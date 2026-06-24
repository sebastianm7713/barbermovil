import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:barbers_app/core/app_theme.dart';
import 'package:barbers_app/models/barber_appointment.dart';
import 'package:barbers_app/models/product.dart';
import 'package:barbers_app/models/service.dart';
import 'package:barbers_app/providers/appointment_provider.dart';
import 'package:barbers_app/providers/barber_provider.dart';
import 'package:barbers_app/providers/product_provider.dart';
import 'package:barbers_app/providers/service_provider.dart';
import 'package:barbers_app/providers/user_provider.dart';

class ManageAppointmentsScreen extends StatefulWidget {
  const ManageAppointmentsScreen({super.key});

  @override
  State<ManageAppointmentsScreen> createState() =>
      _ManageAppointmentsScreenState();
}

class _ManageAppointmentsScreenState extends State<ManageAppointmentsScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar citas y datos de referencia al inicializar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appointmentProvider = context.read<AppointmentProvider>();
      appointmentProvider.loadAppointments();

      final barberProvider = context.read<BarberProvider>();
      if (barberProvider.barbers.isEmpty) {
        barberProvider.fetchBarbers();
      }

      final serviceProvider = context.read<ServiceProvider>();
      if (serviceProvider.services.isEmpty) {
        serviceProvider.loadServices();
      }

      final productProvider = context.read<ProductProvider>();
      if (productProvider.products.isEmpty) {
        productProvider.loadProducts();
      }

      final userProvider = context.read<UserProvider>();
      if (userProvider.users.isEmpty) {
        userProvider.loadUsers();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text("Citas"),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.add),
        onPressed: () => _openForm(),
      ),
      body: Consumer<AppointmentProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.appointments.isEmpty) {
            return const Center(
              child: Text("No hay citas registradas"),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadAppointments(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.appointments.length,
              itemBuilder: (_, index) {
                final appt = provider.appointments[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 28,
                      backgroundColor: AppTheme.primary.withAlpha((0.1 * 255).round()),
                      backgroundImage: _imageProviderFromUrl(appt.serviceImageUrl),
                      child: appt.serviceImageUrl.isEmpty
                          ? const Icon(Icons.room_service, color: Colors.black54)
                          : null,
                    ),
                    title: Text(
                      appt.service.isNotEmpty ? appt.service : 'Servicio desconocido',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "${DateFormat('dd/MM/yyyy').format(appt.date)} · ${appt.hour}",
                        ),
                        const SizedBox(height: 4),
                        Text("Barbero ID: ${appt.barberId} · Cliente ID: ${appt.clientId}"),
                        const SizedBox(height: 4),
                        Text("Estado: ${appt.status}"),
                        if (appt.products.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          const Text(
                            'Productos:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          ...appt.products.map(
                            (product) => Text(
                              '${product.name} x${product.quantity} - \$${product.unitPrice}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ],
                    ),
                    trailing: Wrap(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _openForm(edit: appt),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteAppointment(appt.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  ImageProvider? _imageProviderFromUrl(String imageUrl) {
    if (imageUrl.isEmpty) return null;
    if (imageUrl.startsWith('data:')) {
      try {
        final commaIndex = imageUrl.indexOf(',');
        final base64Data = commaIndex != -1 ? imageUrl.substring(commaIndex + 1) : '';
        final bytes = base64Decode(base64Data);
        return MemoryImage(bytes);
      } catch (_) {
        return null;
      }
    }
    return NetworkImage(imageUrl);
  }

  /// 🧾 FORM CREAR / EDITAR
  Future<void> _openForm({BarberAppointment? edit}) async {
    final barberProvider = Provider.of<BarberProvider>(context, listen: false);
    final serviceProvider = Provider.of<ServiceProvider>(context, listen: false);
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (barberProvider.barbers.isEmpty) {
      await barberProvider.fetchBarbers();
    }
    if (serviceProvider.services.isEmpty) {
      await serviceProvider.loadServices();
    }
    if (productProvider.products.isEmpty) {
      await productProvider.loadProducts();
    }
    if (userProvider.users.isEmpty) {
      await userProvider.loadUsers();
    }

    DateTime selectedDate = edit?.date ?? DateTime.now();
    String selectedHour = edit?.hour ?? '';
    int? selectedBarberId = edit?.barberId;
    int? selectedClientId = edit?.clientId;
    Service selectedService;
    List<AppointmentProduct> selectedProducts = edit?.products ?? [];
    List<String> availableHours = edit != null && edit.hour.isNotEmpty ? [edit.hour] : [];
    bool isLoadingHours = false;
    String? availabilityError;

    final servicesList = serviceProvider.services;
    if (servicesList.isNotEmpty) {
      selectedService = servicesList.firstWhere(
        (s) => s.name == edit?.service,
        orElse: () => servicesList.first,
      );
    } else {
      selectedService = Service(
        id: 0,
        name: 'Sin servicio',
        price: 0,
        imageUrl: '',
        assetImage: '',
        description: '',
        duration: 0,
      );
    }

    Future<void> loadAvailabilityHours(void Function(void Function()) dialogSetState) async {
      if (selectedBarberId == null) return;
      dialogSetState(() {
        isLoadingHours = true;
        availableHours = [];
        availabilityError = null;
      });
      try {
        final dateString = DateFormat('yyyy-MM-dd').format(selectedDate);
        final hours = await Provider.of<AppointmentProvider>(context, listen: false)
            .getAvailableHours(selectedBarberId!, dateString);
        dialogSetState(() {
          availableHours = hours;
          if (selectedHour.isNotEmpty && !availableHours.contains(selectedHour)) {
            selectedHour = '';
          }
          if (availableHours.isEmpty) {
            availabilityError = 'No hay horarios disponibles para este barbero en esta fecha.';
          }
        });
      } catch (e) {
        dialogSetState(() {
          availabilityError = 'Error al consultar disponibilidad: $e';
        });
      } finally {
        dialogSetState(() {
          isLoadingHours = false;
        });
      }
    }

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setModal) {
          final currentBarberProvider = Provider.of<BarberProvider>(context);
          final currentServiceProvider = Provider.of<ServiceProvider>(context);
          final currentProductProvider = Provider.of<ProductProvider>(context);
          final currentUserProvider = Provider.of<UserProvider>(context);

          final availableBarbers = currentBarberProvider.barbers;
          final availableServices = currentServiceProvider.services;
          final availableClients = currentUserProvider.users.where((user) => user.role == 'client').toList();
          final availableProducts = currentProductProvider.products;

          return AlertDialog(
            title: Text(edit == null ? "Nueva cita" : "Editar cita"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// 📅 FECHA
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.calendar_month),
                    title: Text(
                      DateFormat('dd/MM/yyyy').format(selectedDate),
                    ),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) {
                        setModal(() {
                          selectedDate = picked;
                          selectedHour = '';
                          availableHours = [];
                          availabilityError = null;
                        });
                      }
                    },
                  ),

                  const SizedBox(height: 12),

                  /// 💈 BARBERO
                  if (currentBarberProvider.isLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    DropdownButtonFormField<int>(
                      isExpanded: true,
                      initialValue: selectedBarberId,
                      decoration: const InputDecoration(
                        labelText: "Barbero",
                        border: OutlineInputBorder(),
                      ),
                      hint: const Text('Selecciona un barbero'),
                      items: availableBarbers.isNotEmpty
                          ? availableBarbers
                              .map(
                                (barber) => DropdownMenuItem<int>(
                                  value: barber.id,
                                  child: Text(barber.name),
                                ),
                              )
                              .toList()
                          : [
                              const DropdownMenuItem<int>(
                                value: null,
                                child: Text('No se encontraron barberos'),
                              ),
                            ],
                      onChanged: (v) {
                        setModal(() {
                          selectedBarberId = v;
                          selectedHour = '';
                          availableHours = [];
                          availabilityError = null;
                        });
                      },
                    ),

                  const SizedBox(height: 12),

                  /// 👤 CLIENTE
                  DropdownButtonFormField<int>(
                    isExpanded: true,
                    initialValue: selectedClientId,
                    decoration: const InputDecoration(
                      labelText: "Cliente",
                      border: OutlineInputBorder(),
                    ),
                    items: availableClients.isNotEmpty
                        ? availableClients
                            .map(
                              (client) => DropdownMenuItem<int>(
                                value: client.id,
                                child: Text(client.name),
                              ),
                            )
                            .toList()
                        : [
                            const DropdownMenuItem<int>(
                              value: null,
                              child: Text('No se encontraron clientes'),
                            ),
                          ],
                    onChanged: (v) => setModal(() => selectedClientId = v),
                  ),

                  const SizedBox(height: 12),

                  /// ✂️ SERVICIO
                  DropdownButtonFormField<Service>(
                    isExpanded: true,
                    initialValue: selectedService,
                    decoration: const InputDecoration(
                      labelText: "Servicio",
                      border: OutlineInputBorder(),
                    ),
                    items: availableServices
                        .map(
                          (s) => DropdownMenuItem<Service>(
                            value: s,
                            child: Text(
                              s.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setModal(() => selectedService = v!),
                  ),

                  const SizedBox(height: 16),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Productos adicionales',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (selectedProducts.isEmpty)
                    const Text('No se han agregado productos.')
                  else
                    Column(
                      children: selectedProducts.map((product) {
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(product.name),
                          subtitle: Text('Cantidad: ${product.quantity}'),
                          trailing: Text('\$${product.unitPrice.toStringAsFixed(2)}'),
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => _openProductSelector(
                      setModal,
                      availableProducts,
                      selectedProducts,
                    ),
                    child: const Text('Agregar/editar productos'),
                  ),

                  const SizedBox(height: 16),

                  /// ⏰ HORARIOS
                  if (isLoadingHours)
                    const Center(child: CircularProgressIndicator())
                  else if (selectedBarberId == null)
                    const Text('Selecciona primero un barbero para ver horarios disponibles.')
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Hora',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        if (availableHours.isEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(availabilityError ?? 'Presiona el botón para cargar horas disponibles.'),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () => loadAvailabilityHours(setModal),
                                child: const Text('Buscar horarios disponibles'),
                              ),
                            ],
                          )
                        else
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: availableHours.map((hour) {
                              final isSelected = selectedHour == hour;
                              return ChoiceChip(
                                label: Text(hour),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setModal(() {
                                    if (selected) {
                                      selectedHour = hour;
                                    }
                                  });
                                },
                                selectedColor: AppTheme.primary,
                                labelStyle: TextStyle(
                                  color: isSelected ? Colors.white : Colors.black87,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              );
                            }).toList(),
                          ),
                      ],
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
                onPressed: () async {
                  if (selectedBarberId == null || selectedClientId == null || selectedService.id == 0 || selectedHour.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Completa todos los campos antes de guardar.')),
                    );
                    return;
                  }

                  final appointment = edit != null
                      ? BarberAppointment(
                          id: edit.id,
                          clientId: selectedClientId!,
                          barberId: selectedBarberId!,
                          serviceId: selectedService.id,
                          date: selectedDate,
                          hour: selectedHour,
                          service: selectedService.name,
                          serviceImageUrl: edit.serviceImageUrl,
                          status: edit.status,
                          products: selectedProducts,
                        )
                      : BarberAppointment.create(
                          clientId: selectedClientId!,
                          barberId: selectedBarberId!,
                          serviceId: selectedService.id,
                          date: selectedDate,
                          hour: selectedHour,
                          service: selectedService.name,
                          products: selectedProducts,
                        );

                  final success = edit == null
                      ? await context.read<AppointmentProvider>().createAppointment(appointment)
                      : await context.read<AppointmentProvider>().updateAppointment(edit.id, appointment);

                  if (!mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success
                          ? (edit == null ? "Cita creada exitosamente" : "Cita actualizada exitosamente")
                          : "Error al ${edit == null ? 'crear' : 'actualizar'} la cita"),
                    ),
                  );

                  if (success) {
                    Navigator.pop(context);
                  }
                },
                child: const Text("Guardar"),
              ),
            ],
          );
        },
      ),
    );
  }

  void _openProductSelector(
    void Function(void Function()) dialogSetState,
    List<Product> products,
    List<AppointmentProduct> selectedProducts,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            void updateProductQuantity(Product product, int quantity) {
              setSheetState(() {
                final index = selectedProducts.indexWhere((p) => p.id == product.id);
                if (quantity <= 0) {
                  if (index != -1) {
                    selectedProducts.removeAt(index);
                  }
                } else if (index != -1) {
                  selectedProducts[index] = AppointmentProduct(
                    id: product.id,
                    name: product.name,
                    quantity: quantity,
                    unitPrice: product.price,
                  );
                } else {
                  selectedProducts.add(AppointmentProduct(
                    id: product.id,
                    name: product.name,
                    quantity: quantity,
                    unitPrice: product.price,
                  ));
                }
              });
              dialogSetState(() {});
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Selecciona productos',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  if (products.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text('No hay productos disponibles.'),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        final selectedIndex = selectedProducts.indexWhere((p) => p.id == product.id);
                        final quantity = selectedIndex != -1 ? selectedProducts[selectedIndex].quantity : 0;
                        return ListTile(
                          title: Text(product.name),
                          subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
                          trailing: quantity > 0
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle_outline),
                                      onPressed: () => updateProductQuantity(product, quantity - 1),
                                    ),
                                    Text(quantity.toString()),
                                    IconButton(
                                      icon: const Icon(Icons.add_circle_outline),
                                      onPressed: () => updateProductQuantity(product, quantity + 1),
                                    ),
                                  ],
                                )
                              : IconButton(
                                  icon: const Icon(Icons.add_circle_outline),
                                  onPressed: () => updateProductQuantity(product, 1),
                                ),
                        );
                      },
                    ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cerrar'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// 🗑️ ELIMINAR CITA
  void _deleteAppointment(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Eliminar cita"),
        content: const Text("¿Estás seguro de que quieres eliminar esta cita?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Eliminar"),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await context.read<AppointmentProvider>().deleteAppointment(id);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? "Cita eliminada exitosamente" : "Error al eliminar la cita"),
        ),
      );
    }
  }
}
