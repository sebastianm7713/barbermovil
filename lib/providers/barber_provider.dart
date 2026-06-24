import 'package:flutter/material.dart';
import '../models/barber.dart';
import '../services/barber_service.dart';

class BarberProvider with ChangeNotifier {
  final BarberService _barberService = BarberService();
  List<Barber> barbers = [];
  bool isLoading = false;

  Future<void> fetchBarbers() async {
    isLoading = true;
    notifyListeners();

    try {
      barbers = await _barberService.getBarbers();
    } catch (e) {
      barbers = [];
    }

    isLoading = false;
    notifyListeners();
  }

  Future<bool> createBarber(Barber barber) async {
    try {
      final newBarber = await _barberService.createBarber(barber);
      if (newBarber != null) {
        barbers.add(newBarber);
        notifyListeners();
        return true;
      }
    } catch (e) {
      // Handle error
    }
    return false;
  }

  Future<bool> updateBarber(Barber barber) async {
    try {
      final updatedBarber = await _barberService.updateBarber(barber);
      if (updatedBarber != null) {
        final index = barbers.indexWhere((b) => b.id == barber.id);
        if (index != -1) {
          barbers[index] = updatedBarber;
          notifyListeners();
          return true;
        }
      }
    } catch (e) {
      // Handle error
    }
    return false;
  }
}
