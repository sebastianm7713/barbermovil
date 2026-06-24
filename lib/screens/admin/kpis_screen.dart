import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/dashboard_provider.dart';
import '../../core/app_theme.dart';

class KpisScreen extends StatefulWidget {
  const KpisScreen({super.key});

  @override
  State<KpisScreen> createState() => _KpisScreenState();
}

class _KpisScreenState extends State<KpisScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar datos del dashboard al inicializar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().loadDashboardHoy();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Indicadores (KPIs)'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Consumer<DashboardProvider>(
        builder: (context, dashboardProvider, child) {
          if (dashboardProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (dashboardProvider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error al cargar KPIs',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    dashboardProvider.errorMessage!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => dashboardProvider.loadDashboardHoy(),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => dashboardProvider.loadDashboardHoy(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  _buildKpiCard(
                    title: 'Citas Totales Hoy',
                    value: dashboardProvider.totalCitas.toString(),
                    icon: Icons.calendar_today,
                    color: Colors.blue,
                  ),
                  _buildKpiCard(
                    title: 'Citas Completadas',
                    value: dashboardProvider.citasCompletadas.toString(),
                    icon: Icons.check_circle,
                    color: Colors.green,
                  ),
                  _buildKpiCard(
                    title: 'Citas Pendientes',
                    value: dashboardProvider.citasPendientes.toString(),
                    icon: Icons.schedule,
                    color: Colors.orange,
                  ),
                  _buildKpiCard(
                    title: 'Ventas del Día',
                    value: dashboardProvider.cantidadVentas.toString(),
                    icon: Icons.shopping_cart,
                    color: Colors.purple,
                  ),
                  _buildKpiCard(
                    title: 'Ingresos del Día',
                    value: dashboardProvider.formatCurrency(dashboardProvider.totalVendido),
                    icon: Icons.monetization_on,
                    color: Colors.green,
                  ),
                  _buildKpiCard(
                    title: 'Compras del Día',
                    value: dashboardProvider.cantidadCompras.toString(),
                    icon: Icons.shopping_bag,
                    color: Colors.redAccent,
                  ),
                  _buildKpiCard(
                    title: 'Gastos del Día',
                    value: dashboardProvider.formatCurrency(dashboardProvider.totalComprado),
                    icon: Icons.receipt_long,
                    color: Colors.orange,
                  ),
                  _buildKpiCard(
                    title: 'Ganancia Barberos',
                    value: dashboardProvider.formatCurrency(dashboardProvider.gananciaBarberos),
                    icon: Icons.account_balance_wallet,
                    color: Colors.teal,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
