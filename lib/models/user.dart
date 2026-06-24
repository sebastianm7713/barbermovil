class User {
  final int? id;
  final String name;
  final String email;
  final String? password;
  final String role;
  final String? avatarUrl;
  final String? telefono;
  final String? numeroDocumento;

  User({
    this.id,
    required this.name,
    required this.email,
    this.password,
    required this.role,
    this.avatarUrl,
    this.telefono,
    this.numeroDocumento,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"] ?? json["id_usuario"],
    name: json["name"] ?? json["nombre"] ?? '',
    email: json["email"] ?? json["correo"] ?? '',
    password: json["password"],
    role: json["role"] ?? _mapRoleFromId(json["id_rol"] ?? 3),
    avatarUrl: json["avatarUrl"] ?? json["avatar"] ?? json["img"],
    telefono: json["telefono"],
    numeroDocumento: json["numero_documento"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
    "password": password,
    "role": role,
    "avatarUrl": avatarUrl,
    "telefono": telefono,
    "numeroDocumento": numeroDocumento,
  };

  static String _mapRoleFromId(dynamic roleId) {
    if (roleId == 1) return 'admin';
    if (roleId == 2) return 'employee';
    return 'client';
  }
}
