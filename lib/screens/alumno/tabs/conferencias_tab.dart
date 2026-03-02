import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Librería externa para manejo de URIs

/**
 * CONFERENCIAS TAB - Módulo de Visualización de Ponencias
 * * NOTA PARA DESARROLLO BACKEND:
 * 1. El filtrado de esta vista se basa en la ausencia de la llave 'Talleres' (== null).
 * 2. Se asume que el objeto JSON del backend respeta las llaves: 
 * 'Nombre conferencia', 'Nombre', 'Salon', 'Hora', 'Dia' y 'Documento completo'.
 */
class ConferenciasTab extends StatelessWidget {
  final List<Map<String, dynamic>> eventos;

  const ConferenciasTab({super.key, required this.eventos});

  @override
  Widget build(BuildContext context) {
    // FILTRADO: Se excluyen elementos marcados como talleres para esta vista específica
    final conferencias = eventos.where((e) => e['Talleres'] == null).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
      children: [
        const Text(
          "Ciclo de Conferencias",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),

        // Mapeo de la lista 'conferencias' a componentes funcionales _cardInformativa
        ...conferencias.map(
          (conf) => _cardInformativa(
            // Manejo preventivo de nulos mediante operador Null-coalescing (??) [cite: 2026-02-27]
            titulo: conf['Nombre conferencia']?.toString() ?? "Sin título",
            instructor: conf['Nombre']?.toString() ?? "Por asignar",
            lugar: conf['Salon']?.toString() ?? "Sede Central",
            hora: conf['Hora']?.toString() ?? "Horario pendiente",
            dia: conf['Dia']?.toString() ?? "Día pendiente",
            pdfUrl: conf['Documento completo']?.toString() ?? "",
            color: conf['color'] as Color? ?? Colors.indigo,
            icono: conf['icono'] as IconData? ?? Icons.school,
          ),
        ),
      ],
    );
  }

  /// Componente UI: Tarjeta informativa de la conferencia
  Widget _cardInformativa({
    required String titulo,
    required String instructor,
    required String lugar,
    required String hora,
    required String dia,
    required String pdfUrl,
    required Color color,
    required IconData icono,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          // Header: Área visual con Iconografía y Título
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
          // Body: Información detallada de la ponencia
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                _filaDetalle(Icons.calendar_today, "Día: $dia"),
                const SizedBox(height: 8),
                _filaDetalle(Icons.person, "Ponente: $instructor"),
                const SizedBox(height: 8),
                _filaDetalle(Icons.location_on, "Lugar: $lugar"),
                const SizedBox(height: 8),
                _filaDetalle(Icons.access_time, "Horario: $hora"),

                // Call-To-Action: Visualización de recursos (PDF/Links) del backend
                if (pdfUrl.isNotEmpty) ...[
                  const SizedBox(height: 15),
                  ElevatedButton.icon(
                    onPressed: () => _launchURL(pdfUrl),
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text("VER MATERIAL"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 45),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Widget Atómico: Construye una fila de detalle con consistencia visual
  Widget _filaDetalle(IconData icon, String texto) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(texto, style: TextStyle(color: Colors.grey[800])),
      ],
    );
  }

  /// Handler: Orquestador de lanzamiento de URIs externas
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) throw 'Could not launch $url';
  }
}
