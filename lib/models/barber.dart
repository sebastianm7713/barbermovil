class Barber {
  final int id;
  final String name;
  final String specialty;
  final bool available;

  Barber({
    required this.id,
    required this.name,
    required this.specialty,
    required this.available,
  });

  factory Barber.fromJson(Map<String, dynamic> json) {
    return Barber(
      id: json['id'],
      name: json['name'],
      specialty: json['specialty'],
      available: json['available'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'specialty': specialty,
      'available': available,
    };
  }
}
