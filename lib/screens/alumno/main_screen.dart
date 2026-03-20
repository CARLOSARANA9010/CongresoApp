import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'tabs/home_tab.dart';
import 'tabs/actividades_tab.dart';
import 'tabs/conferencias_tab.dart';
import '../../core/widgets/plexus_background.dart';
import 'package:congreso_app/data/models/alumno_model.dart';
import 'package:congreso_app/data/services/api_service.dart';
import 'package:geolocator/geolocator.dart';

/// Hub Principal del Congreso ITESCAM.
class MainScreen extends StatefulWidget {
  final Alumno alumno;
  const MainScreen({super.key, required this.alumno});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  bool _estaCargando = true;
  List<Map<String, dynamic>> misEventos = [];

  static const double itescamLat = 20.3698;
  static const double itescamLon = -90.0515;
  static const double radioMaximoMetros = 2000.0;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  String _limpiarHora(dynamic rawTime) {
    String timeStr = rawTime?.toString() ?? "00:00";
    if (timeStr.contains('T')) return timeStr.split('T')[1].substring(0, 5);
    if (timeStr.contains(' ')) return timeStr.split(' ')[1].substring(0, 5);
    return timeStr.length >= 5 ? timeStr.substring(0, 5) : timeStr;
  }

  Future<void> _cargarDatos() async {
    setState(() => _estaCargando = true);
    misEventos = [];
    final ApiService api = ApiService();

    await api.detectarRed();
    final String hoy = DateTime.now().toIso8601String().split('T')[0];
    List<String> yaAsistidos = await api.getAsistenciasUsuario(
      widget.alumno.email,
    );

    final String miTallerNombre = widget.alumno.workshopName;
    final String miConcurso = widget.alumno.contestName ?? '';

    // --- CARGA DE TALLERES ---
    if (miTallerNombre.isNotEmpty &&
        miTallerNombre.toLowerCase() != 'no entro' &&
        miTallerNombre.toLowerCase() != 'pendiente') {
      final List<dynamic> listaTalleres = await api.getWorkshops();

      final misTalleresInscritos = listaTalleres.where((t) {
        return (t['workshop_name']?.toString() ?? "") == miTallerNombre;
      }).toList();

      for (var t in misTalleresInscritos) {
        final String diaT =
            t['day']?.toString().split(' ')[0].split('T')[0] ?? "";
        final String idManual =
            t['id_workshop']?.toString().trim() ?? ""; // EL DEL QR

        misEventos.add({
          "id": "taller_$idManual",
          "id_manual": idManual,
          "Nombre conferencia": t['workshop_name'] ?? miTallerNombre,
          "Nombre": t['instructor'] ?? "Instructor por definir",
          "Responsable": t['responsible_person'] ?? "Sin responsable",
          "Salon": t['room'] ?? "Sede ITESCAM",
          "Hora": _limpiarHora(t['time']),
          "Dia": diaT,
          "es_de_hoy": diaT == hoy,
          "asistido": yaAsistidos.contains(idManual), // <--- VALIDACIÓN EXACTA
          "Talleres": "S",
          "color": diaT == hoy ? Colors.orange : Colors.grey.shade400,
          "icono": Icons.build,
        });
      }
    }

    // --- CARGA DE CONCURSO ---
    if (miConcurso.isNotEmpty && miConcurso.toLowerCase() != 'no entro') {
      final String idConcurso = "concurso_${widget.alumno.email}";
      misEventos.add({
        "id": idConcurso,
        "id_manual": idConcurso,
        "Nombre conferencia": miConcurso,
        "Nombre": "Competencia Oficial",
        "Responsable": "Comité Organizador",
        "asistido": yaAsistidos.contains(idConcurso),
        "es_de_hoy": true,
        "Talleres": "S",
        "color": Colors.blue,
        "icono": Icons.emoji_events,
        "Salon": "Área de Concursos",
        "Hora": "Por definir",
        "Dia": "Durante el congreso",
      });
    }

    // --- CARGA DE CONFERENCIAS ---
    final listaConferencias = await api.getConferencias();
    for (var conf in listaConferencias) {
      final String diaConf =
          conf['day']?.toString().split(' ')[0].split('T')[0] ?? "";
      final String idConf = conf['Id'].toString().trim(); // NÚMERO DE FILA

      misEventos.add({
        "id": "conf_$idConf",
        "id_manual": idConf, // <--- EL ID DE CONFERENCIA ES EL MANUAL AHORA
        "Nombre conferencia": conf['conference_name'] ?? "Conferencia",
        "Nombre": conf['speaker_name'] ?? "Ponente",
        "Responsable": conf['responsible_person'] ?? "Sin responsable",
        "Salon": conf['room'] ?? "Sede ITESCAM",
        "Hora": _limpiarHora(conf['time']),
        "Dia": diaConf,
        "es_de_hoy": diaConf == hoy,
        "asistido": yaAsistidos.contains(idConf), // <--- VALIDACIÓN EXACTA
        "Talleres": null, // NECESARIO PARA EL FILTRO
        "color": diaConf == hoy ? Colors.indigo : Colors.grey.shade400,
        "icono": Icons.campaign,
      });
    }

    if (mounted) setState(() => _estaCargando = false);
  }

