class Appointment {
  final int id;
  final int clientId;
  final int barberId;
  final DateTime date;
  final String hour;
  final String service; // Aquí solo el nombre del servicio
  final String status;

  Appointment({
    required this.id,
    required this.clientId,
    required this.barberId,
    required this.date,
    required this.hour,
    required this.service,
    required this.status,
  });
}
