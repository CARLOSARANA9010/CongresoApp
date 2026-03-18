import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Módulo de visualización del ciclo de conferencias.
/// Presenta los eventos teóricos y valida la disponibilidad según la fecha actual.
class ConferenciasTab extends StatelessWidget {
  final List<Map<String, dynamic>> eventos;
  final Function(String) onRegister;

  const ConferenciasTab({
    super.key,
    required this.eventos,
    required this.onRegister,
  });

  @override
  Widget build(BuildContext context) {
    // Filtra la colección de eventos para aislar únicamente las conferencias.
    final conferencias = eventos.where((e) => e['Talleres'] == null).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
      children: [
        const Text(
          "Ciclo de Conferencias",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),

        // Iteración y renderizado de las tarjetas de conferencia.
        ...conferencias.map((conf) {
          final bool esDeHoy = conf['es_de_hoy'] == true;

          return _cardInformativa(
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
            asistido: conf['asistido'] ?? false,
            color: conf['color'] as Color? ?? Colors.indigo,
            icono: conf['icono'] as IconData? ?? Icons.school,
            esDeHoy: esDeHoy,
          );
        }),
      ],
    );
  }

  /// Construye el componente visual para una conferencia específica.
  /// Incluye validación de interacción mediante la variable [esDeHoy].
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
    required bool esDeHoy,
  }) {
    return Card(
      elevation: asistido ? 8 : (esDeHoy ? 2 : 1),
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: asistido
            ? const BorderSide(color: Colors.green, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: asistido
            ? null
            : () {
                // Notificación contextual dependiendo del estado temporal del evento.
                final String mensaje = esDeHoy
                    ? "Usa el botón central de escáner QR para registrar tu asistencia."
                    : "Esta conferencia está programada para otra fecha. No disponible hoy.";

                final Color colorFondo = esDeHoy
                    ? Colors.indigo
                    : Colors.redAccent;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(mensaje),
                    backgroundColor: colorFondo,
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
                  // Renderizado de etiquetas de estado.
                  if (asistido)
                    const Badge(
                      label: Text("REGISTRADO"),
                      backgroundColor: Colors.green,
                    )
                  else if (!esDeHoy)
                    const Badge(
                      label: Text("NO DISPONIBLE HOY"),
                      backgroundColor: Colors.grey,
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

                  // Despliegue condicional del botón de material adjunto.
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

  /// Construye una fila de detalles utilizando una estructura uniforme.
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

  /// Procesa la apertura de enlaces externos hacia el material de la conferencia.
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri))
      throw 'No se pudo procesar la solicitud para el enlace: $url';
  }
}
