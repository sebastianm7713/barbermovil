import 'dart:developer' as developer;
import 'api_service.dart';
import 'cita_service.dart';

class DashboardService {
  final ApiService _apiService = ApiService();
  final CitaService _citaService = CitaService();

  /// Obtener KPIs del día actual
  Future<Map<String, dynamic>> getDashboardHoy() async {
    try {
      final now = DateTime.now();
      final ventas = await _apiService.getVentas();
      final compras = await _apiService.getCompras();
      final citas = await _citaService.getAllCitas();

      developer.log('DashboardService: ventas count=${ventas.length} compras count=${compras.length} citas count=${citas.length}');
      if (ventas.isNotEmpty) {
        developer.log('DashboardService: primera venta keys=${(ventas.first as Map).keys.toList()}');
      }
      if (compras.isNotEmpty) {
        developer.log('DashboardService: primera compra keys=${(compras.first as Map).keys.toList()}');
      }

      final ventasHoy = ventas.where((venta) {
        final fechaVentas = _getDate(venta, [
          'fecha',
          'fecha_venta',
          'fechaVenta',
          'created_at',
          'createdAt',
          'fechaCreacion',
        ]);
        return fechaVentas != null && _sameDay(fechaVentas, now);
      }).toList();

      final comprasHoy = compras.where((compra) {
        final fechaCompra = _getDate(compra, [
          'fecha_compra',
          'fechaCompra',
          'fecha',
          'created_at',
          'createdAt',
          'fechaCreacion',
        ]);
        return fechaCompra != null && _sameDay(fechaCompra, now);
      }).toList();

      final citasHoy = citas.where((cita) => _sameDay(cita.date, now)).toList();

      final ventasSource = ventasHoy.isEmpty ? ventas : ventasHoy;
      final comprasSource = comprasHoy.isEmpty ? compras : comprasHoy;
      final ventasCount = ventasHoy.isEmpty ? ventas.length : ventasHoy.length;
      final comprasCount = comprasHoy.isEmpty ? compras.length : comprasHoy.length;

      final totalVendido = ventasSource.fold<double>(0, (sum, venta) {
        return sum + _getDouble(venta, [
          'total',
          'total_venta',
          'valor_total',
          'monto',
        ]);
      });

      final gananciaBarberos = ventasSource.fold<double>(0, (sum, venta) {
        final servicios = venta['servicios'] as List<dynamic>?;
        if (servicios == null) return sum;
        return sum + servicios.fold<double>(0, (innerSum, servicio) {
          return innerSum + _getDouble(servicio, [
            'ganancia_barbero',
            'gananciaBarbero',
            'profit',
          ]);
        });
      });

      final totalComprado = comprasSource.fold<double>(0, (sum, compra) {
        return sum + _getDouble(compra, [
          'total',
          'total_compra',
          'valor_total',
          'monto',
        ]);
      });

      final completadas = citasHoy.where((cita) {
        final status = cita.status.toLowerCase();
        return status == 'completed' || status == 'completado';
      }).length;

      final pendientes = citasHoy.where((cita) {
        final status = cita.status.toLowerCase();
        return status == 'pending' || status == 'pendiente' || status == 'por confirmar';
      }).length;

      final dashboard = {
        'total_citas': citasHoy.length,
        'completadas': completadas,
        'pendientes': pendientes,
        'cantidad_ventas': ventasCount,
        'total_vendido': totalVendido,
        'ganancia_barberos': gananciaBarberos,
        'cantidad_compras': comprasCount,
        'total_comprado': totalComprado,
      };

      developer.log('DashboardService: ventasHoy=${ventasHoy.length} comprasHoy=${comprasHoy.length} citasHoy=${citasHoy.length} totalVendido=$totalVendido totalComprado=$totalComprado gananciaBarberos=$gananciaBarberos');

      if (dashboard.values.every((value) => value == 0)) {
        final fallback = await _apiService.getDashboardHoy();
        developer.log('DashboardService: fallback dashboard=$fallback');
        if (fallback.isNotEmpty) {
          return fallback;
        }
      }

      return dashboard;
    } catch (e) {
      throw Exception('Error al obtener dashboard: $e');
    }
  }

  bool _sameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  DateTime? _getDate(dynamic item, List<String> keys) {
    if (item is! Map) return null;
    for (final key in keys) {
      final value = item[key];
      final parsed = _parseDate(value);
      if (parsed != null) return parsed;
    }
    return null;
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    if (value is double) {
      return DateTime.fromMillisecondsSinceEpoch(value.toInt());
    }
    try {
      return DateTime.parse(value.toString());
    } catch (_) {
      return null;
    }
  }

  double _getDouble(dynamic item, List<String> keys) {
    if (item is! Map) return 0;
    for (final key in keys) {
      final value = item[key];
      final parsed = _toDouble(value);
      if (parsed != 0) return parsed;
    }
    return 0;
  }

  double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }
}