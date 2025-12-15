import 'package:flutter/material.dart';
import '../models/barber_appointment.dart';
import '../services/barber_appointment_service.dart';

class BarberAppointmentProvider extends ChangeNotifier {
  final BarberAppointmentService _service = BarberAppointmentService();

  List<BarberAppointment> appointments = [];
  bool isLoading = false;

  Future<void> loadAppointments(int barberId, DateTime date) async {
    isLoading = true;
    notifyListeners();

    appointments = await _service.getAppointmentsByBarberAndDate(barberId, date);

    isLoading = false;
    notifyListeners();
  }

  Future<void> addAppointment(BarberAppointment appointment) async {
    await _service.createAppointment(appointment);
    appointments.add(appointment);
    notifyListeners();
  }

  Future<void> editAppointment(BarberAppointment appointment) async {
    final index = appointments.indexWhere((a) => a.id == appointment.id);
    if (index != -1) {
      appointments[index] = appointment;
      notifyListeners();
    }
  }

  Future<void> deleteAppointment(int id) async {
    final success = await _service.deleteAppointment(id);
    if (success) {
      appointments.removeWhere((a) => a.id == id);
      notifyListeners();
    }
  }
}
