import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'tabs/home_tab.dart';
import 'tabs/actividades_tab.dart';
import 'tabs/conferencias_tab.dart';
import '../../core/widgets/plexus_background.dart';
import 'package:congreso_app/data/models/alumno_model.dart';
import 'package:congreso_app/data/services/api_service.dart';
import 'package:geolocator/geolocator.dart';

/**
 * MAIN SCREEN - Hub Principal del Congreso ITESCAM
 */
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
  // --- CONFIGURACIÓN DE SEGURIDAD ---
  static const double itescamLat = 20.3698;
  static const double itescamLon = -90.0515;
  static const double radioMaximoMetros = 50000.0;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  // Helper para limpiar el formato de hora de la DB
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

    // 1. Detectamos hoy para el filtro maestro, supongo
    final String hoy = DateTime.now().toIso8601String().split('T')[0];

    // Obtenemos el historial de asistencias
    List<String> yaAsistidos = await api.getAsistenciasUsuario(
      widget.alumno.email,
    );

    final String miTallerNombre = widget.alumno.workshopName ?? '';
    final String miConcurso = widget.alumno.contestName ?? '';

    // --- 2. CARGAR TALLER DEL ALUMNO (Búsqueda inteligente en lista completa) ---
    if (miTallerNombre.isNotEmpty &&
        miTallerNombre.toLowerCase() != 'no entro' &&
        miTallerNombre.toLowerCase() != 'pendiente') {
      print("DEBUG BEAKO: Buscando '$miTallerNombre' en la lista de hoy...");
      final List<dynamic> listaTalleres = await api.getWorkshops();

      try {
        final detallesTaller = listaTalleres.firstWhere((t) {
          final String nombreT = t['workshop_name']?.toString() ?? "";
          final String diaT =
              t['day']?.toString().split(' ')[0].split('T')[0] ?? "";
          return nombreT == miTallerNombre && diaT == hoy;
        });

        final String idManual =
            detallesTaller['id_workshop']?.toString().trim() ?? "";
        final String idRealFila = detallesTaller['Id'].toString().trim();

        misEventos.add({
          "id": "taller_$idRealFila",
          "Nombre conferencia":
              detallesTaller['workshop_name'] ?? miTallerNombre,
          "Nombre": detallesTaller['instructor'] ?? "Instructor por definir",
          "Responsable":
              detallesTaller['responsible_person'] ?? "Sin responsable",
          "Salon": detallesTaller['room'] ?? "Sede ITESCAM",
          "Hora": _limpiarHora(detallesTaller['time']),
          "Dia": hoy,
          "asistido": yaAsistidos.contains(idManual),
          "Talleres": "S",
          "color": Colors.orange,
          "icono": Icons.build,
        });
        print("DEBUG BEAKO: ¡Éxito! Taller de hoy añadido correctamente.");
      } catch (e) {
        // Si .firstWhere no encuentra nada, cae aquí
        print(
          "DEBUG BEAKO: No se encontró el taller '$miTallerNombre' para el día $hoy, supongo.",
        );
      }
    }

    // --- 3. CARGAR CONCURSO (Siempre visible o según tu lógica, bb) ---
    if (miConcurso.isNotEmpty && miConcurso.toLowerCase() != 'no entro') {
      final String idConcurso = "concurso_${widget.alumno.email}";
      misEventos.add({
        "id": idConcurso,
        "Nombre conferencia": miConcurso,
        "Nombre": "Competencia Oficial",
        "Responsable": "Comité Organizador",
        "asistido": yaAsistidos.contains(idConcurso),
        "Talleres": "S",
        "color": Colors.blue,
        "icono": Icons.emoji_events,
        "Salon": "Área de Concursos",
        "Hora": "Por definir",
        "Dia": "Durante el congreso",
      });
    }

    // --- 4. CARGAR CONFERENCIAS GENERALES (Solo las de hoy) ---
    final listaConferencias = await api.getConferencias();
    for (var conf in listaConferencias) {
      final String diaConf =
          conf['day']?.toString().split(' ')[0].split('T')[0] ?? "";

      if (diaConf == hoy) {
        final String idConf = conf['Id'].toString().trim();
        misEventos.add({
          "id": "conf_$idConf",
          "Nombre conferencia": conf['conference_name'] ?? "Conferencia",
          "Nombre": conf['speaker_name'] ?? "Ponente",
          "Responsable": conf['responsible_person'] ?? "Sin responsable",
          "Salon": conf['room'] ?? "Sede ITESCAM",
          "Hora": _limpiarHora(conf['time']),
          "Dia": hoy,
          "asistido": yaAsistidos.contains(idConf),
          "Talleres": null,
          "color": Colors.indigo,
          "icono": Icons.campaign,
        });
      }
    }

    if (mounted) setState(() => _estaCargando = false);
  }

  Future<void> _procesarAsistencia(String idLeido) async {
    final String idLimpio = idLeido.trim();

    // 1. Validación de Duplicados local
    // Verificamos si ya existe un evento con ese ID marcado como asistido
    bool yaEstaRegistrado = misEventos.any(
      (evento) =>
          evento['asistido'] == true &&
          evento['id'].toString().contains(idLimpio),
    );

    if (yaEstaRegistrado) {
      _mostrarError("¡Alto ahí, atrevido! Ya registraste tu asistencia aquí.");
      return;
    }

    // 2. EL FILTRO DE SEGURIDAD (GPS)
    setState(() => _estaCargando = true);

    Position? miPosicion = await _obtenerPosicionSegura();

    if (miPosicion == null) {
      setState(() => _estaCargando = false);
      _mostrarError(
        "No estás en el ITESCAM o el GPS está apagado. ¡Ni lo intentes!",
      );
      return;
    }

    // Preparar datos para el registro
    String coordenadasString =
        "${miPosicion.latitude}, ${miPosicion.longitude}";
    String etiquetaTipo = _currentIndex == 1
        ? "taller"
        : (_currentIndex == 2 ? "conferencia" : "home_scan");

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Validando ubicación y registrando..."),
        backgroundColor: Colors.indigo,
      ),
    );

    // 3. REGISTRO EN LA API
    final ApiService api = ApiService();
    bool exito = await api.registrarAsistencia(
      idEvento: idLimpio,
      idUsuario: widget.alumno.email,
      tipo: etiquetaTipo,
      lugar: coordenadasString,
    );

    if (exito) {
      setState(() {
        for (var evento in misEventos) {
          String idTarjetaLimpio = evento['id']
              .toString()
              .replaceAll("taller_", "")
              .replaceAll("conf_", "")
              .replaceAll("concurso_", "");

          if (idTarjetaLimpio == idLimpio) {
            print(
              "✅ ¡MATCH! Marcando ${evento['Nombre conferencia']} como asistido",
            );
            evento['asistido'] = true;
          }
        }
      });

      _mostrarExito("Asistencia confirmada en el ITESCAM");

      await _cargarDatos();
    } else {
      _mostrarError("Hubo un problema con la base de datos");
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
      desiredAccuracy: LocationAccuracy.high, // <--- Esto es vital, bb
      timeLimit: const Duration(seconds: 10), // Si tarda mucho, algo anda mal
    );

    double distancia = Geolocator.distanceBetween(
      posicion.latitude,
      posicion.longitude,
      itescamLat,
      itescamLon,
    );

    if (distancia > radioMaximoMetros) {
      print("DEBUG: Demasiado lejos ($distancia m)");
      return null;
    }

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
      SnackBar(
        content: Text("✅ Registrado: $titulo"),
        backgroundColor: Colors.green,
      ),
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
        // Usamos una muesca (notch) solo si el botón está presente
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
