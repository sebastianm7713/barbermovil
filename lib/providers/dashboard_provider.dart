import 'package:flutter/material.dart';
import '../services/dashboard_service.dart';

class DashboardProvider extends ChangeNotifier {
  final DashboardService _dashboardService = DashboardService();

  Map<String, dynamic>? _dashboardData;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  Map<String, dynamic>? get dashboardData => _dashboardData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Computed getters para KPIs específicos
  int get totalCitas => _dashboardData?['total_citas'] ?? 0;
  int get citasCompletadas => _dashboardData?['completadas'] ?? 0;
  int get citasPendientes => _dashboardData?['pendientes'] ?? 0;
  int get cantidadVentas => _dashboardData?['cantidad_ventas'] ?? 0;
  double get totalVendido => (_dashboardData?['total_vendido'] ?? 0).toDouble();
  double get gananciaBarberos => (_dashboardData?['ganancia_barberos'] ?? 0).toDouble();
  int get cantidadCompras => _dashboardData?['cantidad_compras'] ?? 0;
  double get totalComprado => (_dashboardData?['total_comprado'] ?? 0).toDouble();

  /// Obtener datos del dashboard del día actual
  Future<void> loadDashboardHoy() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _dashboardService.getDashboardHoy();
      _dashboardData = data;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Limpiar error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Formatear moneda
  String formatCurrency(double value) {
    return '\$${value.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    )}';
  }
}