import 'service.dart';

class Appointment {
  final int id;
  final int clientId;
  final int barberId;
  final int? serviceId;
  final DateTime date;
  final String hour;
  final Service? service;
  final String status;
  final List<dynamic> products;

  Appointment({
    required this.id,
    required this.clientId,
    required this.barberId,
    this.serviceId,
    required this.date,
    required this.hour,
    this.service,
    required this.status,
    this.products = const [],
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'],
      clientId: json['clientId'],
      barberId: json['barberId'],
      serviceId: json['serviceId'],
      date: json['date'],
      hour: json['hour'],
      service: json['service'],
      status: json['status'],
      products: json['products'] ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientId': clientId,
      'barberId': barberId,
      'serviceId': serviceId,
      'date': date,
      'hour': hour,
      'service': service,
      'status': status,
      'products': products,
    };
  }

  /// 🔥 ESTE ES EL QUE FALTABA
  Appointment copyWith({
    int? clientId,
    int? barberId,
    int? serviceId,
    DateTime? date,
    String? hour,
    Service? service,
    String? status,
    List<dynamic>? products,
  }) {
    return Appointment(
      id: id,
      clientId: clientId ?? this.clientId,
      barberId: barberId ?? this.barberId,
      serviceId: serviceId ?? this.serviceId,
      date: date ?? this.date,
      hour: hour ?? this.hour,
      service: service ?? this.service,
      status: status ?? this.status,
      products: products ?? this.products,
    );
  }
}
