import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import '../models/alumno_model.dart';

class ApiService {
  // --- RUTAS BASE (Dinámicas) ---
  // La externa es la que usaremos por defecto si no estamos en el ITESCAM
  String _dominioBase = "https://nocodb.redsureste.org/api/v2/tables";

  // IP Local del ITESCAM para cuando estemos en su Wi-Fi
  final String _ipLocalBase = "http://10.0.10.15:8036/api/v2/tables";

  // --- IDs DE TABLAS (Para armar URLs limpias) ---
  final String _tablaAlumnos = "mfqlf08es6ma58g";
  final String _tablaTalleres = "mlxpwzo5buho1ww";
  final String _tablaConferencias = "mtizpdmz3viqtyw";
  final String _tablaAsistencias = "mep6o9dlege3qmm";

  final String apiKey = "IQJ3Edbd1aZX3Jmjroo6zodBwwlt7sAC-6yPUZEP";

  /// DETECTOR DE RED
  /// Verifica si el servidor local del ITESCAM está accesible.
  /// Si responde rápido, la app cambiará al "modo local" para saltarse el firewall.
  Future<void> detectarRed() async {
    try {
      print("Haciendo ping a la red del ITESCAM");
      // Hacemos una petición rápida a la tabla de conferencias (o alumnos) en local
      final String pingUrl =
          "$_ipLocalBase/$_tablaConferencias/records?limit=1";

      final response = await http
          .get(Uri.parse(pingUrl), headers: {"xc-token": apiKey})
          .timeout(const Duration(seconds: 2)); // 2 segundos o abortamos
      if (response.statusCode >= 200) {
        _dominioBase = _ipLocalBase;
        print("Red ITESCAM detectada. Usando IP 10.0.10.1.");
      }
    } catch (e) {
      // Si hay timeout o error, nos quedamos con nocodb.redsureste.org
      _dominioBase = "https://nocodb.redsureste.org/api/v2/tables";
      print("Fuera del Tec o IP bloqueada. Usando ruta externa.");
    }
  }

  ///  LOGIN DEL ALUMNO (Descarga completa + Filtro local)
  Future<Alumno?> loginAlumno(String email) async {
    await detectarRed(); // Validamos dónde estamos antes de intentar entrar

    final cleanEmail = email.trim().toLowerCase();
    final String url = "$_dominioBase/$_tablaAlumnos/records?limit=1000";

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {"xc-token": apiKey, "Accept": "application/json"},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> list = data['list'];

        for (var item in list) {
          String dbEmail = item['email']?.toString().trim().toLowerCase() ?? '';
          if (dbEmail == cleanEmail) {
            print("¡BINGO! Alumno encontrado: ${item['name']}");
            return Alumno.fromJson(item);
          }
        }
      }
      return null;
    } catch (e) {
      print("Error en login: $e");
      return null;
    }
  }

  ///  OBTENER TODOS LOS TALLERES (Para filtrar los días del alumno)
  Future<List<dynamic>> getWorkshops() async {
    await detectarRed();
    final String urlWorkshops =
        "$_dominioBase/$_tablaTalleres/records?limit=100";

    try {
      final response = await http.get(
        Uri.parse(urlWorkshops),
        headers: {"xc-token": apiKey, "Accept": "application/json"},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['list'] ?? [];
      }
      return [];
    } catch (e) {
      print("Error al traer lista de talleres: $e");
      return [];
    }
  }

  ///  OBTENER CONFERENCIAS GLOBALES
  Future<List<dynamic>> getConferencias() async {
    await detectarRed();
    final String urlConferencias =
        "$_dominioBase/$_tablaConferencias/records?limit=100";

    try {
      final response = await http.get(
        Uri.parse(urlConferencias),
        headers: {"xc-token": apiKey, "Accept": "application/json"},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['list'] ?? [];
      }
      return [];
    } catch (e) {
      print("Error al traer conferencias: $e");
      return [];
    }
  }

  ///  REGISTRAR ASISTENCIA (Con metadatos de GPS y Dispositivo)
  Future<bool> registrarAsistencia({
    required String idEvento,
    required String idUsuario,
    required String tipo,
    String? lugar,
  }) async {
    await detectarRed();
    final String urlAsistencia = "$_dominioBase/$_tablaAsistencias/records";

    try {
      // Metadatos del dispositivo
      String deviceId = await _obtenerDeviceId();
      String origen = kIsWeb ? "web" : "movil";

      DateTime ahora = DateTime.now();
      DateTime horaAjustada = ahora.subtract(const Duration(hours: 6)); // UTC-6

      final Map<String, dynamic> body = {
        "event_id": idEvento,
        "user_id": idUsuario,
        "attendance_at": horaAjustada.toIso8601String(),
        "device_id": deviceId,
        "event_type": tipo,
        "source": origen,
        "record_place": lugar ?? "Ubicación desconocida",
      };

      final response = await http.post(
        Uri.parse(urlAsistencia),
        headers: {
          "xc-token": apiKey,
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("¡Asistencia registrada con éxito en NocoDB!");
        return true;
      } else {
        print("Error del servidor al registrar: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error catastrófico en la asistencia: $e");
      return false;
    }
  }

  /// HISTORIAL DE ASISTENCIAS DEL USUARIO
  Future<List<String>> getAsistenciasUsuario(String email) async {
    await detectarRed();
    final String url =
        "$_dominioBase/$_tablaAsistencias/records?where=(user_id,eq,$email)";

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {"xc-token": apiKey},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List listado = data['list'] ?? [];
        return listado
            .map((item) => item['event_id'].toString().trim())
            .toList();
      }
    } catch (e) {
      print("Error recuperando asistencias: $e");
    }
    return [];
  }

  // --- Helper interno para limpiar el código principal ---
  Future<String> _obtenerDeviceId() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (kIsWeb) {
      final webInfo = await deviceInfo.webBrowserInfo;
      return webInfo.userAgent ?? "web_desconocido";
    } else if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id;
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor ?? "ios_desconocido";
    }
    return "desconocido";
  }
}
