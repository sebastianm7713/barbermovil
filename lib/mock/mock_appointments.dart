import '../models/appointment.dart';
import '../models/service.dart';
import 'mock_services.dart';

final List<Appointment> mockAppointments = [
  Appointment(
    id: 1,
    clientId: 1,
    barberId: 1,
    date: DateTime.now(),
    hour: "09:00 AM",
    service: mockServices.first,
    status: "pending",
  ),
];
