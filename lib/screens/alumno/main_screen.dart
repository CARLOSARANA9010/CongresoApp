import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'tabs/home_tab.dart';
import 'tabs/actividades_tab.dart';
import 'tabs/conferencias_tab.dart';
import '../../core/widgets/plexus_background.dart';

/**
 * MAIN SCREEN - Contenedor Principal de la App (Alumno)
 * * NOTA PARA DESARROLLO BACKEND:
 * 1. La lista 'misEventos' es el HUB central de datos. 
 * 2. Se ha implementado '_cargarDatos' para simular la persistencia desde BD.
 * 3. 'id' es la llave primaria para vincular el escaneo QR con el registro.
 */
class MainScreen extends StatefulWidget {
  final String nombreUsuario;
  const MainScreen({super.key, required this.nombreUsuario});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  bool _estaCargando = true;

  // --- ESTRUCTURA DE DATOS MAESTRA ---
  List<Map<String, dynamic>> misEventos = [];

  @override
  void initState() {
    super.initState();
    _cargarDatos(); // Inicializa la carga de datos al entrar
  }

  /**
   * MÉTODO: _cargarDatos
   * Simula la petición GET al servidor para recuperar eventos y estados de asistencia.
   * Backend: Sustituir el delay por una llamada real al ApiService.
   */
  Future<void> _cargarDatos() async {
    setState(() => _estaCargando = true);

    // Simulación de latencia de red
    await Future.delayed(const Duration(seconds: 1));

    // Datos iniciales (En producción vendrán del servidor)
    misEventos = [
      {
        "id": "flutter_01",
        "Nombre conferencia": "Taller de Flutter Intermedio",
        "Nombre": "Ing. Roberto G.",
        "Salon": "Laboratorio B",
        "Hora": "10:00 AM",
        "Dia": "Lunes 16",
        "asistido": false,
        "Talleres": "S",
        "color": Colors.orange,
        "icono": Icons.code,
      },
      {
        "id": "ia_2026",
        "Nombre conferencia": "Conferencia IA y Futuro",
        "Nombre": "Dr. Armando Ruiz",
        "Salon": "Auditorio Principal",
        "Hora": "12:00 PM",
        "Dia": "Martes 17",
        "asistido": false,
        "Talleres": null,
        "color": Colors.blue,
        "icono": Icons.psychology,
      },
    ];

    setState(() => _estaCargando = false);
  }

  @override
  Widget build(BuildContext context) {
    // RECONSTRUCCIÓN DINÁMICA DE PÁGINAS
    final List<Widget> pages = [
      HomeTab(
        usuario: widget.nombreUsuario,
        eventos: misEventos,
        onNavigate: (index) => setState(() => _currentIndex = index),
      ),
      ActividadesTab(usuario: widget.nombreUsuario, eventos: misEventos),
      ConferenciasTab(eventos: misEventos),
    ];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: _currentIndex != 0,
        leading: _currentIndex != 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildTabItem(index: 1, icon: Icons.event, label: "Actividades"),
            const SizedBox(width: 40),
            _buildTabItem(index: 2, icon: Icons.school, label: "Conferencias"),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.indigo,
        shape: const CircleBorder(),
        onPressed: () => _abrirEscaner(),
        child: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 30),
      ),
    );
  }

  // --- MÉTODOS DE ASISTENCIA ---

  void _abrirEscaner() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                "Escanear QR de Asistencia",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            Expanded(
              child: MobileScanner(
                onDetect: (capture) {
                  final barcode = capture.barcodes.first;
                  final String? codigoLeido = barcode.rawValue;
                  if (codigoLeido != null) {
                    Navigator.pop(context);
                    _procesarAsistencia(codigoLeido);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _procesarAsistencia(String idLeido) {
    bool encontrado = false;
    String tituloEvento = "";

    setState(() {
      for (var evento in misEventos) {
        if (evento['id'] == idLeido) {
          evento['asistido'] = true;
          encontrado = true;
          tituloEvento = evento['Nombre conferencia']?.toString() ?? "Evento";
        }
      }
    });

    if (encontrado) {
      _mostrarExito(tituloEvento);
    } else {
      _mostrarError(idLeido);
    }
  }

  void _mostrarExito(String titulo) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("✅ Asistencia registrada: $titulo"),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _mostrarError(String id) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("❌ El código '$id' no es válido"),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
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
