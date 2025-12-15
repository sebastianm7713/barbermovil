import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/barber.dart';

class BarberService {
  final String baseUrl = "http://localhost:3000/api/barbers";

  /// ✔ Obtener todos los barberos
  Future<List<Barber>> getBarbers() async {
    final res = await http.get(Uri.parse(baseUrl));

    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((b) => Barber.fromJson(b)).toList();
    } else {
      throw Exception("Error obteniendo barberos");
    }
  }

  /// ✔ Crear barbero
  Future<Barber> createBarber(Barber barber) async {
    final res = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(barber.toJson()),
    );

    if (res.statusCode == 201) {
      return Barber.fromJson(jsonDecode(res.body));
    } else {
      throw Exception("Error creando barbero");
    }
  }

  /// ✔ Actualizar barbero
  Future<Barber> updateBarber(Barber barber) async {
    final res = await http.put(
      Uri.parse("$baseUrl/${barber.id}"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(barber.toJson()),
    );

    if (res.statusCode == 200) {
      return Barber.fromJson(jsonDecode(res.body));
    } else {
      throw Exception("Error actualizando barbero");
    }
  }

  /// ✔ Eliminar barbero
  Future<bool> deleteBarber(int id) async {
    final res = await http.delete(
      Uri.parse("$baseUrl/$id"),
    );

    return res.statusCode == 200;
  }
}
