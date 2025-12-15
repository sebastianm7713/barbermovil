import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

// Providers
import 'providers/auth_provider.dart';
import 'providers/product_provider.dart';
import 'providers/appointment_provider.dart';
import 'providers/barber_provider.dart';
import 'providers/user_provider.dart';

// Screens
import 'screens/auth/login_screen.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/employee/employee_home.dart';
import 'screens/client/client_home.dart';

void main() {
  runApp(const BarberSiteApp());
}

class BarberSiteApp extends StatelessWidget {
  const BarberSiteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => AppointmentProvider()),
        ChangeNotifierProvider(create: (_) => BarberProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          final GoRouter _router = GoRouter(
            initialLocation: '/login',
            refreshListenable: authProvider,
            redirect: (BuildContext context, GoRouterState state) {
              final loggedIn = authProvider.isLoggedIn;
              final role = authProvider.user?.role;

              // No logueado → ir a login
              if (!loggedIn && state.uri.path != '/login') return '/login';

              // Logueado y está en login → redirigir según rol
              if (loggedIn && state.uri.path == '/login') {
                if (role == 'admin') return '/admin/dashboard';
                if (role == 'employee') return '/employee/home';
                if (role == 'client') return '/client/home';
              }

              return null;
            },
            routes: [
              GoRoute(
                path: '/login',
                builder: (context, state) => const LoginScreen(),
              ),
              GoRoute(
                path: '/admin/dashboard',
                builder: (context, state) => const AdminDashboard(),
              ),
              GoRoute(
                path: '/employee/home',
                builder: (context, state) => const EmployeeHome(),
              ),
              GoRoute(
                path: '/client/home',
                builder: (context, state) => const ClientHome(),
              ),
            ],
          );

          return MaterialApp.router(
            title: 'BarberSite',
            debugShowCheckedModeBanner: false,
            theme: ThemeData.light(),
            routerConfig: _router,
          );
        },
      ),
    );
  }
}
