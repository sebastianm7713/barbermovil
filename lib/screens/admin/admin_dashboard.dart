import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../../core/app_theme.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text("Panel Administrador"),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authProvider.logout();
              context.go("/login");
            },
          )
        ],
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(20),
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        children: [
          _menuCard(
            context,
            title: "Usuarios",
            icon: Icons.group,
            route: "/admin/users",
          ),
          _menuCard(
            context,
            title: "Productos",
            icon: Icons.shopping_bag,
            route: "/admin/products",
          ),
          _menuCard(
            context,
            title: "Citas",
            icon: Icons.calendar_month,
            route: "/admin/appointments",
          ),
          _menuCard(
            context,
            title: "KPIs",
            icon: Icons.bar_chart,
            route: "/admin/kpis",
          ),
          _menuCard(
            context,
            title: "Servicios",
            icon: Icons.content_cut,
            route: "/admin/services",
          ),

        ],
      ),
    );
  }

  Widget _menuCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String route,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => context.go(route),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: AppTheme.primary.withOpacity(0.15),
              child: Icon(icon, size: 32, color: AppTheme.primary),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.darkText,
              ),
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }
}
