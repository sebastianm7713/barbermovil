import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/appointment_provider.dart';
import '../../providers/barber_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/loading_widget.dart';
import '../../models/appointment.dart';

class BookAppointmentScreen extends StatefulWidget {
  const BookAppointmentScreen({super.key});

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  int? selectedBarberId;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  String? selectedService;

  final List<String> services = [
    "Corte",
    "Barba",
    "Corte + Barba",
    "Cejas",
    "Coloración"
  ];

  @override
  void initState() {
    super.initState();
    final barberProvider = Provider.of<BarberProvider>(context, listen: false);

    /// 🔥 tu provider NO tenía loadBarbers()
    /// Se llama fetchBarbers()
    barberProvider.fetchBarbers();
  }

  @override
  Widget build(BuildContext context) {
    final barberProvider = Provider.of<BarberProvider>(context);
    final appointmentProvider = Provider.of<AppointmentProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Reservar Cita"),
        backgroundColor: Colors.black87,
      ),
      body: barberProvider.isLoading
          ? const LoadingWidget()
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ---------- BARBERO ----------
                  const Text(
                    "Selecciona un barbero",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  DropdownButtonFormField<int>(
                    hint: const Text("Barbero disponible"),
                    value: selectedBarberId,
                    items: barberProvider.barbers.map((barber) {
                      return DropdownMenuItem(
                        value: barber.id,
                        child: Text(barber.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => selectedBarberId = value);
                    },
                  ),

                  const SizedBox(height: 25),

                  // ---------- SERVICIO ----------
                  const Text(
                    "Selecciona el servicio",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  DropdownButtonFormField<String>(
                    hint: const Text("Servicio"),
                    value: selectedService,
                    items: services.map((service) {
                      return DropdownMenuItem(
                        value: service,
                        child: Text(service),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => selectedService = value);
                    },
                  ),

                  const SizedBox(height: 25),

                  // ---------- FECHA ----------
                  const Text(
                    "Selecciona la fecha",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  CustomButton(
                    text: selectedDate == null
                        ? "Elegir fecha"
                        : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                    onPressed: pickDate,
                  ),

                  const SizedBox(height: 25),

                  // ---------- HORA ----------
                  const Text(
                    "Selecciona la hora",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  CustomButton(
                    text: selectedTime == null
                        ? "Elegir hora"
                        : "${selectedTime!.hour}:${selectedTime!.minute.toString().padLeft(2, '0')}",
                    onPressed: pickTime,
                  ),

                  const Spacer(),

                  // ---------- BOTÓN FINAL ----------
                  CustomButton(
                    text: "Reservar Cita",
                    onPressed: () async {
                      if (selectedBarberId == null ||
                          selectedDate == null ||
                          selectedTime == null ||
                          selectedService == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Completa todos los campos")),
                        );
                        return;
                      }

                      // Construir FULL DATETIME
                      final fullDate = DateTime(
                        selectedDate!.year,
                        selectedDate!.month,
                        selectedDate!.day,
                        selectedTime!.hour,
                        selectedTime!.minute,
                      );

                      final newAppointment = Appointment(
                        id: 0,
                        clientId: 999, // reemplaza por ID real del cliente logueado
                        barberId: selectedBarberId!,
                        date: fullDate,
                        hour:
                            "${selectedTime!.hour}:${selectedTime!.minute.toString().padLeft(2, '0')}",
                        service: selectedService!,
                        status: "pending",
                      );

                      final ok =
                          await appointmentProvider.createAppointment(newAppointment);

                      if (!mounted) return;

                      if (ok) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Cita registrada exitosamente")),
                        );
                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Error al registrar la cita")),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
    );
  }

  // ---------- FUNCIONES ----------

  Future<void> pickDate() async {
    DateTime now = DateTime.now();
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() => selectedDate = date);
    }
  }

  Future<void> pickTime() async {
    final TimeOfDay? time =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());

    if (time != null) {
      setState(() => selectedTime = time);
    }
  }
}
