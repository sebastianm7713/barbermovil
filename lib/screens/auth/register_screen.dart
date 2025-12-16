import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_theme.dart';
import '../../models/user.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text("Crear cuenta")),
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: "Nombre")),
            TextField(controller: emailController, decoration: const InputDecoration(labelText: "Correo")),
            TextField(controller: passwordController, obscureText: true, decoration: const InputDecoration(labelText: "Contraseña")),
            TextField(controller: confirmPasswordController, obscureText: true, decoration: const InputDecoration(labelText: "Confirmar contraseña")),
            const SizedBox(height: 25),

            ElevatedButton(
              onPressed: () {
                if (passwordController.text != confirmPasswordController.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Las contraseñas no coinciden")),
                  );
                  return;
                }

                final newUser = User(
                  id: DateTime.now().millisecondsSinceEpoch,
                  name: nameController.text.trim(),
                  email: emailController.text.trim(),
                  password: passwordController.text.trim(),
                  role: "client", // 👈 por defecto
                );

                authProvider.register(newUser);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Usuario registrado correctamente")),
                );

                Navigator.pop(context); // vuelve al login
              },
              child: const Text("Registrarme"),
            ),
          ],
        ),
      ),
    );
  }
}