  Future<void> _procesarAsistencia(String idLeido) async {
    final String idLimpio = idLeido.trim();

    final eventoTarget = misEventos.firstWhere(
      (e) => e['id_manual'].toString() == idLimpio,
      orElse: () => <String, dynamic>{},
    );

    if (eventoTarget.isEmpty) {
      _mostrarError("Código QR no reconocido o evento no asignado.");
      return;
    }

    if (eventoTarget['es_de_hoy'] == false) {
      _mostrarError(
        "Acceso denegado. Este evento está programado para el día ${eventoTarget['Dia']}.",
      );
      return;
    }

    if (eventoTarget['asistido'] == true) {
      _mostrarError(
        "La asistencia para este evento ya ha sido registrada previamente.",
      );
      return;
    }

    setState(() => _estaCargando = true);

    Position? miPosicion = await _obtenerPosicionSegura();

    if (miPosicion == null) {
      setState(() => _estaCargando = false);
      _mostrarError(
        "Verificación GPS fallida. Asegúrese de estar dentro de las instalaciones del ITESCAM.",
      );
      return;
    }

    String coordenadasString =
        "${miPosicion.latitude}, ${miPosicion.longitude}";
    String etiquetaTipo = _currentIndex == 1
        ? "taller"
        : (_currentIndex == 2 ? "conferencia" : "home_scan");

    // 5. OBTENCIÓN DEL ID MAESTRO QUE SE ENVÍA A NOCODB
    String idParaRegistro = eventoTarget['id_manual'].toString();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Autenticando ubicación y procesando registro..."),
        backgroundColor: Colors.indigo,
      ),
    );

    final ApiService api = ApiService();
    await api.detectarRed();

    bool exito = await api.registrarAsistencia(
      idEvento:
          idParaRegistro, // <--- ENVIAMOS EL 28, 29, O EL ID DE LA CONFERENCIA EXACTO
      idUsuario: widget.alumno.email,
      tipo: etiquetaTipo,
      lugar: coordenadasString,
    );

    if (exito) {
      _mostrarExito("Registro completado exitosamente.");
      await _cargarDatos();
    } else {
      setState(() => _estaCargando = false);
      _mostrarError(
        "No se pudo registrar. Intenta de nuevo o verifica tu conexión.",
      );
    }
  }

  Future<Position?> _obtenerPosicionSegura() async {
    bool servicioHabilitado;
    LocationPermission permiso;

    servicioHabilitado = await Geolocator.isLocationServiceEnabled();
    if (!servicioHabilitado) return null;

    permiso = await Geolocator.checkPermission();
    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
      if (permiso == LocationPermission.denied) return null;
    }

    Position posicion = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      ),
    );

    double distancia = Geolocator.distanceBetween(
      posicion.latitude,
      posicion.longitude,
      itescamLat,
      itescamLon,
    );

    if (distancia > radioMaximoMetros) return null;

    return posicion;
  }

  void _abrirEscaner() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
        child: MobileScanner(
          onDetect: (capture) {
            final barcode = capture.barcodes.first;
            if (barcode.rawValue != null) {
              Navigator.pop(context);
              _procesarAsistencia(barcode.rawValue!);
            }
          },
        ),
      ),
    );
  }

  void _mostrarExito(String titulo) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("✅ $titulo"), backgroundColor: Colors.green),
    );
  }

  void _mostrarError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("❌ $msg"), backgroundColor: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomeTab(
        alumno: widget.alumno,
        eventos: misEventos,
        onNavigate: (index) => setState(() => _currentIndex = index),
      ),
      ActividadesTab(
        usuario: widget.alumno.email,
        eventos: misEventos,
        onRegister: (id) => _procesarAsistencia(id),
      ),
      ConferenciasTab(
        eventos: misEventos,
        onRegister: (id) => _procesarAsistencia(id),
      ),
    ];
    return Scaffold(
      appBar: AppBar(
        leading: _currentIndex != 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new),
                onPressed: () => setState(() => _currentIndex = 0),
              )
            : null,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        title: Text(
          _currentIndex == 0
              ? "Bienvenido"
              : _currentIndex == 1
              ? "Actividades"
              : "Conferencias",
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.of(context).pushReplacementNamed('/'),
          ),
        ],
      ),
      body: Stack(
        children: [
          const PlexusBackground(),
          _estaCargando
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.indigo),
                )
              : IndexedStack(index: _currentIndex, children: pages),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        height: 70,
        color: Colors.white,
        elevation: 10,
        shape: _currentIndex == 0 ? null : const CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildTabItem(index: 1, icon: Icons.event, label: "Actividades"),
            const SizedBox(width: 40),
            _buildTabItem(index: 2, icon: Icons.school, label: "Conferencias"),
          ],
        ),
      ),
      floatingActionButtonLocation: _currentIndex == 0
          ? null
          : FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _currentIndex == 0
          ? null
          : FloatingActionButton(
              backgroundColor: Colors.indigo,
              onPressed: () => _abrirEscaner(),
              child: const Icon(
                Icons.qr_code_scanner,
                color: Colors.white,
                size: 30,
              ),
            ),
    );
  }

  Widget _buildTabItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    return InkResponse(
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: _currentIndex == index ? Colors.indigo : Colors.grey,
          ),
          Text(
            label,
            style: TextStyle(
              color: _currentIndex == index ? Colors.indigo : Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
