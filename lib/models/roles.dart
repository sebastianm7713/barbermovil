class Role {
  final int id;
  final String name; // admin, employee, client
  final String description;

  Role({
    required this.id,
    required this.name,
    required this.description,
  });

  // JSON → Modelo
  factory Role.fromJson(Map<String, dynamic> json) => Role(
        id: json["id"],
        name: json["name"],
        description: json["description"],
      );

  // Modelo → JSON
  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "description": description,
      };
}
