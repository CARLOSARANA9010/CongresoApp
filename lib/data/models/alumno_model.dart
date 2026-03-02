/**
 * ALUMNO MODEL - Representación del perfil de usuario y métricas de desempeño
 * * NOTA PARA DESARROLLO BACKEND:
 * 1. El campo 'nombre' debe extraerse del registro de inscripción del alumno [cite: 2026-01-31].
 * 2. El campo 'asistencia' es un valor decimal (0.0 a 1.0) que representa el porcentaje 
 * de participación total en el congreso.
 */
class Alumno {
  final String
  nombre; // Nombre completo o Matrícula del usuario [cite: 2026-01-31]
  final double asistencia; // Porcentaje de eventos asistidos (0.0 - 1.0)

  Alumno({required this.nombre, required this.asistencia});

  /**
   * FACTORY CONSTRUCTOR: Alumno.fromJson
   * Utilizar este método para deserializar la respuesta del API de perfil.
   * Se recomienda que el backend entregue la asistencia ya calculada 
   * o el conteo de eventos para realizar la operación en Flutter [cite: 2026-02-27].
   */
  factory Alumno.fromJson(Map<String, dynamic> json) {
    return Alumno(
      nombre: json['nombre_completo']?.toString() ?? 'Usuario ITESCAM',
      // Se asegura de convertir cualquier valor numérico del backend a double
      asistencia: (json['porcentaje_asistencia'] ?? 0.0).toDouble(),
    );
  }
}
