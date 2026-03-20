class Alumno {
  final int? id;
  final String name;
  final String secondName;
  final String email;
  final String workshopName;
  final String? contestName;
  final String status;

  Alumno({
    this.id,
    required this.name,
    required this.secondName,
    required this.email,
    required this.workshopName,
    this.contestName,
    required this.status,
  });

  // Para convertir el JSON que nos manda NocoDB a un objeto de Flutter
  factory Alumno.fromJson(Map<String, dynamic> json) {
    return Alumno(
      id: json['Id'],
      name: json['name'] ?? '',
      secondName: json['second_name'] ?? '',
      email: json['email'] ?? '',
      workshopName: json['workshop_name'] ?? '',
      contestName: json['contest_name'],
      status: json['status'] ?? 'Pendiente',
    );
  }
}
