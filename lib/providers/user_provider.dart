import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class UserProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<User> _users = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<User> get users => _users;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Obtener todos los usuarios
  Future<void> loadUsers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _apiService.getUsuarios();
      _users = (data as List)
          .map((userJson) => User.fromJson(_mapBackendToFrontend(userJson)))
          .toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Obtener usuario por ID
  Future<User?> getUserById(int id) async {
    try {
      final data = await _apiService.getUsuarioById(id);
      return User.fromJson(_mapBackendToFrontend(data));
    } catch (e) {
      return null;
    }
  }

  /// Crear usuario
  Future<User?> createUser(User user) async {
    try {
      final response = await _apiService.createUsuario({
        'id_rol': _mapRoleToId(user.role),
        'id_tipo_documento': 1, // Asumiendo CC por defecto
        'numero_documento': user.numeroDocumento ?? '',
        'nombre': user.name,
        'email': user.email,
        'telefono': user.telefono,
        'direccion': '', // Campo opcional
        'contrasena': user.password ?? '',
        'img': user.avatarUrl,
        'estado': 'activo',
      });

      final data = response['data'] ?? response;
      return User.fromJson(_mapBackendToFrontend(data));
    } catch (e) {
      throw Exception('Error al crear usuario: $e');
    }
  }

  /// Actualizar usuario
  Future<bool> updateUser(int id, User user) async {
    try {
      await _apiService.updateUsuario(id, {
        'id_rol': _mapRoleToId(user.role),
        'id_tipo_documento': 1,
        'numero_documento': user.numeroDocumento ?? '',
        'nombre': user.name,
        'email': user.email,
        'telefono': user.telefono,
        'direccion': '',
        'contrasena': user.password,
        'img': user.avatarUrl,
        'estado': 'activo',
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Eliminar usuario
  Future<bool> deleteUser(int id) async {
    try {
      await _apiService.deleteUsuario(id);
      _users.removeWhere((user) => user.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Limpiar error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Mapear estructura del backend
  Map<String, dynamic> _mapBackendToFrontend(dynamic backendData) {
    if (backendData is Map<String, dynamic>) {
      return {
        'id_usuario': backendData['id_usuario'] ?? backendData['id'],
        'nombre': backendData['nombre'] ?? backendData['name'] ?? '',
        'email': backendData['email'] ?? '',
        'telefono': backendData['telefono'] ?? '',
        'numero_documento': backendData['numero_documento'] ?? '',
        'id_rol': backendData['id_rol'] ?? 3,
        'img': backendData['img'] ?? backendData['avatarUrl'] ?? '',
        'estado': backendData['estado'] ?? 'activo',
      };
    }
    return {};
  }

  int _mapRoleToId(String role) {
    switch (role) {
      case 'admin':
        return 1;
      case 'employee':
        return 2;
      case 'client':
      default:
        return 3;
    }
  }
}
