import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/barber_appointment_provider.dart';
import '../../mock/mock_barber_clients.dart';
import '../../mock/mock_services.dart';
import '../../widgets/loading_widget.dart';
import '../../models/barber_appointment.dart';
import '../../models/service.dart';
import '../../core/app_theme.dart';


class EmployeeAgendaScreen extends StatefulWidget {
  const EmployeeAgendaScreen({super.key});

  @override
  State<EmployeeAgendaScreen> createState() => _EmployeeAgendaScreenState();
}

class _EmployeeAgendaScreenState extends State<EmployeeAgendaScreen> {
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  void _loadAppointments() {
    final provider =
        Provider.of<BarberAppointmentProvider>(context, listen: false);
    provider.loadAppointments(1, selectedDate);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BarberAppointmentProvider>(context);
    final appointments = provider.appointments;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Agenda del Día"),
        backgroundColor: AppTheme.primary,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.add),
        onPressed: _openAddAppointmentForm,
      ),
      body: Column(
        children: [
          const SizedBox(height: 15),
          _dateSelector(),
          const SizedBox(height: 15),
          if (provider.isLoading)
            const Expanded(child: LoadingWidget()),
          if (!provider.isLoading)
            Expanded(
              child: appointments.isEmpty
                  ? const Center(
                      child: Text(
                        "No tienes citas asignadas hoy.",
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                    )
                  : ListView.builder(
                      itemCount: appointments.length,
                      itemBuilder: (context, index) {
                        final a = appointments[index];
                        final client = mockBarberClients
                            .firstWhere((c) => c.id == a.clientId);
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 8),
                          child: ListTile(
                            leading: const Icon(Icons.person),
                            title: Text(client.name),
                            subtitle: Text(
                                "Hora: ${a.hour}\nServicio: ${a.service}\nEstado: ${a.status}"),
                            isThreeLine: true,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => _openEditAppointmentForm(a),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    provider.deleteAppointment(a.id);
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
        ],
      ),
    );
  }

  Widget _dateSelector() {
    return GestureDetector(
      onTap: () async {
        final newDate = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime(2020),
          lastDate: DateTime(2035),
        );
        if (newDate != null) {
          setState(() => selectedDate = newDate);
          _loadAppointments();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: AppTheme.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: Colors.white),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
            const Icon(Icons.edit_calendar, color: Colors.white),
          ],
        ),
      ),
    );
  }

  void _openAddAppointmentForm() => _openAppointmentForm();

  void _openEditAppointmentForm(BarberAppointment appointment) =>
      _openAppointmentForm(appointment: appointment);

  void _openAppointmentForm({BarberAppointment? appointment}) {
    int? selectedClientId = appointment?.clientId;
    Service? selectedService = appointment != null
        ? mockServices.firstWhere((s) => s.name == appointment.service)
        : null;

    TimeOfDay selectedTime = appointment != null
        ? TimeOfDay(
            hour: int.parse(appointment.hour.split(":")[0]),
            minute: int.parse(appointment.hour.split(":")[1]),
          )
        : const TimeOfDay(hour: 9, minute: 0);

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setModal) {
          return AlertDialog(
            title: Text(appointment == null ? "Nueva Cita" : "Editar Cita"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Cliente
                  DropdownButtonFormField<int>(
                    value: selectedClientId,
                    items: mockBarberClients
                        .map((c) => DropdownMenuItem(
                              value: c.id,
                              child: Text(c.name),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setModal(() => selectedClientId = value);
                    },
                    decoration:
                        const InputDecoration(labelText: "Selecciona Cliente"),
                  ),
                  const SizedBox(height: 10),
                  // Servicio
                  DropdownButtonFormField<Service>(
                    value: selectedService,
                    items: mockServices
                        .map((s) => DropdownMenuItem(
                              value: s,
                              child: Text(s.name),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setModal(() => selectedService = value);
                    },
                    decoration:
                        const InputDecoration(labelText: "Selecciona Servicio"),
                  ),
                  const SizedBox(height: 10),
                  // Hora
                  GestureDetector(
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: selectedTime,
                      );
                      if (picked != null) setModal(() => selectedTime = picked);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Hora: ${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancelar"),
              ),
              ElevatedButton(
                onPressed: () {
                  if (selectedClientId == null || selectedService == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Completa todos los campos")),
                    );
                    return;
                  }

                  final provider =
                      Provider.of<BarberAppointmentProvider>(context, listen: false);

                  final newAppointment = BarberAppointment(
                    id: appointment?.id ?? DateTime.now().millisecondsSinceEpoch,
                    clientId: selectedClientId!,
                    barberId: 1,
                    date: selectedDate,
                    hour:
                        "${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}",
                    service: selectedService!.name,
                    status: appointment?.status ?? "pending",
                  );

                  if (appointment == null) {
                    provider.addAppointment(newAppointment);
                  } else {
                    provider.editAppointment(newAppointment);
                  }

                  Navigator.pop(context);
                },
                child: Text(appointment == null ? "Agregar" : "Guardar"),
              ),
            ],
          );
        },
      ),
    );
  }
}
