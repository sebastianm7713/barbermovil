import 'dart:io' show Platform;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:4000/api';
    }
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:4000/api';
    }
    return 'http://localhost:4000/api';
  }
  
  static final ApiService _instance = ApiService._internal();
  
  late Dio _dio;
  late SharedPreferences _prefs;
  bool _initialized = false;

  factory ApiService() {
    return _instance;
  }

  ApiService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ));

    // Agregar interceptor para token usando InterceptorsWrapper compatible con Dio v5
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          try {
            final prefs = await SharedPreferences.getInstance();
            final token = prefs.getString('auth_token');
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
              print('ApiService: Token agregado al header');
            } else {
              print('ApiService: No hay token disponible');
            }
          } catch (e) {
            print('ApiService: Error al obtener token - $e');
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          if (error.response?.statusCode == 401) {
            print('ApiService: Token inválido o expirado (401)');
            SharedPreferences.getInstance().then((prefs) {
              prefs.remove('auth_token');
            });
          }
          return handler.next(error);
        },
      ),
    );
  }

  // ============ AUTH ENDPOINTS ============

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      
      // El backend retorna { success: true, data: { token: "...", user: {...} } }
      final token = response.data['data']?['token'] ?? response.data['token'];
      
      if (token != null && token.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        print('ApiService: Token guardado exitosamente');
      }
      
      return response.data;
    } on DioException catch (e) {
      print('ApiService login error: ${e.response?.statusCode} - ${e.response?.data}');
      throw Exception(e.response?.data['message'] ?? 'Error en login');
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    try {
      final response = await _dio.post('/auth/register', data: userData);
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error en registro');
    }
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await _dio.post(
        '/auth/forgot-password',
        data: {'email': email},
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error al enviar email');
    }
  }

  Future<Map<String, dynamic>> resetPassword(String token, String newPassword) async {
    try {
      final response = await _dio.post(
        '/auth/reset-password',
        data: {'token': token, 'password': newPassword},
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error al resetear contraseña');
    }
  }

  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _dio.get('/auth/profile');
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error al obtener perfil');
    }
  }

  // ============ SERVICIOS ENDPOINTS ============

  Future<List<dynamic>> getServicios() async {
    try {
      final response = await _dio.get('/servicios');
      print('ApiService getServicios response: ${response.data}');
      // Manejar ambas estructuras: array directo o { success, data }
      if (response.data is List) {
        return response.data as List;
      } else if (response.data is Map && response.data['data'] is List) {
        return response.data['data'] as List;
      }
      return [];
    } on DioException catch (e) {
      print('ApiService getServicios error: ${e.response?.statusCode} - ${e.response?.data}');
      throw Exception(e.response?.data['message'] ?? 'Error al obtener servicios');
    }
  }

  Future<Map<String, dynamic>> getServicioById(int id) async {
    try {
      final response = await _dio.get('/servicios/$id');
      // Extraer data si está envuelto en { success, data }
      if (response.data is Map && response.data['data'] is Map) {
        return response.data['data'] as Map<String, dynamic>;
      }
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      print('ApiService getServicioById error: ${e.response?.statusCode} - ${e.response?.data}');
      throw Exception(e.response?.data['message'] ?? 'Error al obtener servicio');
    }
  }

  Future<Map<String, dynamic>> createServicio(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/servicios', data: data);
      // Extraer data si está envuelto en { success, data }
      if (response.data is Map && response.data['data'] is Map) {
        return response.data;
      }
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      print('ApiService createServicio error: ${e.response?.statusCode} - ${e.response?.data}');
      throw Exception(e.response?.data['message'] ?? 'Error al crear servicio');
    }
  }

  Future<Map<String, dynamic>> updateServicio(int id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/servicios/$id', data: data);
      // Extraer data si está envuelto en { success, data }
      if (response.data is Map && response.data['data'] is Map) {
        return response.data;
      }
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      print('ApiService updateServicio error: ${e.response?.statusCode} - ${e.response?.data}');
      throw Exception(e.response?.data['message'] ?? 'Error al actualizar servicio');
    }
  }

  Future<void> deleteServicio(int id) async {
    try {
      await _dio.delete('/servicios/$id');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error al eliminar servicio');
    }
  }

  // ============ CITAS ENDPOINTS ============

  Future<List<dynamic>> getCitas() async {
    try {
      final response = await _dio.get('/citas');
      return response.data is List ? response.data : response.data['data'] ?? [];
    } on DioException catch (e) {
      print('ApiService getCitas Error: ${e.response?.statusCode} - ${e.response?.data}');
      throw Exception(e.response?.data['message'] ?? 'Error al obtener citas');
    }
  }

  Future<List<dynamic>> getVentas() async {
    try {
      final response = await _dio.get('/ventas');
      final responseData = response.data;
      if (responseData is List) {
        return responseData;
      }
      if (responseData is Map<String, dynamic>) {
        if (responseData['data'] is List) {
          return responseData['data'] as List<dynamic>;
        }
        if (responseData['ventas'] is List) {
          return responseData['ventas'] as List<dynamic>;
        }
      }
      return [];
    } on DioException catch (e) {
      print('ApiService getVentas Error: ${e.response?.statusCode} - ${e.response?.data}');
      throw Exception(e.response?.data['message'] ?? 'Error al obtener ventas');
    }
  }

  Future<List<dynamic>> getCompras() async {
    try {
      final response = await _dio.get('/compras');
      final responseData = response.data;
      if (responseData is List) {
        return responseData;
      }
      if (responseData is Map<String, dynamic>) {
        if (responseData['data'] is List) {
          return responseData['data'] as List<dynamic>;
        }
        if (responseData['compras'] is List) {
          return responseData['compras'] as List<dynamic>;
        }
      }
      return [];
    } on DioException catch (e) {
      print('ApiService getCompras Error: ${e.response?.statusCode} - ${e.response?.data}');
      throw Exception(e.response?.data['message'] ?? 'Error al obtener compras');
    }
  }

  Future<Map<String, dynamic>> getCitaById(int id) async {
    try {
      final response = await _dio.get('/citas/$id');
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error al obtener cita');
    }
  }

  Future<Map<String, dynamic>> createCita(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/citas', data: data);
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error al crear cita');
    }
  }

  Future<Map<String, dynamic>> createCitaFromLanding(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/citas/landing', data: data);
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error al crear cita');
    }
  }

  Future<Map<String, dynamic>> updateCita(int id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/citas/$id', data: data);
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error al actualizar cita');
    }
  }

  Future<void> deleteCita(int id) async {
    try {
      await _dio.delete('/citas/$id');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error al eliminar cita');
    }
  }

  Future<List<dynamic>> getHorasDisponibles(int barberoId, String fecha) async {
    try {
      final response = await _dio.get(
        '/citas/disponibilidad/horario',
        queryParameters: {
          'id_barbero': barberoId,
          'fecha': fecha,
        },
      );
      return response.data['data'] ?? [];
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error al obtener horas disponibles');
    }
  }

  // ============ CLIENTES ENDPOINTS ============

  Future<List<dynamic>> getClientes() async {
    try {
      final response = await _dio.get('/clientes');
      return response.data is List ? response.data : response.data['data'] ?? [];
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error al obtener clientes');
    }
  }

  Future<Map<String, dynamic>> getClienteById(int id) async {
    try {
      final response = await _dio.get('/clientes/$id');
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error al obtener cliente');
    }
  }

  Future<Map<String, dynamic>> createCliente(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/clientes', data: data);
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error al crear cliente');
    }
  }

  Future<Map<String, dynamic>> updateCliente(int id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/clientes/$id', data: data);
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error al actualizar cliente');
    }
  }

  Future<void> deleteCliente(int id) async {
    try {
      await _dio.delete('/clientes/$id');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error al eliminar cliente');
    }
  }

  // ============ DASHBOARD ENDPOINTS ============

  Future<Map<String, dynamic>> getDashboardHoy() async {
    try {
      final response = await _dio.get('/dashboard/hoy');
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error al obtener dashboard');
    }
  }

  // ============ USUARIOS ENDPOINTS ============

  Future<List<dynamic>> getUsuarios() async {
    try {
      final response = await _dio.get('/usuarios');
      return response.data is List ? response.data : response.data['data'] ?? [];
    } on DioException catch (e) {
      print('ApiService getUsuarios Error: ${e.response?.statusCode} - ${e.response?.data}');
      throw Exception(e.response?.data['message'] ?? 'Error al obtener usuarios');
    }
  }

  Future<Map<String, dynamic>> getUsuarioById(int id) async {
    try {
      final response = await _dio.get('/usuarios/$id');
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error al obtener usuario');
    }
  }

  Future<Map<String, dynamic>> createUsuario(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/usuarios', data: data);
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error al crear usuario');
    }
  }

  Future<Map<String, dynamic>> updateUsuario(int id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/usuarios/$id', data: data);
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error al actualizar usuario');
    }
  }

  Future<void> deleteUsuario(int id) async {
    try {
      await _dio.delete('/usuarios/$id');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error al eliminar usuario');
    }
  }

  // ============ LOGOUT ============

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }
}
