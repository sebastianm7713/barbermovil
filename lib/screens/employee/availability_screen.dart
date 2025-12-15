import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/custom_button.dart';
import '../../providers/barber_availability_provider.dart';

class AvailabilityScreen extends StatefulWidget {
  const AvailabilityScreen({super.key});

  @override
  State<AvailabilityScreen> createState() => _AvailabilityScreenState();
}

class _AvailabilityScreenState extends State<AvailabilityScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BarberAvailabilityProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Disponibilidad"),
        backgroundColor: Colors.black87,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Días Disponibles",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            ...provider.availability.keys.map((day) {
              return SwitchListTile(
                title: Text(day),
                value: provider.availability[day]!,
                onChanged: (value) => provider.toggleDay(day, value),
              );
            }).toList(),
            const SizedBox(height: 25),
            const Text(
              "Horario",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text("Hora de inicio"),
              subtitle: Text("${provider.startTime.hour}:${provider.startTime.minute.toString().padLeft(2, '0')}"),
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: provider.startTime,
                );
                if (picked != null) provider.setStartTime(picked);
              },
            ),
            ListTile(
              leading: const Icon(Icons.access_time_filled),
              title: const Text("Hora de finalización"),
              subtitle: Text("${provider.endTime.hour}:${provider.endTime.minute.toString().padLeft(2, '0')}"),
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: provider.endTime,
                );
                if (picked != null) provider.setEndTime(picked);
              },
            ),
            const SizedBox(height: 30),
            CustomButton(
              text: "Guardar Disponibilidad",
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Disponibilidad guardada"),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
