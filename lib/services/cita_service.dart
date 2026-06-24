import 'dart:developer' as developer;
import '../models/barber_appointment.dart';
import 'api_service.dart';

class CitaService {
  final ApiService _apiService = ApiService();

  /// Obtener todas las citas
  Future<List<BarberAppointment>> getAllCitas() async {
    try {
      developer.log('CitaService: Llamando a getCitas()', level: 800);
      final data = await _apiService.getCitas();
      developer.log('CitaService: Respuesta recibida: ${data.runtimeType}', level: 800);
      return (data as List)
          .map((citaJson) => BarberAppointment.fromJson(
                _mapBackendToFrontend(citaJson),
              ))
          .toList();
    } catch (e) {
      developer.log('CitaService Error: $e', level: 1000);
      throw Exception('Error al obtener citas: $e');
    }
  }

  /// Obtener cita por ID
  Future<BarberAppointment?> getCitaById(int id) async {
    try {
      final data = await _apiService.getCitaById(id);
      return BarberAppointment.fromJson(_mapBackendToFrontend(data));
    } catch (e) {
      return null;
    }
  }

  /// Crear cita
  Future<BarberAppointment?> createCita(BarberAppointment cita) async {
    try {
      final requestData = {
        'id_cliente': cita.clientId,
        'id_barbero': cita.barberId,
        'id_servicio': cita.serviceId,
        'fecha': cita.date.toIso8601String(),
        'hora': cita.hour,
        'estado': cita.status,
      };
      if (cita.products.isNotEmpty) {
        requestData['productos'] = cita.products
            .map((product) => {
                  'id_producto': product.id,
                  'cantidad': product.quantity,
                  'precio_unitario': product.unitPrice,
                })
            .toList();
      }
      final response = await _apiService.createCita(requestData);

      final data = response['data'] ?? response;
      return BarberAppointment.fromJson(_mapBackendToFrontend(data));
    } catch (e) {
      throw Exception('Error al crear cita: $e');
    }
  }

  /// Crear cita desde landing (sin autenticación)
  Future<BarberAppointment?> createCitaFromLanding(BarberAppointment cita) async {
    try {
      final requestData = {
        'id_cliente': cita.clientId,
        'id_barbero': cita.barberId,
        'id_servicio': cita.serviceId,
        'fecha': cita.date.toIso8601String(),
        'hora': cita.hour,
        'estado': cita.status,
      };
      if (cita.products.isNotEmpty) {
        requestData['productos'] = cita.products
            .map((product) => {
                  'id_producto': product.id,
                  'cantidad': product.quantity,
                  'precio_unitario': product.unitPrice,
                })
            .toList();
      }
      final response = await _apiService.createCitaFromLanding(requestData);

      final data = response['data'] ?? response;
      return BarberAppointment.fromJson(_mapBackendToFrontend(data));
    } catch (e) {
      throw Exception('Error al crear cita: $e');
    }
  }

  /// Actualizar cita
  Future<bool> updateCita(int id, BarberAppointment cita) async {
    try {
      final requestData = {
        'id_cliente': cita.clientId,
        'id_barbero': cita.barberId,
        'id_servicio': cita.serviceId,
        'fecha': cita.date.toIso8601String(),
        'hora': cita.hour,
        'estado': cita.status,
      };
      if (cita.products.isNotEmpty) {
        requestData['productos'] = cita.products
            .map((product) => {
                  'id_producto': product.id,
                  'cantidad': product.quantity,
                  'precio_unitario': product.unitPrice,
                })
            .toList();
      }
      await _apiService.updateCita(id, requestData);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Eliminar cita
  Future<bool> deleteCita(int id) async {
    try {
      await _apiService.deleteCita(id);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Obtener horas disponibles
  Future<List<String>> getHorasDisponibles(int barberoId, String fecha) async {
    try {
      final data = await _apiService.getHorasDisponibles(barberoId, fecha);
      return (data as List).map((h) => h.toString()).toList();
    } catch (e) {
      throw Exception('Error al obtener horas disponibles: $e');
    }
  }

  /// Mapear estructura del backend
  Map<String, dynamic> _mapBackendToFrontend(dynamic backendData) {
    if (backendData is Map<String, dynamic>) {
      return {
        'id': backendData['id_cita'] ?? backendData['id'] ?? 0,
        'clientId': backendData['id_cliente'] ?? backendData['clientId'] ?? 0,
        'barberId': backendData['id_barbero'] ?? backendData['barberId'] ?? 0,
        'serviceId': backendData['id_servicio'] ?? backendData['serviceId'] ?? 0,
        'date': backendData['fecha'] ?? DateTime.now(),
        'hour': backendData['hora'] ?? backendData['hour'] ?? '',
        'service': backendData['servicio_nombre'] ?? backendData['nombre_servicio'] ?? backendData['service'] ?? '',
        'serviceImageUrl': _normalizeImageUrl(
          backendData['imagen'] ?? backendData['imageUrl'] ?? backendData['img'] ?? '',
        ),
        'status': backendData['estado'] ?? backendData['status'] ?? 'pending',
        'productos': backendData['productos'] ?? backendData['products'] ?? [],
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
    return trimmed;
  }
}
