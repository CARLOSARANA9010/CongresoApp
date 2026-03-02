import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:congreso_app/data/services/api_service.dart';

/**
 * ACTIVIDADES TAB - Vista de Talleres y Dinámicas
 * * NOTA PARA BACKEND: 
 * Este widget filtra la lista maestra 'eventos' buscando la presencia de la llave 'Talleres'.
 * Se espera que el objeto JSON contenga llaves como 'Nombre conferencia', 'Nombre', 'Salon', etc.
 */
class ActividadesTab extends StatelessWidget {
  final List<Map<String, dynamic>> eventos;
  final String usuario;

  const ActividadesTab({
    super.key,
    required this.eventos,
    required this.usuario,
  });

  @override
  Widget build(BuildContext context) {
    // FILTRADO LÓGICO: Solo incluimos elementos clasificados como talleres
    final actividades = eventos.where((e) => e['Talleres'] != null).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
      children: [
        const Text(
          "Talleres y Dinámicas",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),

        // Mapeo dinámico de la lista filtrada a componentes visuales (Cards)
        ...actividades.map(
          (ev) => _cardDetallada(
            context,
            id:
                ev['id']?.toString() ??
                "0", // ID necesario para el POST de asistencia
            titulo: ev['Nombre conferencia']?.toString() ?? "Sin título",
            instructor: ev['Nombre']?.toString() ?? "Por asignar",
            lugar: ev['Salon']?.toString() ?? "Sede Central",
            hora: ev['Hora']?.toString() ?? "Horario pendiente",
            dia: ev['Dia']?.toString() ?? "Día pendiente",
            pdfUrl: ev['Documento completo']?.toString() ?? "",
            asistido: ev['asistido'] ?? false,
            color: (ev['asistido'] ?? false)
                ? Colors.green
                : (ev['color'] as Color? ?? Colors.indigo),
            icono: ev['icono'] as IconData? ?? Icons.event,
          ),
        ),
      ],
    );
  }

  /// Componente visual de la tarjeta de actividad
  Widget _cardDetallada(
    BuildContext context, {
    required String id,
    required String titulo,
    required String instructor,
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
      // InkWell gestiona la interacción táctil y el registro de asistencia
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: asistido
            ? null // Inhabilitar clic si el usuario ya está registrado
            : () async {
                // INTEGRACIÓN API: Envío de matrícula y ID de evento al servidor [cite: 2026-02-27]
                bool exito = await ApiService.registrarAsistencia(
                  idUsuario:
                      usuario, // Proveniente de la sesión del usuario [cite: 2026-01-31]
                  idEvento: id,
                );

                if (exito) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("¡Asistencia registrada en $titulo!"),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Error al registrar. Intenta de nuevo."),
                    ),
                  );
                }
              },
        child: Column(
          children: [
            // Cabecera de la tarjeta con Icono, Título y Badge de estado
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
            // Cuerpo de la tarjeta con detalles del evento (Día, Ponente, Lugar, Hora)
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  _filaDetalle(Icons.calendar_today, "Día: $dia"),
                  const SizedBox(height: 8),
                  _filaDetalle(Icons.person, "Instructor: $instructor"),
                  const SizedBox(height: 8),
                  _filaDetalle(Icons.location_on, "Lugar: $lugar"),
                  const SizedBox(height: 8),
                  _filaDetalle(Icons.access_time, "Horario: $hora"),

                  // Botón de acción para visualizar/descargar material PDF
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

  /// Helper para construir filas informativas con iconos
  Widget _filaDetalle(IconData icon, String texto) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(texto, style: TextStyle(color: Colors.grey[800])),
      ],
    );
  }

  /// Lógica para abrir enlaces externos (PDFs) en el navegador o visor nativo
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) throw 'Could not launch $url';
  }
}
