import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/app_theme.dart';
import '../../models/barber_appointment.dart';
import '../../providers/appointment_provider.dart';
import 'modify_appointment_screen.dart';

/// Pantalla para gestionar citas pasadas y futuras
class MyAppointmentsScreen extends StatefulWidget {
  const MyAppointmentsScreen({super.key});

  @override
  State<MyAppointmentsScreen> createState() => _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState extends State<MyAppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<AppointmentProvider>(context, listen: false);
      if (!provider.isLoading && provider.appointments.isEmpty) {
        provider.loadAppointments();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Citas'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Próximas', icon: Icon(Icons.upcoming)),
            Tab(text: 'Historial', icon: Icon(Icons.history)),
          ],
        ),
      ),
      body: Consumer<AppointmentProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final upcoming = provider.appointments.where((appointment) {
            return appointment.status == 'pendiente' ||
                appointment.status == 'pending' ||
                appointment.status == 'confirmada' ||
                appointment.status == 'confirmed' ||
                appointment.status == 'en_ejecucion';
          }).toList();

          final past = provider.appointments.where((appointment) {
            return appointment.status == 'completado' ||
                appointment.status == 'completed' ||
                appointment.status == 'cancelado' ||
                appointment.status == 'cancelled';
          }).toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildAppointmentList(
                upcoming,
                emptyTitle: 'No tienes citas programadas',
                emptySubtitle: '¡Reserva tu próxima cita ahora!',
              ),
              _buildAppointmentList(
                past,
                emptyTitle: 'No tienes historial de citas',
                emptySubtitle: 'Tus citas pasadas aparecerán aquí',
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppointmentList(List<BarberAppointment> appointments,
      {required String emptyTitle, required String emptySubtitle}) {
    if (appointments.isEmpty) {
      return _buildEmptyState(
        icon: Icons.event_available,
        title: emptyTitle,
        subtitle: emptySubtitle,
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await Provider.of<AppointmentProvider>(context, listen: false)
            .loadAppointments();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: appointments.length,
        itemBuilder: (context, index) {
          final appointment = appointments[index];
          return _buildAppointmentCard(appointment);
        },
      ),
    );
  }

  Widget _buildAppointmentCard(BarberAppointment appointment) {
    final date = appointment.date;
    final status = appointment.status;

    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (status) {
      case 'confirmada':
      case 'confirmed':
        statusColor = Colors.green;
        statusText = 'Confirmada';
        statusIcon = Icons.check_circle;
        break;
      case 'pendiente':
      case 'pending':
        statusColor = Colors.orange;
        statusText = 'Pendiente';
        statusIcon = Icons.schedule;
        break;
      case 'completado':
      case 'completed':
        statusColor = Colors.blue;
        statusText = 'Completada';
        statusIcon = Icons.done_all;
        break;
      case 'cancelado':
      case 'cancelled':
        statusColor = Colors.red;
        statusText = 'Cancelada';
        statusIcon = Icons.cancel;
        break;
      case 'en_ejecucion':
        statusColor = Colors.purple;
        statusText = 'En ejecución';
        statusIcon = Icons.play_circle;
        break;
      default:
        statusColor = Colors.grey;
        statusText = 'Desconocido';
        statusIcon = Icons.help;
    }

    final appointmentMap = {
      'id': appointment.id,
      'service': appointment.service,
      'barber': 'Barbero ${appointment.barberId}',
      'date': appointment.date,
      'time': appointment.hour,
      'status': appointment.status,
    };

    final isUpcoming = appointment.status == 'pendiente' ||
        appointment.status == 'pending' ||
        appointment.status == 'confirmada' ||
        appointment.status == 'confirmed' ||
        appointment.status == 'en_ejecucion';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(statusIcon, color: statusColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointment.service.isNotEmpty
                      ? appointment.service
                      : 'Servicio desconocido',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${DateFormat('dd/MM/yyyy').format(date)} · ${appointment.hour}',
                ),
                const SizedBox(height: 8),
                Text('Barbero: ${appointment.barberId}'),
                const SizedBox(height: 4),
                if (appointment.products.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'Productos:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  ...appointment.products.map(
                    (product) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '${product.name} x${product.quantity} - \$${product.unitPrice}',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ),
                ],
                if (appointment.products.isEmpty) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'Sin productos adicionales',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
                if (isUpcoming && status != 'cancelado' && status != 'cancelled') ...[
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _modifyAppointment(appointment),
                          icon: const Icon(Icons.edit, size: 18),
                          label: const Text('Modificar'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.primary,
                            side: const BorderSide(color: AppTheme.primary),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _cancelAppointment(appointment),
                          icon: const Icon(Icons.cancel, size: 18),
                          label: const Text('Cancelar'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                if (!isUpcoming &&
                    (status == 'completed' || status == 'completado')) ...[
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _rateAppointment(appointment),
                      icon: const Icon(Icons.star, size: 18),
                      label: const Text('Dejar Reseña'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 100,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _modifyAppointment(BarberAppointment appointment) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ModifyAppointmentScreen(appointment: appointment),
      ),
    );

    if (result != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cita actualizada exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _cancelAppointment(BarberAppointment appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 12),
            Text('Cancelar Cita'),
          ],
        ),
        content: Text(
          '¿Estás seguro de que deseas cancelar tu cita de ${appointment.service} '
          'el ${DateFormat('dd/MM/yyyy').format(appointment.date)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () async {
              final provider =
                  Provider.of<AppointmentProvider>(context, listen: false);
              await provider.deleteAppointment(appointment.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cita cancelada'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sí, Cancelar'),
          ),
        ],
      ),
    );
  }

  void _rateAppointment(BarberAppointment appointment) {
    int rating = 0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Calificar Servicio'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '¿Cómo fue tu experiencia con el barbero ${appointment.barberId}?',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      onPressed: () {
                        setDialogState(() {
                          rating = index + 1;
                        });
                      },
                      icon: Icon(
                        index < rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 40,
                      ),
                    );
                  }),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: rating > 0
                    ? () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Gracias por tu calificación de $rating estrellas'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Enviar'),
              ),
            ],
          );
        },
      ),
    );
  }
}
