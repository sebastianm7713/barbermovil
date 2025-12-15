import 'package:flutter/material.dart';
import '../models/barber.dart';
import '../mock/mock_barbers.dart';

class BarberProvider with ChangeNotifier {
  List<Barber> barbers = [];
  bool isLoading = false;

  Future<void> fetchBarbers() async {
    isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));
    barbers = mockBarbers;

    isLoading = false;
    notifyListeners();
  }
}
