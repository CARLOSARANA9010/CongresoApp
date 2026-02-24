import 'package:flutter/material.dart';
import '../../../core/widgets/card_progreso.dart';

class HomeTab extends StatelessWidget {
  final String usuario;
  const HomeTab({super.key, required this.usuario});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "¡Hola, $usuario!",
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const Text(
            "Este es tu resumen general del Congreso",
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 30),

          // Gráfica General (Promedio de todo)
          Center(child: _buildCircularProgress(0.45, "45%", "Progreso Total")),

          const SizedBox(height: 30),
          const Text(
            "Próximo evento en tu agenda:",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Card(
            child: ListTile(
              leading: Icon(Icons.timer, color: Colors.indigo),
              title: Text("Conferencia: IA en 2026"),
              subtitle: Text("Auditorio Principal • 04:00 PM"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircularProgress(
    double porcentaje,
    String titulo,
    String subtitulo,
  ) {
    return CardProgreso(
      porcentaje: porcentaje,
      titulo: titulo,
      subtitulo: subtitulo,
      colorPrincipal: Colors.indigo,
    );
  }
}
