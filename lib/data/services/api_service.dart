import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/alumno_model.dart';
import 'dart:io'; // Para saber si es Android o iOS
import 'package:device_info_plus/device_info_plus.dart'; // Para sacar el device_id
import 'package:flutter/foundation.dart'; // Para kIsWeb

class ApiService {
  final String baseUrl =
      "https://nocodb.redsureste.org/api/v2/tables/mfqlf08es6ma58g/records";

  final String apiKey = "IQJ3Edbd1aZX3Jmjroo6zodBwwlt7sAC-6yPUZEP";

  Future<List<Alumno>> fetchAlumnos() async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {"xc-token": apiKey},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> rawList = data['list'];
        return rawList.map((json) => Alumno.fromJson(json)).toList();
      } else {
        throw Exception('Error al conectar con NocoDB: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de red: $e');
    }
  }

  // --- MÉTODO DE LOGIN REAL CON NOCODB ---
  Future<Alumno?> loginAlumno(String email) async {
    final cleanEmail = email.trim().toLowerCase();

    final String url = "$baseUrl?limit=1000";

    try {
      print(
        "ESTRATEGIA B: Descargando lista completa para buscar localmente...",
      );

      final response = await http.get(
        Uri.parse(url),
        headers: {"xc-token": apiKey, "Accept": "application/json"},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> list = data['list'];

        print("Descargados ${list.length} registros. Buscando a: $cleanEmail");

        for (var item in list) {
          String dbEmail = item['email']?.toString().trim().toLowerCase() ?? '';

          if (dbEmail == cleanEmail) {
            print("¡BINGO! Alumno encontrado: ${item['name']}");
            return Alumno.fromJson(item);
          }
        }

        print("Revisé toda la lista y no encontré a nadie con ese correo.");
      }
      return null;
    } catch (e) {
      print("Error en login: $e");
      return null;
    }
  }

  // ---MÉTODO PARA BUSCAR EL TALLER ---
  Future<Map<String, dynamic>?> getDetallesTaller(String workshopName) async {
    final String urlWorkshops =
        "https://nocodb.redsureste.org/api/v2/tables/mlxpwzo5buho1ww/records?limit=100";

    try {
      final response = await http.get(
        Uri.parse(urlWorkshops),
        headers: {"xc-token": apiKey, "Accept": "application/json"},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> list = data['list'];

        for (var taller in list) {
          String dbWorkshopName =
              taller['workshop_name']?.toString().trim().toLowerCase() ?? '';
          String targetName = workshopName.trim().toLowerCase();

          if (dbWorkshopName == targetName) {
            return taller;
          }
        }
      }
      return null;
    } catch (e) {
      print("Error al buscar taller: $e");
      return null;
    }
  }

  // --- MÉTODO PARA OBTENER LAS CONFERENCIAS ---
  Future<List<dynamic>> getConferencias() async {
    final String urlConferencias =
        "https://nocodb.redsureste.org/api/v2/tables/mtizpdmz3viqtyw/records?limit=100";

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

  // --- MÉTODO PARA ENVIAR LA ASISTENCIA A NOCODB (VERSIÓN HÍBRIDA) ---
  Future<bool> registrarAsistencia({
    required String idEvento,
    required String idUsuario,
    required String tipo,
    String? lugar,
  }) async {
    final String urlAsistencia =
        "https://nocodb.redsureste.org/api/v2/tables/mep6o9dlege3qmm/records";

    try {
      String deviceId = "dispositivo_desconocido";
      String origen = "desconocido";

      final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

      if (kIsWeb) {
        origen = "web";
        final webInfo = await deviceInfo.webBrowserInfo;

        deviceId = webInfo.userAgent ?? "navegador_web_desconocido";
      } else {
        origen = "movil";
        if (Platform.isAndroid) {
          final androidInfo = await deviceInfo.androidInfo;
          deviceId = androidInfo.id;
        } else if (Platform.isIOS) {
          final iosInfo = await deviceInfo.iosInfo;
          deviceId = iosInfo.identifierForVendor ?? "ios_desconocido";
        }
      }

      // 1. Obtenemos la hora actual
      DateTime ahora = DateTime.now();

      // 2. Le restamos 6 horas (porque México es UTC-6), supongo
      // Si estuviéramos en horario de verano, serían 5, pero por ahora son 6.
      DateTime horaAjustada = ahora.subtract(const Duration(hours: 6));

      final Map<String, dynamic> body = {
        "event_id": idEvento,
        "user_id": idUsuario,
        // Mandamos la hora ya "atrasada" para que NocoDB al subirla quede perfecta
        "attendance_at": horaAjustada.toIso8601String(),
        "device_id": deviceId,
        "event_type": tipo,
        "source": origen,
        "record_place": lugar ?? "Ubicación desconocida",
      };

      print("Enviando asistencia: $body");

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

  Future<List<String>> getAsistenciasUsuario(String email) async {
    final String url =
        "https://nocodb.redsureste.org/api/v2/tables/mep6o9dlege3qmm/records?where=(user_id,eq,$email)";

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {"xc-token": apiKey},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List listado = data['list'] ?? [];

        // Convertimos todo a String y aplicamos trim() para evitar fallos de comparación, supongo.
        return listado
            .map((item) => item['event_id'].toString().trim())
            .toList();
      }
    } catch (e) {
      print("Error recuperando asistencias: $e");
    }
    return [];
  }

  Future<List<dynamic>> getWorkshops() async {
    // Usamos la misma URL que usas en getDetallesTaller, supongo
    final String urlWorkshops =
        "https://nocodb.redsureste.org/api/v2/tables/mlxpwzo5buho1ww/records?limit=100";

    try {
      final response = await http.get(
        Uri.parse(urlWorkshops),
        headers: {"xc-token": apiKey, "Accept": "application/json"},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Devolvemos la lista completa para que el MainScreen haga su magia, bb
        return data['list'] ?? [];
      }
      return [];
    } catch (e) {
      print("Error al traer lista de talleres: $e");
      return [];
    }
  }
}
