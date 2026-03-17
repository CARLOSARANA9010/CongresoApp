import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/**
 * ACTIVIDADES TAB - Vista de Talleres y Dinámicas
 */
class ActividadesTab extends StatelessWidget {
  final List<Map<String, dynamic>> eventos;
  final String usuario;
  final Function(String) onRegister;

  const ActividadesTab({
    super.key,
    required this.eventos,
    required this.usuario,
    required this.onRegister,
  });

  @override
  Widget build(BuildContext context) {
    final actividades = eventos.where((e) => e['Talleres'] != null).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
      children: [
        const Text(
          "Talleres y Dinámicas",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),

        // --- TEXTO INFORMATIVO PARA EL ALUMNO, supongo ---
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.amber.shade700, width: 0.5),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.amber.shade800, size: 20),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  "Escanea el código QR del taller para registrar tu asistencia automáticamente.",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        ...actividades.map((ev) {
          // Verificación de seguridad: solo procesamos si es un taller real, supongo
          final bool esTallerReal = ev['Talleres'] == "S";

          return _cardDetallada(
            context,
            id: ev['id']?.toString() ?? "0",
            // Si es taller real, usamos sus datos, si no, lo ignoramos, supongo
            titulo: ev['Nombre conferencia']?.toString() ?? "Sin título",
            instructor: ev['Nombre']?.toString() ?? "Por asignar",
            responsable: ev['Responsable']?.toString() ?? "Sin responsable",
            lugar: ev['Salon']?.toString() ?? "Sede Central",
            hora: ev['Hora']?.toString() ?? "Horario pendiente",
            dia: ev['Dia']?.toString() ?? "Día pendiente",
            pdfUrl: ev['Documento completo']?.toString() ?? "",
            asistido: ev['asistido'] ?? false,
            color: (ev['asistido'] ?? false) ? Colors.green : Colors.orange,
            icono: ev['icono'] as IconData? ?? Icons.build,
          );
        }),
      ],
    );
  }

  Widget _cardDetallada(
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
      elevation: asistido ? 8 : 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: asistido
            ? const BorderSide(color: Colors.green, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        // --- CAMBIAMOS EL COMPORTAMIENTO DEL CLIC, supongo ---
        onTap: asistido
            ? null
            : () {
                // En lugar de registrar directo, mandamos un aviso sarcástico
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                      "¡Alto ahí! Usa el botón de QR para registrar tu asistencia.",
                    ),
                    backgroundColor: Colors.indigo,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    action: SnackBarAction(
                      label: "OK",
                      textColor: Colors.white,
                      onPressed: () {},
                    ),
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
                  _filaDetalle(Icons.person, "Instructor: $instructor"),
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
                    OutlinedButton.icon(
                      onPressed: () => _launchURL(pdfUrl),
                      icon: const Icon(Icons.download),
                      label: const Text("DESCARGAR GUÍA"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: color,
                        side: BorderSide(color: color),
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
