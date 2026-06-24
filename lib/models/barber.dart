class Barber {
  final int id;
  final String name;
  final String specialty;
  final String phone;
  final String email;
  final String status;

  Barber({
    required this.id,
    required this.name,
    required this.specialty,
    required this.phone,
    required this.email,
    required this.status,
  });

  factory Barber.fromJson(Map<String, dynamic> json) {
    return Barber(
      id: json['id'],
      name: json['name'],
      specialty: json['specialty'],
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      status: json['status'] ?? 'active',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'specialty': specialty,
      'phone': phone,
      'email': email,
      'status': status,
    };
  }
}
