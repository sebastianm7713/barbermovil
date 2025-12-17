import 'package:flutter/material.dart';
import '../../widgets/profile_tab_widget.dart';

/// Pantalla de perfil y configuración de usuario (Cliente)
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProfileTabWidget(
      // Usa el color primario del tema para el cliente
      primaryColor: null, // Usará Theme.of(context).primaryColor
    );
  }
}
