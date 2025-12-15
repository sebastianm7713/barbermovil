import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/roles.dart';

class RoleService {
  final String baseUrl = 'http://localhost:3000/api/roles';

  /// Obtener todos los roles
  Future<List<Role>> getRoles() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Role.fromJson(e)).toList();
    } else {
      throw Exception('Error al cargar roles');
    }
  }

  /// Crear rol
  Future<Role> createRole(Role role) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(role.toJson()),
    );

    if (response.statusCode == 201) {
      return Role.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al crear rol');
    }
  }

  /// Actualizar rol
  Future<Role> updateRole(Role role) async {
    final response = await http.put(
      Uri.parse('$baseUrl/${role.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(role.toJson()),
    );

    if (response.statusCode == 200) {
      return Role.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al actualizar rol');
    }
  }

  /// Eliminar rol
  Future<void> deleteRole(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));

    if (response.statusCode != 200) {
      throw Exception('Error al eliminar rol');
    }
  }
}
