class AppointmentProduct {
  final int id;
  final String name;
  final int quantity;
  final num unitPrice;

  AppointmentProduct({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unitPrice,
  });

  factory AppointmentProduct.fromJson(Map<String, dynamic> json) {
    return AppointmentProduct(
      id: json['id_producto'] ?? json['id'] ?? 0,
      name: json['producto_nombre'] ?? json['nombre'] ?? json['name'] ?? '',
      quantity: json['cantidad'] ?? json['quantity'] ?? 0,
      unitPrice: json['precio_unitario'] ?? json['unitPrice'] ?? 0,
    );
  }
}

class BarberAppointment {
  final int id;
  final int clientId;
  final int barberId;
  final int serviceId;
  final DateTime date;
  final String hour;
  final String service;
  final String serviceImageUrl;
  final List<AppointmentProduct> products;
  String status;

  BarberAppointment({
    required this.id,
    required this.clientId,
    required this.barberId,
    required this.serviceId,
    required this.date,
    required this.hour,
    required this.service,
    required this.serviceImageUrl,
    required this.products,
    required this.status,
  });

  // Constructor para crear citas nuevas (sin ID)
  BarberAppointment.create({
    required this.clientId,
    required this.barberId,
    required this.serviceId,
    required this.date,
    required this.hour,
    required this.service,
    this.serviceImageUrl = '',
    this.products = const [],
    this.status = 'pending',
  }) : id = 0;

  factory BarberAppointment.fromJson(Map<String, dynamic> json) {
    final rawProducts = json['productos'] as List<dynamic>?;
    return BarberAppointment(
      id: json['id'],
      clientId: json['clientId'],
      barberId: json['barberId'],
      serviceId: json['serviceId'],
      date: json['date'] is String ? DateTime.parse(json['date']) : json['date'],
      hour: json['hour'],
      service: json['service'] ?? '',
      serviceImageUrl: json['serviceImageUrl'] ?? '',
      products: rawProducts != null
          ? rawProducts
              .whereType<Map<String, dynamic>>()
              .map((p) => AppointmentProduct.fromJson(p))
              .toList()
          : [],
      status: json['status'],
    );
  }
}
