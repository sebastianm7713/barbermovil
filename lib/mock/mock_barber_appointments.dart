import '../models/barber_appointment.dart';

List<BarberAppointment> mockBarberAppointments = [
  BarberAppointment(
    id: 1,
    clientId: 1,
    barberId: 1,
    serviceId: 1,
    date: DateTime.now(),
    hour: "09:00",
    service: "Corte",
    serviceImageUrl: '',
    status: "pending",
    products: const [],
  ),
  BarberAppointment(
    id: 2,
    clientId: 2,
    barberId: 1,
    serviceId: 2,
    date: DateTime.now(),
    hour: "10:00",
    service: "Barba",
    serviceImageUrl: '',
    status: "confirmed",
    products: const [],
  ),
];
