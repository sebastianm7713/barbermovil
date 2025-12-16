import 'service.dart';

class Appointment {
  final int id;
  final int clientId;
  final int barberId;
  final DateTime date;
  final String hour;
  final Service service;
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

  /// 🔥 ESTE ES EL QUE FALTABA
  Appointment copyWith({
    int? clientId,
    int? barberId,
    DateTime? date,
    String? hour,
    Service? service,
    String? status,
  }) {
    return Appointment(
      id: id,
      clientId: clientId ?? this.clientId,
      barberId: barberId ?? this.barberId,
      date: date ?? this.date,
      hour: hour ?? this.hour,
      service: service ?? this.service,
      status: status ?? this.status,
    );
  }
}
