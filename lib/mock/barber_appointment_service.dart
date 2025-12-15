import '../models/barber_appointment.dart';
import '../mock/mock_barber_appointments.dart';

class BarberAppointmentService {
  // Obtener citas filtradas por barberId y fecha
  Future<List<BarberAppointment>> getAppointmentsByBarberAndDate(int barberId, DateTime date) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return mockBarberAppointments.where((a) =>
      a.barberId == barberId &&
      a.date.year == date.year &&
      a.date.month == date.month &&
      a.date.day == date.day
    ).toList();
  }

  // Crear cita nueva
  Future<BarberAppointment?> createAppointment(BarberAppointment appointment) async {
    await Future.delayed(const Duration(milliseconds: 300));
    mockBarberAppointments.add(appointment);
    return appointment;
  }

  // Actualizar estado de cita
  Future<bool> updateStatus(int id, String status) async {
    final index = mockBarberAppointments.indexWhere((a) => a.id == id);
    if (index != -1) {
      mockBarberAppointments[index].status = status;
      return true;
    }
    return false;
  }

  // Eliminar cita
  Future<bool> deleteAppointment(int id) async {
    final index = mockBarberAppointments.indexWhere((a) => a.id == id);
    if (index != -1) {
      mockBarberAppointments.removeAt(index);
      return true;
    }
    return false;
  }
}
