import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/api.dart';
import '../models/appointment.dart';

class AppointmentService {
  /// Obtener todas las citas
  Future<List<Appointment>> getAllAppointments() async {
    final response = await http.get(Uri.parse('/citas'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        return (data['data'] as List).map((appointmentJson) => Appointment.fromJson({
          'id': appointmentJson['id_cita'],
          'clientId': appointmentJson['id_cliente'],
          'barberId': appointmentJson['id_barbero'],
          'serviceId': appointmentJson['id_servicio'],
          'date': DateTime.parse(appointmentJson['fecha'] ?? appointmentJson['fecha_cita']),
          'hour': appointmentJson['hora'] ?? appointmentJson['hora_cita'],
          'status': appointmentJson['estado'],
          'products': appointmentJson['productos'] ?? [],
        })).toList();
      }
    }
    return [];
  }

  /// Crear cita
  Future<Appointment?> createAppointment(Appointment appointment) async {
    final response = await http.post(
      Uri.parse('/citas'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'id_cliente': appointment.clientId,
        'id_barbero': appointment.barberId,
        'id_servicio': appointment.serviceId,
        'fecha_cita': appointment.date.toIso8601String().split('T')[0],
        'hora_cita': appointment.hour,
        'estado': appointment.status ?? 'pendiente',
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        return Appointment.fromJson({
          'id': data['data']['id_cita'],
          'clientId': data['data']['id_cliente'],
          'barberId': data['data']['id_barbero'],
          'serviceId': data['data']['id_servicio'],
          'date': DateTime.parse(data['data']['fecha_cita']),
          'hour': data['data']['hora_cita'],
          'status': data['data']['estado'],
          'products': data['data']['productos'] ?? [],
        });
      }
    }
    return null;
  }

  /// Actualizar cita
  Future<bool> updateAppointment(int id, Appointment appointment) async {
    final response = await http.put(
      Uri.parse('/citas/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'id_cliente': appointment.clientId,
        'id_barbero': appointment.barberId,
        'id_servicio': appointment.serviceId,
        'fecha_cita': appointment.date.toIso8601String().split('T')[0],
        'hora_cita': appointment.hour,
        'estado': appointment.status,
      }),
    );

    return response.statusCode == 200;
  }

  /// Eliminar cita
  Future<bool> deleteAppointment(int id) async {
    final response = await http.delete(Uri.parse('/citas/'));
    return response.statusCode == 200;
  }

  /// Obtener citas por barbero
  Future<List<Appointment>> getAppointmentsByBarber(int barberId) async {
    final allAppointments = await getAllAppointments();
    return allAppointments.where((appointment) => appointment.barberId == barberId).toList();
  }

  /// Obtener citas por cliente
  Future<List<Appointment>> getAppointmentsByClient(int clientId) async {
    final allAppointments = await getAllAppointments();
    return allAppointments.where((appointment) => appointment.clientId == clientId).toList();
  }
}
