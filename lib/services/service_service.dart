import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';

import '../models/service.dart';
import 'api_service.dart';

class ServiceService {
  final ApiService _apiService = ApiService();

  /// Obtener todos los servicios
  Future<List<Service>> getAllServices() async {
    try {
      final data = await _apiService.getServicios();
      print('ServiceService getAllServices raw data: $data');
      return (data as List)
          .map((serviceJson) {
            final mapped = _mapBackendToFrontend(serviceJson);
            print('ServiceService mapped service: $mapped');
            return Service.fromJson(mapped);
          })
          .toList();
    } catch (e) {
      print('ServiceService getAllServices error: $e');
      throw Exception('Error al obtener servicios: $e');
    }
  }

  /// Obtener servicio por ID
  Future<Service?> getServiceById(int id) async {
    try {
      final data = await _apiService.getServicioById(id);
      return Service.fromJson(_mapBackendToFrontend(data));
    } catch (e) {
      return null;
    }
  }

  /// Crear servicio
  Future<Service?> createService(Service service) async {
    try {
      final response = await _apiService.createServicio({
        'nombre': service.name,
        'descripcion': service.description,
        'precio': service.price,
        'duracion': service.duration,
        'porcentaje_barbero': 30,
        'imagen': service.imageUrl,
      });

      // Mapear respuesta del backend
      final data = response['data'] ?? response;
      return Service.fromJson(_mapBackendToFrontend(data));
    } catch (e) {
      throw Exception('Error al crear servicio: $e');
    }
  }

  /// Actualizar servicio
  Future<bool> updateService(int id, Service service) async {
    try {
      await _apiService.updateServicio(id, {
        'nombre': service.name,
        'descripcion': service.description,
        'precio': service.price,
        'duracion': service.duration,
        'porcentaje_barbero': 30,
        'imagen': service.imageUrl,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Eliminar servicio
  Future<bool> deleteService(int id) async {
    try {
      await _apiService.deleteServicio(id);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Mapear estructura del backend a estructura del frontend
  Map<String, dynamic> _mapBackendToFrontend(dynamic backendData) {
    if (backendData is Map<String, dynamic>) {
      final rawImage = backendData['img'] ?? backendData['imagen'] ?? backendData['imageUrl'] ?? '';
      final imageUrl = _normalizeImageUrl(rawImage?.toString() ?? '');

      return {
        'id': backendData['id_servicio'] ?? backendData['id'] ?? 0,
        'name': backendData['nombre'] ?? backendData['name'] ?? '',
        'description': backendData['descripcion'] ?? backendData['description'] ?? '',
        'price': backendData['precio'] ?? backendData['price'] ?? 0,
        'duration': backendData['duracion'] ?? backendData['duration'] ?? 30,
        'imageUrl': imageUrl,
      };
    }
    return {};
  }

  String _normalizeImageUrl(String imageUrl) {
    final trimmed = imageUrl.trim();
    if (trimmed.isEmpty) return '';
    if (trimmed.startsWith('data:')) {
      return trimmed;
    }
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    if (trimmed.startsWith('//')) {
      return 'http:$trimmed';
    }
    final host = _backendHost;
    if (trimmed.startsWith('/')) {
      return '$host$trimmed';
    }
    return '$host/$trimmed';
  }

  String get _backendHost {
    if (kIsWeb) {
      return 'http://localhost:4000';
    }
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:4000';
    }
    return 'http://localhost:4000';
  }
}