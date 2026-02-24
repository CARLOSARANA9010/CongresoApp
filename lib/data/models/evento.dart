class Evento {
  final String id;
  final String titulo;
  final String ponente;
  final String lugar;
  final String hora;
  final bool esConferencia;
  bool asistido;

  Evento({
    required this.id,
    required this.titulo,
    required this.ponente,
    required this.lugar,
    required this.hora,
    required this.esConferencia,
    this.asistido = false,
  });
}
