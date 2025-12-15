class BarberAppointment {
  final int id;
  final int clientId;
  final int barberId;
  final DateTime date;
  final String hour;
  final String service;
  String status;

  BarberAppointment({
    required this.id,
    required this.clientId,
    required this.barberId,
    required this.date,
    required this.hour,
    required this.service,
    required this.status,
  });
}
