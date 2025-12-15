import 'package:flutter/material.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_input.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Restablecer contraseña"),
        backgroundColor: Colors.black87,
      ),
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            const SizedBox(height: 20),

            const Text(
              "Ingresa tu correo y enviaremos un enlace para restablecer tu contraseña.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 30),

            CustomInput(
              controller: emailController,
              icon: Icons.email,
              label: "Correo electrónico",
            ),

            const SizedBox(height: 30),

            CustomButton(
              text: "Enviar enlace",
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Enlace enviado (demo)"),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
