import '../models/appointment.dart';

List<Appointment> mockAppointments = [
  Appointment(
    id: 1,
    clientId: 1,
    barberId: 1,
    date: DateTime.now().add(const Duration(days: 1)),
    hour: "10:00",
    service: "Corte",
    status: "pending",
  ),
];
