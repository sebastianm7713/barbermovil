import 'dart:convert';
import 'package:http/http.dart' as http;

import '../core/api.dart';
import '../models/barber.dart';

class BarberService {
  /// ✔ Obtener todos los barberos
  Future<List<Barber>> getBarbers() async {
    final res = await http.get(Uri.parse('${Api.barbers}/public'));

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      if (data['success'] == true) {
        final List barberData = data['data'];
        return barberData.map((b) => Barber.fromJson({
          'id': b['id_barbero'],
          'name': b['nombre'],
          'specialty': b['especialidad'],
          'phone': b['telefono'],
          'email': b['email'],
          'status': b['estado'] == 1 ? 'active' : 'inactive',
        })).toList();
      }
    }
    return [];
  }

  /// ✔ Crear barbero
  Future<Barber> createBarber(Barber barber) async {
    final res = await http.post(
      Uri.parse('${Api.baseUrl}/barberos'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        'nombre': barber.name,
        'especialidad': barber.specialty,
        'telefono': barber.phone,
        'email': barber.email,
        'estado': barber.status == 'active' ? 1 : 0,
      }),
    );

    if (res.statusCode == 201) {
      final data = jsonDecode(res.body);
      if (data['success'] == true) {
        return Barber.fromJson({
          'id': data['data']['id_barbero'],
          'name': data['data']['nombre'],
          'specialty': data['data']['especialidad'],
          'phone': data['data']['telefono'],
          'email': data['data']['email'],
          'status': data['data']['estado'] == 1 ? 'active' : 'inactive',
        });
      }
    }
    throw Exception("Error creando barbero");
  }

  /// ✔ Actualizar barbero
  Future<Barber> updateBarber(Barber barber) async {
    final res = await http.put(
      Uri.parse("${Api.baseUrl}/barberos/${barber.id}"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        'nombre': barber.name,
        'especialidad': barber.specialty,
        'telefono': barber.phone,
        'email': barber.email,
        'estado': barber.status == 'active' ? 1 : 0,
      }),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      if (data['success'] == true) {
        return Barber.fromJson({
          'id': data['data']['id_barbero'],
          'name': data['data']['nombre'],
          'specialty': data['data']['especialidad'],
          'phone': data['data']['telefono'],
          'email': data['data']['email'],
          'status': data['data']['estado'] == 1 ? 'active' : 'inactive',
        });
      }
    }
    throw Exception("Error actualizando barbero");
  }

  /// ✔ Eliminar barbero
  Future<bool> deleteBarber(int id) async {
    final res = await http.delete(
      Uri.parse('${Api.baseUrl}/barberos/$id'),
    );

    return res.statusCode == 200;
  }
}
