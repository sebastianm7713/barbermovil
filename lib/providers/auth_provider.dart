import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  User? _currentUser;
  String? _token;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  User? get user => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// 🔐 LOGIN
  Future<User?> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.login(email, password);
      
      // Extraer token desde data wrapper o raíz
      final tokenData = response['data'] ?? response;
      _token = tokenData['token'];
      
      // Crear usuario desde respuesta
      final userData = tokenData['user'] ?? tokenData;
      final userId = userData['id_usuario'] ?? userData['id'];
      if (userId != null) {
        _currentUser = User(
          id: userId,
          name: userData['nombre'] ?? userData['name'] ?? 'Usuario',
          email: userData['email'] ?? email,
          role: _mapRoleFromId(userData['id_rol'] ?? userData['rol'] ?? 3),
          avatarUrl: userData['avatar'],
        );
      }
      
      _isLoading = false;
      notifyListeners();
      return _currentUser;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// 📝 REGISTER
  Future<bool> register({
    required String nombre,
    required String apellido,
    required String correo,
    required String password,
    String? telefono,
    String? numeroDocumento,
    String? tipoDocumento,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.register({
        'nombre': nombre,
        'apellido': apellido,
        'correo': correo,
        'password': password,
        'telefono': telefono ?? '',
        'numero_documento': numeroDocumento ?? '',
        'tipo_documento': tipoDocumento ?? 'CC',
      });

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// 🔄 OBTENER PERFIL (requiere estar autenticado)
  Future<User?> getProfile() async {
    try {
      final response = await _authService.getProfile();
      
      if (response != null) {
        _currentUser = User(
          id: response['id_usuario'] ?? response['id'],
          name: response['nombre'] ?? '',
          email: response['correo'] ?? response['email'] ?? '',
          role: _mapRoleFromId(response['id_rol'] ?? 3),
        );
        notifyListeners();
        return _currentUser;
      }
    } catch (e) {
      _errorMessage = e.toString();
    }
    return null;
  }

  /// 🔑 OLVIDÉ CONTRASEÑA
  Future<bool> forgotPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.forgotPassword(email);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// 🔐 RESETEAR CONTRASEÑA
  Future<bool> resetPassword(String token, String newPassword) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.resetPassword(token, newPassword);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// 🚪 LOGOUT
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.logout();
      _currentUser = null;
      _token = null;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// ✅ VERIFICAR AUTENTICACIÓN
  Future<bool> checkAuthentication() async {
    try {
      final isAuth = await _authService.isAuthenticated();
      if (isAuth) {
        await getProfile();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// 🔄 MAPEAR ROL
  String _mapRoleFromId(dynamic roleId) {
    if (roleId == 1) return 'admin';
    if (roleId == 2) return 'employee';
    return 'client';
  }

  /// 🧹 LIMPIAR ERROR
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
