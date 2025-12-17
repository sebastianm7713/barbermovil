import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/app_routes.dart';

import 'providers/auth_provider.dart';
import 'providers/product_provider.dart';
import 'providers/appointment_provider.dart';
import 'providers/barber_provider.dart';
import 'providers/user_provider.dart';
import 'providers/barber_availability_provider.dart';
import 'providers/barber_appointment_provider.dart'; // 👈 SI EXISTE

import 'core/app_theme.dart'; // Add import

void main() {
  runApp(const BarberSiteApp());
}

class BarberSiteApp extends StatelessWidget {
  const BarberSiteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [

        /// 🔐 AUTH
        ChangeNotifierProvider(create: (_) => AuthProvider()),

        /// 🧑‍💼 ADMIN
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => AppointmentProvider()),
        ChangeNotifierProvider(create: (_) => BarberProvider()),

        /// 💈 BARBERO
        ChangeNotifierProvider(create: (_) => BarberAvailabilityProvider()),
        ChangeNotifierProvider(create: (_) => BarberAppointmentProvider()),

      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'BarberSite',
        routerConfig: appRouter,
        theme: AppTheme.lightTheme, // Use custom theme
      ),
    );
  }
}
