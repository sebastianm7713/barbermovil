import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/api.dart';
import '../models/barber_appointment.dart';

class BarberAppointmentService {
  /// Obtener citas de un barbero en una fecha específica
  Future<List<BarberAppointment>> getAppointmentsByBarberAndDate(int barberId, DateTime date) async {
    final response = await http.get(
      Uri.parse('${Api.baseUrl}/citas?id_barbero=$barberId'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        final List appointments = data['data'] as List;
        
        return appointments
            .where((apt) {
              try {
                final aptDate = DateTime.parse(apt['fecha'] ?? apt['fecha_cita']);
                return apt['id_barbero'] == barberId &&
                    aptDate.year == date.year &&
                    aptDate.month == date.month &&
                    aptDate.day == date.day;
              } catch (e) {
                return false;
              }
            })
            .map((apt) => BarberAppointment.fromJson({
              'id': apt['id_cita'],
              'barberId': apt['id_barbero'],
              'clientId': apt['id_cliente'],
              'serviceId': apt['id_servicio'],
              'date': DateTime.parse(apt['fecha'] ?? apt['fecha_cita']),
              'hour': apt['hora'] ?? apt['hora_cita'],
              'service': 'Servicio ${apt['id_servicio']}', // Placeholder, should fetch service name
              'status': apt['estado'],
            }))
            .toList();
      }
    }
    return [];
  }

  /// Crear cita (barbero)
  Future<BarberAppointment?> createAppointment(BarberAppointment appointment) async {
    final response = await http.post(
      Uri.parse('${Api.baseUrl}/citas'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'id_cliente': appointment.clientId,
        'id_barbero': appointment.barberId,
        'id_servicio': appointment.serviceId,
        'fecha_cita': appointment.date.toIso8601String().split('T')[0],
        'hora_cita': appointment.hour,
        'estado': appointment.status ?? 'confirmada',
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        return BarberAppointment.fromJson({
          'id': data['data']['id_cita'],
          'barberId': data['data']['id_barbero'],
          'clientId': data['data']['id_cliente'],
          'serviceId': data['data']['id_servicio'],
          'date': DateTime.parse(data['data']['fecha'] ?? data['data']['fecha_cita']),
          'hour': data['data']['hora'] ?? data['data']['hora_cita'],
          'status': data['data']['estado'],
        });
      }
    }
    return null;
  }

  /// Eliminar cita (barbero)
  Future<bool> deleteAppointment(int id) async {
    final response = await http.delete(Uri.parse('${Api.baseUrl}/citas/$id'));
    return response.statusCode == 200;
  }
}
