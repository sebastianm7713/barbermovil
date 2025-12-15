import 'package:flutter/material.dart';

class BarberAvailabilityProvider extends ChangeNotifier {
  // Días de la semana con disponibilidad
  Map<String, bool> availability = {
    "Lunes": false,
    "Martes": false,
    "Miércoles": false,
    "Jueves": false,
    "Viernes": false,
    "Sábado": false,
    "Domingo": false,
  };

  // Horario de trabajo
  TimeOfDay startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay endTime = const TimeOfDay(hour: 18, minute: 0);

  // Alternar día disponible
  void toggleDay(String day, bool value) {
    availability[day] = value;
    notifyListeners();
  }

  // Cambiar hora de inicio
  void setStartTime(TimeOfDay time) {
    startTime = time;
    notifyListeners();
  }

  // Cambiar hora de fin
  void setEndTime(TimeOfDay time) {
    endTime = time;
    notifyListeners();
  }
}
