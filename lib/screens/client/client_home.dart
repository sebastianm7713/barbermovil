import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/custom_button.dart';

class ClientHome extends StatelessWidget {
  const ClientHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Inicio - Cliente"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Bienvenido",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            const Text(
              "Aquí podrás ver productos, reservar citas y más.",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),

            const SizedBox(height: 30),

            CustomButton(
              text: "Ver Catálogo",
              onPressed: () {
                context.push("/client/catalog");
              },
            ),

            const SizedBox(height: 15),

            CustomButton(
              text: "Reservar Cita",
              onPressed: () {
                context.push("/client/book");
              },
            ),

            const SizedBox(height: 15),

            CustomButton(
              text: "Cerrar Sesión",
              isPrimary: false,
              onPressed: () {
                context.go("/login");
              },
            ),
          ],
        ),
      ),
    );
  }
}
