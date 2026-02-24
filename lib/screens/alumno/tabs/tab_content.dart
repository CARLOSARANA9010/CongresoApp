import 'package:flutter/material.dart';

class AlumnoTabContent extends StatelessWidget {
  final String tipo;
  final String usuario;

  const AlumnoTabContent({
    super.key,
    required this.tipo,
    required this.usuario,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "¡Hola, $usuario!",
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          Text(
            "Tu progreso en $tipo",
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 30),

          // Gráfica Circular (Tu código original)
          Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.indigo.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const SizedBox(
                    width: 150,
                    height: 150,
                    child: CircularProgressIndicator(
                      value: 0.3,
                      strokeWidth: 12,
                      color: Colors.indigo,
                      backgroundColor: Colors.white,
                    ),
                  ),
                  Column(
                    children: [
                      const Text(
                        "30%",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        tipo == "Conferencias" ? "Asistidas" : "Completadas",
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
          const Text(
            "Historial reciente",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          // Aquí puedes mapear una lista según el "tipo"
          _historialItem("Sesión de $tipo 1", "10:00 AM", Colors.green),
          _historialItem("Sesión de $tipo 2", "12:30 PM", Colors.green),
        ],
      ),
    );
  }

  Widget _historialItem(String titulo, String hora, Color color) {
    return ListTile(
      leading: Icon(Icons.check_circle, color: color),
      title: Text(titulo),
      subtitle: Text(hora),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}
