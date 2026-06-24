import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  /// Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _apiService.login(email, password);
      
      // Extraer datos desde data wrapper o raíz
      final tokenData = response['data'] ?? response;
      
      // Guardar datos del usuario
      if (tokenData['token'] != null) {
        final prefs = await SharedPreferences.getInstance();
        final userData = tokenData['user'] ?? tokenData;
        await prefs.setString('user_email', userData['email'] ?? email);
        await prefs.setString('user_id', (userData['id_usuario'] ?? userData['id'])?.toString() ?? '');
        await prefs.setString('user_role', (userData['id_rol'] ?? userData['rol'])?.toString() ?? '');
      }
      
      return tokenData;
    } catch (e) {
      throw Exception('Error en login: $e');
    }
  }

  /// Registro
  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    try {
      final response = await _apiService.register({
        'nombre': userData['nombre'] ?? '',
        'apellido': userData['apellido'] ?? '',
        'correo': userData['correo'] ?? '',
        'password': userData['password'] ?? '',
        'telefono': userData['telefono'] ?? '',
        'numero_documento': userData['numero_documento'] ?? '',
        'tipo_documento': userData['tipo_documento'] ?? 'CC',
      });
      
      return response;
    } catch (e) {
      throw Exception('Error en registro: $e');
    }
  }

  /// Olvidé contraseña
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await _apiService.forgotPassword(email);
      return response;
    } catch (e) {
      throw Exception('Error al enviar email: $e');
    }
  }

  /// Resetear contraseña
  Future<Map<String, dynamic>> resetPassword(
    String token,
    String newPassword,
  ) async {
    try {
      final response = await _apiService.resetPassword(token, newPassword);
      return response;
    } catch (e) {
      throw Exception('Error al resetear contraseña: $e');
    }
  }

  /// Obtener perfil
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _apiService.getProfile();
      return response;
    } catch (e) {
      throw Exception('Error al obtener perfil: $e');
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_email');
      await prefs.remove('user_id');
      await prefs.remove('user_role');
      await _apiService.logout();
    } catch (e) {
      throw Exception('Error al cerrar sesión: $e');
    }
  }

  /// Obtener token guardado
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  /// Obtener email del usuario logueado
  Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_email');
  }

  /// Obtener ID del usuario logueado
  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }

  /// Obtener rol del usuario
  Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_role');
  }

  /// Verificar si usuario está autenticado
  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
