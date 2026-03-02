import 'package:http/http.dart' as http;
import 'dart:convert';

/**
 * API SERVICE - Capa de Comunicación con el Backend del ITESCAM
 * * NOTA PARA DESARROLLO BACKEND:
 * 1. La URL base debe apuntar al dominio oficial del congreso.
 * 2. El endpoint '/registrar-asistencia' debe aceptar peticiones POST.
 * 3. Se requiere que el servidor responda con un HTTP Status 200 para confirmar el éxito.
 */
class ApiService {
  // Base URL: Punto de acceso al servidor del ITESCAM
  static const String _baseUrl = 'https://api.itescam.edu.mx';

  /**
   * MÉTODO: registrarAsistencia
   * Envía la información de presencialidad de un alumno a un evento específico.
   * [idUsuario] corresponde a la matrícula del alumno
   * [idEvento] es el identificador único de la conferencia o taller.
   */
  static Future<bool> registrarAsistencia({
    required String idUsuario,
    required String idEvento,
  }) async {
    final url = Uri.parse('$_baseUrl/registrar-asistencia');

    try {
      /** * ESTRUCTURA DEL PAYLOAD (JSON):
       * El backend debe procesar estas llaves exactas para la inserción en BD.
       */
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'id_usuario': idUsuario,
          'id_evento': idEvento,
          'fecha_registro': DateTime.now()
              .toIso8601String(), // Timestamp ISO 8601
        }),
      );

      // Verificación de respuesta exitosa del servidor
      if (response.statusCode == 200) {
        return true;
      } else {
        // En caso de error (404, 500, etc.), se registra el log para depuración
        print("Servidor respondió con error: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      // Manejo de excepciones de red (Timeout, DNS, falta de internet)
      print("Excepción de red en ApiService: $e");
      return false;
    }
  }

  /**
   * NOTA FUTURA: Se pueden añadir métodos adicionales aquí, como:
   * - obtenerEventos() para traer la lista dinámica desde la base de datos.
   * - validarLogin() para la pantalla de acceso.
   */
}
