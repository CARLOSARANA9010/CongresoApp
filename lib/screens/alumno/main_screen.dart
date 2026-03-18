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
/// Gestiona el estado global de eventos, validaciones de red y seguridad GPS.
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

  // Constantes de geocercado para validación de asistencia
  static const double itescamLat = 20.3698;
  static const double itescamLon = -90.0515;
  static const double radioMaximoMetros =
      5000.0; // Restringido a 500m para evitar registros remotos

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  /// Formatea la cadena de tiempo proveniente de la base de datos.
  String _limpiarHora(dynamic rawTime) {
    String timeStr = rawTime?.toString() ?? "00:00";
    if (timeStr.contains('T')) return timeStr.split('T')[1].substring(0, 5);
    if (timeStr.contains(' ')) return timeStr.split(' ')[1].substring(0, 5);
    return timeStr.length >= 5 ? timeStr.substring(0, 5) : timeStr;
  }

  /// Carga el itinerario completo del usuario, resolviendo estado de red e historial de asistencias.
  Future<void> _cargarDatos() async {
    setState(() => _estaCargando = true);
    misEventos = [];
    final ApiService api = ApiService();

    // 1. Detección de entorno de red (ITESCAM vs Externo)
    await api.detectarRed();

    // 2. Establecimiento de la fecha actual para bloqueo temporal
    final String hoy = DateTime.now().toIso8601String().split('T')[0];

    // 3. Obtención de asistencias previas
    List<String> yaAsistidos = await api.getAsistenciasUsuario(
      widget.alumno.email,
    );

    final String miTallerNombre = widget.alumno.workshopName ?? '';
    final String miConcurso = widget.alumno.contestName ?? '';

    // --- CARGA DE TALLERES (Múltiples días) ---
    if (miTallerNombre.isNotEmpty &&
        miTallerNombre.toLowerCase() != 'no entro' &&
        miTallerNombre.toLowerCase() != 'pendiente') {
      final List<dynamic> listaTalleres = await api.getWorkshops();

      // Filtrado de todas las sesiones correspondientes al taller inscrito
      final misTalleresInscritos = listaTalleres.where((t) {
        return (t['workshop_name']?.toString() ?? "") == miTallerNombre;
      }).toList();

      for (var t in misTalleresInscritos) {
        final String diaT =
            t['day']?.toString().split(' ')[0].split('T')[0] ?? "";
        final String idManual = t['id_workshop']?.toString().trim() ?? "";
        final String idRealFila = t['Id'].toString().trim();

        misEventos.add({
          "id": "taller_$idRealFila",
          "id_manual": idManual, // Identificador auxiliar para cruce de datos
          "Nombre conferencia": t['workshop_name'] ?? miTallerNombre,
          "Nombre": t['instructor'] ?? "Instructor por definir",
          "Responsable": t['responsible_person'] ?? "Sin responsable",
          "Salon": t['room'] ?? "Sede ITESCAM",
          "Hora": _limpiarHora(t['time']),
          "Dia": diaT,
          "es_de_hoy": diaT == hoy, // Bandera para bloqueo UI en ActividadesTab
          "asistido":
              yaAsistidos.contains(idManual) ||
              yaAsistidos.contains(idRealFila),
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
        "es_de_hoy": true, // Los concursos suelen estar siempre disponibles
        "Talleres": "S",
        "color": Colors.blue,
        "icono": Icons.emoji_events,
        "Salon": "Área de Concursos",
        "Hora": "Por definir",
        "Dia": "Durante el congreso",
      });
    }

    // --- CARGA DE CONFERENCIAS GLOBALES ---
    final listaConferencias = await api.getConferencias();
    for (var conf in listaConferencias) {
      final String diaConf =
          conf['day']?.toString().split(' ')[0].split('T')[0] ?? "";
      final String idConf = conf['Id'].toString().trim();

      misEventos.add({
        "id": "conf_$idConf",
        "id_manual": idConf,
        "Nombre conferencia": conf['conference_name'] ?? "Conferencia",
        "Nombre": conf['speaker_name'] ?? "Ponente",
        "Responsable": conf['responsible_person'] ?? "Sin responsable",
        "Salon": conf['room'] ?? "Sede ITESCAM",
        "Hora": _limpiarHora(conf['time']),
        "Dia": diaConf,
        "es_de_hoy":
            diaConf == hoy, // Bandera para bloqueo UI en ConferenciasTab
        "asistido": yaAsistidos.contains(idConf),
        "Talleres": null,
        "color": diaConf == hoy ? Colors.indigo : Colors.grey.shade400,
        "icono": Icons.campaign,
      });
    }

    if (mounted) setState(() => _estaCargando = false);
  }

  /// Procesa la lógica de negocio al detectar un código QR.
  Future<void> _procesarAsistencia(String idLeido) async {
    final String idLimpio = idLeido.trim();
    final String hoy = DateTime.now().toIso8601String().split('T')[0];

    // 1. Identificación del evento objetivo en la memoria local
    final eventoTarget = misEventos.firstWhere(
      (e) =>
          e['id'].toString().contains(idLimpio) ||
          e['id_manual'].toString() == idLimpio,
      orElse: () => {},
    );

    if (eventoTarget.isEmpty) {
      _mostrarError("Código QR no reconocido o evento no asignado.");
      return;
    }

    // 2. Control de Acceso Basado en Tiempo (Bloqueo de fechas futuras/pasadas)
    if (eventoTarget['es_de_hoy'] == false) {
      _mostrarError(
        "Acceso denegado. Este evento está programado para el día ${eventoTarget['Dia']}.",
      );
      return;
    }

    // 3. Validación de duplicidad
    if (eventoTarget['asistido'] == true) {
      _mostrarError(
        "La asistencia para este evento ya ha sido registrada previamente.",
      );
      return;
    }

    setState(() => _estaCargando = true);

    // 4. Validación de Geocercado (GPS)
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

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Autenticando ubicación y procesando registro..."),
        backgroundColor: Colors.indigo,
      ),
    );

    // 5. Transacción de red hacia la API
    final ApiService api = ApiService();
    await api.detectarRed(); // Re-verificación de conectividad local

    bool exito = await api.registrarAsistencia(
      idEvento: idLimpio,
      idUsuario: widget.alumno.email,
      tipo: etiquetaTipo,
      lugar: coordenadasString,
    );

    if (exito) {
      _mostrarExito("Registro completado exitosamente.");
      await _cargarDatos(); // Refresco del estado global para actualizar UI
    } else {
      setState(() => _estaCargando = false);
      _mostrarError("Fallo de comunicación con el servidor de base de datos.");
    }
  }

  /// Obtiene la ubicación del dispositivo con alta precisión y valida contra la geocerca.
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
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 10),
    );

    double distancia = Geolocator.distanceBetween(
      posicion.latitude,
      posicion.longitude,
      itescamLat,
      itescamLon,
    );

    if (distancia > radioMaximoMetros) {
      return null;
    }

    return posicion;
  }

  /// Despliega el componente modal del escáner óptico.
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
