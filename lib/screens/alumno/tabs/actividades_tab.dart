import 'package:flutter/material.dart';

class ActividadesTab extends StatelessWidget {
  final String usuario;
  final List<Map<String, dynamic>> eventos;

  const ActividadesTab({
    super.key,
    required this.usuario,
    required this.eventos,
  });

  @override
  Widget build(BuildContext context) {
    // Filtramos solo los que NO son conferencias (si es que tienes mezclados)
    // O mostramos todos si la lista 'eventos' ya viene filtrada de actividades
    final actividades = eventos;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
      children: [
        const Text(
          "Talleres y Dinámicas",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),

        // --- GENERACIÓN DINÁMICA ---
        ...actividades.map((ev) {
          return _cardDetallada(
            id: ev['id'],
            titulo: ev['titulo'],
            instructor: ev['instructor'] ?? "Por asignar",
            lugar: ev['lugar'] ?? "Sede Central",
            hora: ev['hora'] ?? "Horario pendiente",
            // Si ya asistió, el color cambia a verde automáticamente
            color: ev['asistido']
                ? Colors.green
                : (ev['color'] ?? Colors.indigo),
            icono: ev['icono'] ?? Icons.event,
            asistido: ev['asistido'],
          );
        }).toList(),
      ],
    );
  }

  Widget _cardDetallada({
    required String id,
    required String titulo,
    required String instructor,
    required String lugar,
    required String hora,
    required Color color,
    required IconData icono,
    required bool asistido,
  }) {
    return Card(
      elevation: asistido ? 8 : 4, // Más sombra si ya está completado
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        // Borde verde si ya tiene la "palomita"
        side: asistido
            ? const BorderSide(color: Colors.green, width: 2)
            : BorderSide.none,
      ),
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
                Icon(asistido ? Icons.check_circle : icono, color: color),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    titulo,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: color,
                      decoration: asistido ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
                if (asistido)
                  const Badge(
                    label: Text("REGISTRADO"),
                    backgroundColor: Colors.green,
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
