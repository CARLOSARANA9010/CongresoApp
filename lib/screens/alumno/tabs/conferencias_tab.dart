import 'package:flutter/material.dart';

class ConferenciasTab extends StatelessWidget {
  final List<Map<String, dynamic>> eventos;

  const ConferenciasTab({super.key, required this.eventos});

  @override
  Widget build(BuildContext context) {
    final conferencias = eventos
        .where((e) => e['id'].contains('ia') || e['id'].contains('cyber'))
        .toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
      children: [
        const Text(
          "Ciclo de Conferencias",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),

        ...conferencias
            .map(
              (conf) => _cardInformativa(
                titulo: conf['titulo'],
                instructor: conf['instructor'],
                lugar: conf['lugar'],
                hora: conf['hora'],
                color: conf['color'] ?? Colors.indigo,
                icono: conf['icono'] ?? Icons.school,
              ),
            )
            .toList(),
      ],
    );
  }

  Widget _cardInformativa({
    required String titulo,
    required String instructor,
    required String lugar,
    required String hora,
    required Color color,
    required IconData icono,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(15),
              ),
            ),
            child: Row(
              children: [
                Icon(icono, color: color),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    titulo,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                _filaDetalle(Icons.person, "Ponente: $instructor"),
                const SizedBox(height: 8),
                _filaDetalle(Icons.location_on, "Lugar: $lugar"),
                const SizedBox(height: 8),
                _filaDetalle(Icons.access_time, "Horario: $hora"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _filaDetalle(IconData icon, String texto) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(texto, style: TextStyle(color: Colors.grey[800])),
      ],
    );
  }
}
