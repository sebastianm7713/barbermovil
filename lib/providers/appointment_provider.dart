import 'package:flutter/material.dart';
import '../models/appointment.dart';
import '../mock/mock_appointments.dart';

class AppointmentProvider with ChangeNotifier {
  List<Appointment> appointments = mockAppointments;

  Future<bool> createAppointment(Appointment appt) async {
    appointments.add(appt);
    notifyListeners();
    return true; // siempre OK en mocks
  }
}
