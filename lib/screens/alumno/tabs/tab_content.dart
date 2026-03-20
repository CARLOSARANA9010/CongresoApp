import 'package:flutter/material.dart';

/// ALUMNO TAB CONTENT - Vista de Detalle de Progreso por Categoría
/// * NOTA PARA BACKEND: 
/// Este widget filtra la lista maestra 'eventos' basándose en el parámetro 'tipo'.
/// 1. Calcula el porcentaje de asistencia localmente para la gráfica circular.
/// 2. Genera un historial visual de los eventos ya marcados como 'asistido: true'.
class AlumnoTabContent extends StatelessWidget {
  final String tipo; // "Conferencias" o "Talleres"
  final String usuario;
  final List<Map<String, dynamic>> eventos; // Lista maestra de eventos

  const AlumnoTabContent({
    super.key,
    required this.tipo,
    required this.usuario,
    required this.eventos,
  });

  @override
  Widget build(BuildContext context) {
    // FILTRADO: Obtenemos solo los eventos que pertenecen a esta categoría [cite: 2026-02-27]
    // Si tipo es 'Talleres', filtramos donde 'Talleres' != null.
    final listaFiltrada = eventos.where((e) {
      if (tipo == "Talleres") return e['Talleres'] != null;
      return e['Talleres'] == null;
    }).toList();

    // CÁLCULO DE PROGRESO ESPECÍFICO
    int total = listaFiltrada.length;
    int asistidos = listaFiltrada.where((e) => e['asistido'] == true).length;
    double porcentaje = total > 0 ? asistidos / total : 0.0;
    String porcentajeTexto = "${(porcentaje * 100).toInt()}%";

    // HISTORIAL: Solo eventos completados de esta categoría
    final historial = listaFiltrada
        .where((e) => e['asistido'] == true)
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "¡Hola, $usuario!",
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          Text(
            "Tu progreso en $tipo",
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 30),

          // --- GRÁFICA CIRCULAR DINÁMICA ---
          Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.indigo.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 150,
                    height: 150,
                    child: CircularProgressIndicator(
                      value:
                          porcentaje, // Valor real calculado [cite: 2026-02-27]
                      strokeWidth: 12,
                      color: Colors.indigo,
                      backgroundColor: Colors.white,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        porcentajeTexto,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        tipo == "Conferencias" ? "Asistidas" : "Completadas",
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),

          const Text(
            "Historial reciente",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          // --- RENDERIZADO DE HISTORIAL REAL ---
          if (historial.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                "Aún no tienes asistencias registradas en esta categoría.",
                style: TextStyle(
                  color: Colors.grey[500],
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
          else
            ...historial.map(
              (e) => _historialItem(
                e['Nombre conferencia']?.toString() ?? "Evento",
                "${e['Dia']} - ${e['Hora']}",
                Colors.green,
              ),
            ),
        ],
      ),
    );
  }

  /// Widget de item para el historial
  Widget _historialItem(String titulo, String hora, Color color) {
    return ListTile(
      leading: Icon(Icons.check_circle, color: color),
      title: Text(titulo),
      subtitle: Text(hora),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}
