import '../models/barber_appointment.dart';

List<BarberAppointment> mockBarberAppointments = [
  BarberAppointment(
    id: 1,
    clientId: 1,
    barberId: 1,
    date: DateTime.now(),
    hour: "09:00",
    service: "Corte",
    status: "pending",
  ),
  BarberAppointment(
    id: 2,
    clientId: 2,
    barberId: 1,
    date: DateTime.now(),
    hour: "10:00",
    service: "Barba",
    status: "confirmed",
  ),
];
