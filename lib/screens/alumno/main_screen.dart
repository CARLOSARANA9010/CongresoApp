import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'tabs/home_tab.dart';
import 'tabs/actividades_tab.dart';
import 'tabs/conferencias_tab.dart';
import '../../core/widgets/plexus_background.dart';

class MainScreen extends StatefulWidget {
  final String nombreUsuario;
  const MainScreen({super.key, required this.nombreUsuario});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // 1. LISTA MAESTRA DE DATOS (Lo que pidió el Profe Lira)
  // Agregamos campos extra para que ActividadesTab no de error de null
  List<Map<String, dynamic>> misEventos = [
    {
      "id": "flutter_01",
      "titulo": "Taller de Flutter Intermedio",
      "instructor": "Ing. Roberto G.",
      "lugar": "Laboratorio B",
      "hora": "10:00 AM",
      "asistido": false,
      "color": Colors.orange,
      "icono": Icons.code,
    },
    {
      "id": "ia_2026",
      "titulo": "Conferencia IA y Futuro",
      "instructor": "Dr. Armando Ruiz",
      "lugar": "Auditorio Principal",
      "hora": "12:00 PM",
      "asistido": false,
      "color": Colors.blue,
      "icono": Icons.psychology,
    },
    {
      "id": "cyber_cloud",
      "titulo": "Seguridad en la Nube",
      "instructor": "Mtra. Elena Solís",
      "lugar": "Sala de Usos Múltiples",
      "hora": "04:00 PM",
      "asistido": false,
      "color": Colors.redAccent,
      "icono": Icons.lock_outline,
    },
  ];

  @override
  Widget build(BuildContext context) {
    // 2. RECONSTRUCCIÓN DINÁMICA DE PÁGINAS
    // Las definimos aquí dentro para que siempre usen la lista 'misEventos' actualizada
    final List<Widget> pages = [
      HomeTab(usuario: widget.nombreUsuario),
      ActividadesTab(usuario: widget.nombreUsuario, eventos: misEventos),
      ConferenciasTab(eventos: misEventos),
    ];

    return Scaffold(
      extendBody: false,
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
          IndexedStack(index: _currentIndex, children: pages),
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
            const SizedBox(width: 40), // Espacio para el FAB
            _buildTabItem(index: 2, icon: Icons.school, label: "Conferencias"),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.indigo,
        shape: const CircleBorder(),
        elevation: 8,
        onPressed: () => _abrirEscaner(),
        child: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 30),
      ),
    );
  }

  // Widget auxiliar para los botones del BottomAppBar
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
            const SizedBox(height: 20),
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
          tituloEvento = evento['titulo'];
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
}
