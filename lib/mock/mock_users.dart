import '../models/user.dart';

final mockUsers = [
  User(
    id: 1,
    name: "Admin",
    email: "admin@barber.com",
    password: "1234",
    role: "admin",
  ),
  User(
    id: 2,
    name: "Barbero",
    email: "barbero@barber.com",
    password: "1234",
    role: "employee",
  ),
  User(
    id: 3,
    name: "Cliente",
    email: "cliente@barber.com",
    password: "1234",
    role: "client",
  ),
];
