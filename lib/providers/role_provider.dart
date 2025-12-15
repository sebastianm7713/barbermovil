import 'package:flutter/material.dart';
import '../models/roles.dart';
import '../services/role_service.dart';

class RoleProvider with ChangeNotifier {
  final RoleService _roleService = RoleService();

  List<Role> _roles = [];
  bool _isLoading = false;

  List<Role> get roles => _roles;
  bool get isLoading => _isLoading;

  /// 📌 Cargar roles
  Future<void> fetchRoles() async {
    try {
      _isLoading = true;
      notifyListeners();

      final data = await _roleService.getRoles();
      _roles = data;
    } catch (e) {
      print('Error cargando roles: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 📌 Crear rol
  Future<void> createRole(Role role) async {
    try {
      final newRole = await _roleService.createRole(role);
      _roles.add(newRole);
      notifyListeners();
    } catch (e) {
      print('Error creando rol: $e');
    }
  }

  /// 📌 Eliminar rol
  Future<void> deleteRole(int id) async {
    try {
      await _roleService.deleteRole(id);
      _roles.removeWhere((r) => r.id == id);
      notifyListeners();
    } catch (e) {
      print('Error eliminando rol: $e');
    }
  }

  /// 📌 Actualizar rol
  Future<void> updateRole(Role role) async {
    try {
      final updated = await _roleService.updateRole(role);
      final index = _roles.indexWhere((r) => r.id == role.id);

      if (index != -1) {
        _roles[index] = updated;
        notifyListeners();
      }
    } catch (e) {
      print('Error actualizando rol: $e');
    }
  }
}
