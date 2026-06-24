import 'package:flutter/material.dart';
import '../models/service.dart';
import '../services/service_service.dart';

class ServiceProvider with ChangeNotifier {
  final ServiceService _serviceService = ServiceService();
  List<Service> services = [];
  bool isLoading = false;

  Future<void> loadServices() async {
    isLoading = true;
    notifyListeners();

    try {
      services = await _serviceService.getAllServices();
      print('ServiceProvider loadServices success: ${services.length} servicios cargados');
    } catch (e) {
      print('ServiceProvider loadServices error: $e');
      services = [];
    }

    isLoading = false;
    notifyListeners();
  }

  Future<Service?> getServiceById(int id) async {
    try {
      return await _serviceService.getServiceById(id);
    } catch (e) {
      return null;
    }
  }

  Future<bool> createService(Service service) async {
    try {
      final newService = await _serviceService.createService(service);
      if (newService != null) {
        services.add(newService);
        notifyListeners();
        return true;
      }
    } catch (e) {
      // Handle error
    }
    return false;
  }

  Future<bool> updateService(int id, Service service) async {
    try {
      final success = await _serviceService.updateService(id, service);
      if (success) {
        final index = services.indexWhere((s) => s.id == id);
        if (index != -1) {
          services[index] = service;
          notifyListeners();
          return true;
        }
      }
    } catch (e) {
      // Handle error
    }
    return false;
  }

  Future<bool> deleteService(int id) async {
    try {
      final success = await _serviceService.deleteService(id);
      if (success) {
        services.removeWhere((s) => s.id == id);
        notifyListeners();
        return true;
      }
    } catch (e) {
      // Handle error
    }
    return false;
  }
}