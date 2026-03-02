import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'tabs/home_tab.dart';
import 'tabs/actividades_tab.dart';
import 'tabs/conferencias_tab.dart';
import '../../core/widgets/plexus_background.dart';

/**
 * MAIN SCREEN - Hub Principal del Congreso ITESCAM
 * * NOTA PARA BACKEND:
 * 1. 'misEventos' debe sincronizarse con la DB para persistir la asistencia [cite: 2026-02-27].
 * 2. La lógica de 'proximoEvento' ahora es dinámica y se actualiza al marcar asistencia.
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
    _cargarDatos(); // Recupera el estado inicial de los eventos [cite: 2026-02-27]
  }

  Future<void> _cargarDatos() async {
    setState(() => _estaCargando = true);
    await Future.delayed(const Duration(seconds: 1)); // Simulación de red

    // Backend: Estos datos deben venir de un GET /eventos?usuario=matricula [cite: 2026-02-27]
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
    // --- LÓGICA DEL PRÓXIMO EVENTO ---
    // Buscamos el primer evento en la lista que aún no ha sido asistido [cite: 2026-02-27]
    final proximo = misEventos.firstWhere(
      (e) => e['asistido'] == false,
      orElse: () => {},
    );

    final List<Widget> pages = [
      HomeTab(
        usuario: widget.nombreUsuario,
        eventos: misEventos,
        // Pasamos la función de navegación para que la Card del Home funcione [cite: 2026-02-27]
        onNavigate: (index) => setState(() => _currentIndex = index),
      ),
      ActividadesTab(usuario: widget.nombreUsuario, eventos: misEventos),
      ConferenciasTab(eventos: misEventos),
    ];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: _currentIndex != 0,
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
        onPressed: () => _abrirEscaner(),
        child: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 30),
      ),
    );
  }

  // --- MÉTODOS DE SCANNER Y ASISTENCIA ---

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

  void _procesarAsistencia(String idLeido) {
    setState(() {
      for (var evento in misEventos) {
        if (evento['id'] == idLeido) {
          evento['asistido'] =
              true; // Se marca como asistido y se actualiza el Home [cite: 2026-02-27]
          _mostrarExito(evento['Nombre conferencia'] ?? "Evento");
          return;
        }
      }
      _mostrarError(idLeido);
    });
  }

  void _mostrarExito(String titulo) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("✅ Registrado: $titulo"),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _mostrarError(String id) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("❌ Código $id no válido"),
        backgroundColor: Colors.redAccent,
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
