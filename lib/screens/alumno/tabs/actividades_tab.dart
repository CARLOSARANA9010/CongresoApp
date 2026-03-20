import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Vista encargada de renderizar la lista de talleres y dinámicas del usuario.
/// Incorpora validaciones visuales para eventos bloqueados por fecha.
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
    // Filtra la lista maestra para obtener únicamente los eventos de tipo taller.
    final actividades = eventos.where((e) => e['Talleres'] != null).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
      children: [
        const Text(
          "Talleres y Dinámicas",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),

        // Banner informativo sobre el uso del escáner QR.
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.amber.withValues(alpha: 0.1),
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

        // Mapeo iterativo de las actividades hacia el componente visual de tarjeta.
        ...actividades.map((ev) {
          final bool esDeHoy = ev['es_de_hoy'] == true;

          return _cardDetallada(
            context,
            id: ev['id']?.toString() ?? "0",
            titulo: ev['Nombre conferencia']?.toString() ?? "Sin título",
            instructor: ev['Nombre']?.toString() ?? "Por asignar",
            responsable: ev['Responsable']?.toString() ?? "Sin responsable",
            lugar: ev['Salon']?.toString() ?? "Sede Central",
            hora: ev['Hora']?.toString() ?? "Horario pendiente",
            dia: ev['Dia']?.toString() ?? "Día pendiente",
            pdfUrl: ev['Documento completo']?.toString() ?? "",
            asistido: ev['asistido'] ?? false,
            color: ev['color'] as Color? ?? Colors.grey,
            icono: ev['icono'] as IconData? ?? Icons.build,
            esDeHoy: esDeHoy,
          );
        }),
      ],
    );
  }

  /// Construye una tarjeta detallada para cada evento, manejando sus estados
  /// de asistencia y disponibilidad según la fecha.
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
    required bool esDeHoy,
  }) {
    return Card(
      elevation: asistido ? 8 : (esDeHoy ? 4 : 1),
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
                // Validación de retroalimentación al usuario según el día del evento.
                final String mensaje = esDeHoy
                    ? "Usa el botón central de escáner QR para registrar tu asistencia."
                    : "Este evento está programado para otra fecha. No disponible hoy.";

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
                color: color.withValues(alpha: 0.1),
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
                  // Indicadores visuales de estado del evento.
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

                  // Botón de descarga condicionado a la existencia de la URL.
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

  /// Construye una fila estandarizada para mostrar metadatos del evento con icono.
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

  /// Ejecuta el lanzamiento de URLs externas mediante el paquete url_launcher.
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) throw 'No se pudo abrir la URL externa: $url';
  }
}
