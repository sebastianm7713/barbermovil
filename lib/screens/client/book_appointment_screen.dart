import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/barber_appointment.dart';
import '../../models/product.dart';
import '../../models/service.dart';
import '../../providers/appointment_provider.dart';
import '../../providers/barber_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/loading_widget.dart';
import '../../mock/mock_services.dart';

class BookAppointmentScreen extends StatefulWidget {
  const BookAppointmentScreen({super.key});

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  int? selectedBarberId;
  DateTime? selectedDate;
  String? selectedTime;
  Service? selectedService;
  bool _isLoadingHours = false;
  List<String> availableHours = [];
  String? availabilityError;
  List<AppointmentProduct> selectedProducts = [];

  @override
  void initState() {
    super.initState();
    Provider.of<BarberProvider>(context, listen: false).fetchBarbers();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      if (productProvider.products.isEmpty) {
        productProvider.loadProducts();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final barberProvider = Provider.of<BarberProvider>(context);
    final appointmentProvider = Provider.of<AppointmentProvider>(context);
    final productProvider = Provider.of<ProductProvider>(context);

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
                  const Text(
                    "Selecciona un barbero",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<int>(
                    value: selectedBarberId,
                    hint: const Text("Barbero disponible"),
                    items: barberProvider.barbers.map((barber) {
                      return DropdownMenuItem(
                        value: barber.id,
                        child: Text(barber.name),
                      );
                    }).toList(),
                    onChanged: (value) async {
                      setState(() {
                        selectedBarberId = value;
                        selectedTime = null;
                        availableHours = [];
                        availabilityError = null;
                      });
                      await _loadAvailableHours();
                    },
                  ),

                  const SizedBox(height: 25),
                  const Text(
                    "Selecciona el servicio",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<Service>(
                    value: selectedService,
                    hint: const Text("Servicio"),
                    items: mockServices.map((service) {
                      return DropdownMenuItem<Service>(
                        value: service,
                        child: Text(service.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => selectedService = value);
                    },
                  ),

                  const SizedBox(height: 25),
                  const Text(
                    "Selecciona la fecha",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  CustomButton(
                    text: selectedDate == null
                        ? "Elegir fecha"
                        : DateFormat('dd/MM/yyyy').format(selectedDate!),
                    onPressed: () async {
                      final now = DateTime.now();
                      final date = await showDatePicker(
                        context: context,
                        initialDate: now,
                        firstDate: now,
                        lastDate: now.add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setState(() {
                          selectedDate = date;
                          selectedTime = null;
                          availableHours = [];
                          availabilityError = null;
                        });
                        await _loadAvailableHours();
                      }
                    },
                  ),

                  const SizedBox(height: 25),
                  const Text(
                    "Selecciona la hora",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  if (_isLoadingHours)
                    const Center(child: CircularProgressIndicator())
                  else if (selectedBarberId == null || selectedDate == null)
                    const Text('Selecciona barbero y fecha para ver horarios disponibles.')
                  else if (availableHours.isEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(availabilityError ?? 'No hay horarios disponibles para ese día.'),
                        const SizedBox(height: 12),
                        CustomButton(
                          text: 'Buscar horarios disponibles',
                          onPressed: _loadAvailableHours,
                        ),
                      ],
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: availableHours.map((hour) {
                        final isSelected = hour == selectedTime;
                        return ChoiceChip(
                          label: Text(hour),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => selectedTime = hour);
                            }
                          },
                          selectedColor: Colors.black87,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        );
                      }).toList(),
                    ),

                  const SizedBox(height: 25),
                  const Text(
                    "Productos adicionales",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  if (selectedProducts.isNotEmpty)
                    Column(
                      children: selectedProducts.map((product) {
                        return ListTile(
                          dense: true,
                          title: Text(product.name),
                          subtitle: Text('Cantidad: ${product.quantity}'),
                          trailing: Text('\$${product.unitPrice.toStringAsFixed(2)}'),
                        );
                      }).toList(),
                    )
                  else
                    const Text('No se han agregado productos.'),
                  const SizedBox(height: 12),
                  CustomButton(
                    text: 'Agregar productos',
                    onPressed: () => _openProductSelector(productProvider.products),
                  ),

                  const Spacer(),
                  CustomButton(
                    text: "Reservar Cita",
                    onPressed: () async {
                      if (selectedBarberId == null ||
                          selectedDate == null ||
                          selectedTime == null ||
                          selectedService == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Completa todos los campos"),
                          ),
                        );
                        return;
                      }

                      final dateParts = selectedTime!.split(':');
                      final appointmentDate = DateTime(
                        selectedDate!.year,
                        selectedDate!.month,
                        selectedDate!.day,
                        int.parse(dateParts[0]),
                        int.parse(dateParts[1]),
                      );

                      final appointment = BarberAppointment.create(
                        clientId: 999,
                        barberId: selectedBarberId!,
                        serviceId: selectedService!.id,
                        date: appointmentDate,
                        hour: selectedTime!,
                        service: selectedService!.name,
                        serviceImageUrl: selectedService!.imageUrl,
                        products: selectedProducts,
                        status: 'pending',
                      );

                      final ok = await appointmentProvider.createAppointment(appointment);

                      if (!mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(ok
                              ? "Cita registrada exitosamente"
                              : "Error al registrar la cita"),
                        ),
                      );

                      if (ok) Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> _loadAvailableHours() async {
    if (selectedBarberId == null || selectedDate == null) return;

    setState(() {
      _isLoadingHours = true;
      availableHours = [];
      availabilityError = null;
    });

    try {
      final dateString = DateFormat('yyyy-MM-dd').format(selectedDate!);
      final hours = await Provider.of<AppointmentProvider>(context, listen: false)
          .getAvailableHours(selectedBarberId!, dateString);
      setState(() {
        availableHours = hours;
        if (selectedTime != null && !availableHours.contains(selectedTime)) {
          selectedTime = null;
        }
        if (hours.isEmpty) {
          availabilityError = 'No hay horarios disponibles para este barbero en esta fecha.';
        }
      });
    } catch (e) {
      setState(() {
        availabilityError = 'Error al consultar disponibilidad: $e';
      });
    } finally {
      setState(() {
        _isLoadingHours = false;
      });
    }
  }

  void _openProductSelector(List<Product> products) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, modalSetState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
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
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
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
                                        onPressed: () {
                                          _updateProductQuantity(product, quantity - 1);
                                          modalSetState(() {});
                                        },
                                      ),
                                      Text(quantity.toString()),
                                      IconButton(
                                        icon: const Icon(Icons.add_circle_outline),
                                        onPressed: () {
                                          _updateProductQuantity(product, quantity + 1);
                                          modalSetState(() {});
                                        },
                                      ),
                                    ],
                                  )
                                : IconButton(
                                    icon: const Icon(Icons.add_circle_outline),
                                    onPressed: () {
                                      _updateProductQuantity(product, 1);
                                      modalSetState(() {});
                                    },
                                  ),
                          );
                        },
                      ),
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

  void _updateProductQuantity(Product product, int quantity) {
    setState(() {
      if (quantity <= 0) {
        selectedProducts.removeWhere((item) => item.id == product.id);
      } else {
        final index = selectedProducts.indexWhere((item) => item.id == product.id);
        if (index != -1) {
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
      }
    });
  }
}
