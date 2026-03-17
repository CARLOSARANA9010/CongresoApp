import 'package:flutter/material.dart';
import '../../../core/widgets/card_progreso.dart';
import 'package:congreso_app/data/models/alumno_model.dart';

class HomeTab extends StatelessWidget {
  final Alumno alumno;
  final List<Map<String, dynamic>> eventos;
  final Function(int) onNavigate;

  const HomeTab({
    super.key,
    required this.alumno,
    required this.eventos,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    // --- LÓGICA DE PROGRESO FILTRADA (Solo Talleres) ---
    final talleres = eventos.where((e) => e['Talleres'] == "S").toList();

    int totalTalleres = talleres.length;
    int completados = talleres.where((e) => e['asistido'] == true).length;

    double porcentajeDouble = totalTalleres > 0
        ? completados / totalTalleres
        : 0.0;
    String porcentajeTexto = "${(porcentajeDouble * 100).toInt()}%";

    final proximoEvento = eventos.firstWhere(
      (e) => e['asistido'] == false,
      orElse: () => {},
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // BIENVENIDA PERSONALIZADA
          Text(
            "¡Hola, ${alumno.name} ${alumno.secondName}!",
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const Text(
            "Resumen de tus actividades prácticas",
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),

          // --- BANNER DE PAGO PENDIENTE ---
          if (alumno.status.toLowerCase() == "pendiente")
            Container(
              margin: const EdgeInsets.only(bottom: 25),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.redAccent, width: 1),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "ATENCIÓN: Falta el pago de tu inscripción. Acude al módulo del ITESCAM.",
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Gráfica de Progreso
          Center(
            child: _buildCircularProgress(
              porcentajeDouble,
              porcentajeTexto,
              "Progreso en Talleres",
            ),
          ),

          const SizedBox(height: 40),
          const Text(
            "Próximo evento en tu agenda:",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          // Renderizado del próximo evento
          if (proximoEvento.isNotEmpty)
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(15),
                onTap: () {
                  // Navegación inteligente según el tipo, supongo
                  int targetIndex = proximoEvento['Talleres'] != null ? 1 : 2;
                  onNavigate(targetIndex);
                },
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (proximoEvento['color'] as Color? ?? Colors.indigo)
                          .withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      proximoEvento['icono'] as IconData? ?? Icons.timer,
                      color: proximoEvento['color'] as Color? ?? Colors.indigo,
                    ),
                  ),
                  title: Text(
                    proximoEvento['Nombre conferencia']?.toString() ??
                        "Sin título",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "${proximoEvento['Salon'] ?? 'Sede'} • ${proximoEvento['Hora'] ?? '00:00'}\n${proximoEvento['Dia'] ?? 'Fecha pendiente'}",
                    style: const TextStyle(fontSize: 13),
                  ),
                  isThreeLine: true,
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey,
                  ),
                ),
              ),
            )
          else
            const Card(
              elevation: 2,
              child: ListTile(
                leading: Icon(Icons.celebration, color: Colors.orange),
                title: Text("¡Has terminado!"),
                subtitle: Text(
                  "No tienes más eventos pendientes en tu agenda.",
                ),
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
      colorPrincipal: Colors.orange,
    );
  }
}
