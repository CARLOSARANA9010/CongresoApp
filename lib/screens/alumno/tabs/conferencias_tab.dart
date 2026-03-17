import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/**
 * CONFERENCIAS TAB - Módulo de Visualización de Ponencias
 */
class ConferenciasTab extends StatelessWidget {
  final List<Map<String, dynamic>> eventos;
  // --- EL CEREBRO PARA EL ESCÁNER, supongo ---
  final Function(String) onRegister;

  const ConferenciasTab({
    super.key,
    required this.eventos,
    required this.onRegister,
  });

  @override
  Widget build(BuildContext context) {
    // FILTRADO: Solo conferencias
    final conferencias = eventos.where((e) => e['Talleres'] == null).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
      children: [
        const Text(
          "Ciclo de Conferencias",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),

        ...conferencias.map(
          (conf) => _cardInformativa(
            context,
            id: conf['id']?.toString() ?? "0",
            titulo: conf['Nombre conferencia']?.toString() ?? "Sin título",
            instructor: conf['Nombre']?.toString() ?? "Por asignar",
            responsable:
                conf['Responsable']?.toString() ?? "Sin responsable asignado",
            lugar: conf['Salon']?.toString() ?? "Sede Central",
            hora: conf['Hora']?.toString() ?? "Horario pendiente",
            dia: conf['Dia']?.toString() ?? "Día pendiente",
            pdfUrl: conf['Documento completo']?.toString() ?? "",
            asistido: conf['asistido'] ?? false, // <--- ESTO ES VITAL
            color: (conf['asistido'] ?? false)
                ? Colors.green
                : (conf['color'] as Color? ?? Colors.indigo),
            icono: conf['icono'] as IconData? ?? Icons.school,
          ),
        ),
      ],
    );
  }

  Widget _cardInformativa(
    BuildContext context, {
    required String id,
    required String titulo,
    required String instructor,
    required String responsable,
    required String lugar,
    required String hora,
    required String dia,
    required String pdfUrl,
    required bool asistido,
    required Color color,
    required IconData icono,
  }) {
    return Card(
      elevation: asistido ? 8 : 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: asistido
            ? const BorderSide(color: Colors.green, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        // <--- AÑADIMOS EL CLIC, supongo
        borderRadius: BorderRadius.circular(15),
        onTap: asistido
            ? null
            : () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      "¡Usa el escáner QR para registrar tu asistencia!",
                    ),
                    backgroundColor: Colors.indigo,
                  ),
                );
              },
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
                        decoration: asistido
                            ? TextDecoration.lineThrough
                            : null,
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
                  _filaDetalle(Icons.calendar_today, "Día: $dia"),
                  const SizedBox(height: 8),
                  _filaDetalle(Icons.person, "Ponente: $instructor"),
                  const SizedBox(height: 8),
                  _filaDetalle(
                    Icons.assignment_ind,
                    "Responsable: $responsable",
                  ),
                  const SizedBox(height: 8),
                  _filaDetalle(Icons.location_on, "Lugar: $lugar"),
                  const SizedBox(height: 8),
                  _filaDetalle(Icons.access_time, "Horario: $hora"),

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
      ),
    );
  }

  Widget _filaDetalle(IconData icon, String texto) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(texto, style: TextStyle(color: Colors.grey[800])),
        ),
      ],
    );
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) throw 'Could not launch $url';
  }
}
