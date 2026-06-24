import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import '../models/barber_appointment.dart';
import '../services/cita_service.dart';

class AppointmentProvider with ChangeNotifier {
  final CitaService _citaService = CitaService();
  List<BarberAppointment> appointments = [];
  bool isLoading = false;

  Future<void> loadAppointments() async {
    isLoading = true;
    notifyListeners();

    try {
      developer.log('AppointmentProvider: Iniciando carga de citas', level: 800);
      appointments = await _citaService.getAllCitas();
      developer.log('AppointmentProvider: ${appointments.length} citas cargadas', level: 800);
    } catch (e) {
      developer.log('AppointmentProvider Error: $e', level: 1000);
      appointments = [];
    }

    isLoading = false;
    notifyListeners();
  }

  Future<bool> createAppointment(BarberAppointment appt) async {
    try {
      final newAppointment = await _citaService.createCita(appt);
      if (newAppointment != null) {
        appointments.add(newAppointment);
        notifyListeners();
        return true;
      }
    } catch (e) {
      // Handle error
    }
    return false;
  }

  Future<bool> updateAppointment(int id, BarberAppointment appt) async {
    try {
      final success = await _citaService.updateCita(id, appt);
      if (success) {
        final index = appointments.indexWhere((a) => a.id == id);
        if (index != -1) {
          appointments[index] = appt;
          notifyListeners();
          return true;
        }
      }
    } catch (e) {
      // Handle error
    }
    return false;
  }

  Future<bool> deleteAppointment(int id) async {
    try {
      final success = await _citaService.deleteCita(id);
      if (success) {
        appointments.removeWhere((a) => a.id == id);
        notifyListeners();
        return true;
      }
    } catch (e) {
      // Handle error
    }
    return false;
  }

  Future<List<String>> getAvailableHours(int barberId, String date) async {
    try {
      return await _citaService.getHorasDisponibles(barberId, date);
    } catch (e) {
      return [];
    }
  }

  Future<List<BarberAppointment>> getAppointmentsByBarber(int barberId) async {
    try {
      // Filter appointments by barber
      return appointments.where((appt) => appt.barberId == barberId).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<BarberAppointment>> getAppointmentsByClient(int clientId) async {
    try {
      // Filter appointments by client
      return appointments.where((appt) => appt.clientId == clientId).toList();
    } catch (e) {
      return [];
    }
  }
}
