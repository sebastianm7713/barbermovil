class User {
  final int? id;
  final String name;
  final String email;
  final String? password; // AHORA OPCIONAL
  final String role;
  final String? avatarUrl;

  User({
    this.id,
    required this.name,
    required this.email,
    this.password,       // YA NO ES REQUERIDO
    required this.role,
    this.avatarUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        name: json["name"],
        email: json["email"],
        password: json["password"], // puede ser null
        role: json["role"],
        avatarUrl: json["avatarUrl"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
        "password": password,
        "role": role,
        "avatarUrl": avatarUrl,
      };
}
