/// EVENTO MODEL - Representación de datos de conferencias y talleres
/// * NOTA PARA DESARROLLO BACKEND:
/// Este modelo utiliza un patrón 'Factory' para la deserialización de JSON.
/// Asegurarse de que las llaves del mapa (keys) coincidan exactamente con 
/// la respuesta del API del ITESCAM para evitar valores vacíos por defecto.
class Evento {
  final String dia;
  final String hora;
  final String salon;
  final String ponente;
  final String tituloConferencia;
  final String documentoUrl;
  final String responsable;
  final bool esTaller;

  Evento({
    required this.dia,
    required this.hora,
    required this.salon,
    required this.ponente,
    required this.tituloConferencia,
    required this.documentoUrl,
    required this.responsable,
    required this.esTaller,
  });

  /// FACTORY CONSTRUCTOR: Evento.fromJson
  /// Mapea un objeto dinámico (JSON) proveniente del servidor a una instancia de clase Evento.
  /// * Mapeo de llaves backend (Inventario WhatsApp 2026-02-27):
  /// - 'Dia' -> dia
  /// - 'Hora' -> hora
  /// - 'Salon' -> salon
  /// - 'Nombre' -> ponente
  /// - 'Nombre conferencia' -> tituloConferencia
  /// - 'Documento completo' -> documentoUrl
  /// - 'Responsable' -> responsable
  factory Evento.fromJson(Map<String, dynamic> json) {
    return Evento(
      // Se utiliza el operador ?? para garantizar que el tipo String no sea Null
      dia: json['Dia'] ?? '',
      hora: json['Hora'] ?? '',
      salon: json['Salon'] ?? '',
      ponente: json['Nombre'] ?? '',
      tituloConferencia: json['Nombre conferencia'] ?? '',
      documentoUrl: json['Documento completo'] ?? '',
      responsable: json['Responsable'] ?? '',

      /** * LÓGICA DE CLASIFICACIÓN:
       * El sistema determina si es un taller verificando la existencia 
       * de datos en el campo 'Talleres' del backend.
       */
      esTaller: json['Talleres'] != null,
    );
  }
}
