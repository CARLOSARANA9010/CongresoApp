import 'package:flutter/material.dart';
import '../../../core/widgets/card_progreso.dart';

/**
 * HOME TAB - Pantalla de Resumen para el Alumno
 * * NOTA PARA BACKEND: 
 * Este widget depende de una lista de mapas llamada 'eventos'.
 * Las llaves esperadas coinciden con la estructura del inventario (WhatsApp 2026-02-27):
 * - 'Nombre conferencia' (String)
 * - 'Salon' (String)
 * - 'Hora' (String)
 * - 'Dia' (String)
 * - 'Talleres' (String? -> null para Conferencias, !null para Talleres)
 * - 'asistido' (bool -> gestionado localmente o por API de asistencia)
 */
class HomeTab extends StatelessWidget {
  final String usuario;
  final List<Map<String, dynamic>> eventos;
  final Function(int)
  onNavigate; // Función para cambiar de pestaña en MainScreen

  const HomeTab({
    super.key,
    required this.usuario,
    required this.eventos,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    // --- LÓGICA DE PROGRESO ---
    int totalEventos = eventos.length;
    int completados = eventos.where((e) => e['asistido'] == true).length;

    double porcentajeDouble = totalEventos > 0
        ? completados / totalEventos
        : 0.0;
    String porcentajeTexto = "${(porcentajeDouble * 100).toInt()}%";

    // --- LÓGICA DE NAVEGACIÓN DINÁMICA ---
    // Buscamos el primer evento pendiente (asistido == false)
    final proximoEvento = eventos.firstWhere(
      (e) => e['asistido'] == false,
      orElse: () => {},
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "¡Hola, $usuario!",
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const Text(
            "Este es tu resumen general del Congreso",
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 30),

          // Gráfica de Progreso Calculada
          Center(
            child: _buildCircularProgress(
              porcentajeDouble,
              porcentajeTexto,
              "Progreso Total",
            ),
          ),

          const SizedBox(height: 40),
          const Text(
            "Próximo evento en tu agenda:",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          // Renderizado condicional del próximo evento
          if (proximoEvento.isNotEmpty)
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(15),
                onTap: () {
                  /** * REDIRECCIÓN DINÁMICA:
                   * Basado en la llave 'Talleres' del backend.
                   * Index 1: ActividadesTab (Si es Taller)
                   * Index 2: ConferenciasTab (Si no es Taller)
                   */
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
      colorPrincipal: Colors.indigo,
    );
  }
}
