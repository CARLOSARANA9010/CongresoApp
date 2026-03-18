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
    // --- 1. PROGRESO DE TALLERES ---
    // Filtra únicamente los eventos clasificados como talleres, excluyendo concursos.
    final talleres = eventos
        .where(
          (e) =>
              e['Talleres'] == "S" && !e['id'].toString().contains("concurso"),
        )
        .toList();

    int totalTalleres = talleres.length;
    int completadosT = talleres.where((e) => e['asistido'] == true).length;

    // Calcula el porcentaje de avance de talleres. clamp(0.0, 1.0) evita valores fuera de rango en la interfaz gráfica.
    double progresoTalleres = totalTalleres > 0
        ? (completadosT / totalTalleres).clamp(0.0, 1.0)
        : 0.0;
    String textoTalleres = totalTalleres > 0
        ? "$completadosT de $totalTalleres"
        : "0 de 0";

    // --- 2. PROGRESO DE CONFERENCIAS ---
    // Filtra los eventos clasificados como conferencias (sin el tag de taller ni concurso).
    final conferencias = eventos
        .where(
          (e) =>
              e['Talleres'] == null && !e['id'].toString().contains("concurso"),
        )
        .toList();
    int completadasC = conferencias.where((e) => e['asistido'] == true).length;

    // Calcula el porcentaje en base a un mínimo de 3 conferencias requeridas por las reglas del congreso.
    double progresoConferencias = (completadasC / 3.0).clamp(0.0, 1.0);

    // Asigna el texto de progreso, añadiendo un distintivo visual si se supera el mínimo requerido.
    String textoConferencias = completadasC > 3
        ? "$completadasC de 3 🌟"
        : "$completadasC de 3";

    // --- 3. PRÓXIMO EVENTO ---
    // Obtiene el próximo evento pendiente de asistencia que esté programado para el día actual.
    final proximoEvento = eventos.firstWhere(
      (e) => e['asistido'] == false && e['es_de_hoy'] == true,
      orElse: () => {},
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "¡Hola, ${alumno.name} ${alumno.secondName}!",
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const Text(
            "Resumen de tus actividades prácticas",
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),

          // Banner condicional para alumnos con pago de inscripción pendiente.
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

          // Renderizado de tarjetas de progreso.
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: _buildCircularProgress(
                  progresoTalleres,
                  textoTalleres,
                  "Talleres\nCompletados",
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildCircularProgress(
                  progresoConferencias,
                  textoConferencias,
                  "Conferencias\nMínimas",
                  Colors.indigo,
                ),
              ),
            ],
          ),

          const SizedBox(height: 40),
          const Text(
            "Próximo evento en tu agenda (Hoy):",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          // Renderizado de la tarjeta del próximo evento o mensaje de día libre.
          if (proximoEvento.isNotEmpty)
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(15),
                onTap: () {
                  // Redirección dinámica dependiendo del tipo de evento (Taller o Conferencia).
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
                leading: Icon(Icons.celebration, color: Colors.green),
                title: Text("¡Día libre!"),
                subtitle: Text(
                  "No tienes eventos pendientes para hoy. ¡Disfruta el congreso!",
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Método auxiliar para instanciar el widget de CardProgreso con parámetros específicos.
  Widget _buildCircularProgress(
    double porcentaje,
    String titulo,
    String subtitulo,
    Color colorP,
  ) {
    return CardProgreso(
      porcentaje: porcentaje,
      titulo: titulo,
      subtitulo: subtitulo,
      colorPrincipal: colorP,
    );
  }
}
