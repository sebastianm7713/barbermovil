import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../core/app_theme.dart';
import '../../models/barber_appointment.dart';
import '../../models/product.dart';
import '../../providers/appointment_provider.dart';
import '../../providers/barber_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/custom_button.dart';

class ModifyAppointmentScreen extends StatefulWidget {
  final BarberAppointment appointment;

  const ModifyAppointmentScreen({super.key, required this.appointment});

  @override
  State<ModifyAppointmentScreen> createState() => _ModifyAppointmentScreenState();
}

class _ModifyAppointmentScreenState extends State<ModifyAppointmentScreen> {
  late BarberAppointment appointment;
  late DateTime _selectedDay;
  late DateTime _focusedDay;
  String? _selectedTime;
  int? _selectedBarberId;
  bool _isLoadingHours = false;
  bool _isSaving = false;
  List<String> _availableTimes = [];
  String? _availabilityError;
  List<AppointmentProduct> _selectedProducts = [];

  @override
  void initState() {
    super.initState();
    appointment = widget.appointment;
    _selectedDay = appointment.date;
    _focusedDay = appointment.date;
    _selectedBarberId = appointment.barberId;
    _selectedTime = appointment.hour;
    _selectedProducts = List.from(appointment.products);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final barberProvider = Provider.of<BarberProvider>(context, listen: false);
      if (barberProvider.barbers.isEmpty) {
        barberProvider.fetchBarbers();
      }
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      if (productProvider.products.isEmpty) {
        productProvider.loadProducts();
      }
      _loadAvailableHours();
    });
  }

  @override
  Widget build(BuildContext context) {
    final barberProvider = Provider.of<BarberProvider>(context);
    final productProvider = Provider.of<ProductProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Modificar Cita'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildServiceInfo(),
            const SizedBox(height: 24),
            _buildDateSelection(),
            const SizedBox(height: 24),
            _buildTimeSelection(),
            const SizedBox(height: 24),
            _buildBarberSelection(barberProvider.barbers),
            const SizedBox(height: 24),
            _buildProductSelection(productProvider.products),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: _isSaving ? 'Guardando...' : 'Guardar Cambios',
                onPressed: _isSaving ? null : () => _saveChanges(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.content_cut, color: AppTheme.primary),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Servicio',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                appointment.service,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nueva Fecha:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TableCalendar(
            firstDay: DateTime.now(),
            lastDay: DateTime.now().add(const Duration(days: 90)),
            focusedDay: _focusedDay,
            currentDay: DateTime.now(),
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              _loadAvailableHours();
            },
            calendarStyle: CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: AppTheme.primary,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nueva Hora:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        if (_isLoadingHours)
          const Center(child: CircularProgressIndicator())
        else if (_selectedBarberId == null)
          const Text('Selecciona primero el barbero para ver horarios.' )
        else if (_availableTimes.isEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_availabilityError ?? 'No hay horarios disponibles para esta fecha.'),
              const SizedBox(height: 10),
              CustomButton(
                text: 'Actualizar disponibilidad',
                onPressed: _loadAvailableHours,
              ),
            ],
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableTimes.map((time) {
              final isSelected = _selectedTime == time;
              return ChoiceChip(
                label: Text(time),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _selectedTime = time);
                  }
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
    );
  }

  Widget _buildBarberSelection(List barbers) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Barbero:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        if (barbers.isEmpty)
          const Text('Cargando barberos...')
        else
          Column(
            children: barbers.map<Widget>((barber) {
              final isSelected = _selectedBarberId == barber.id;
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                elevation: isSelected ? 3 : 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                    color: isSelected ? AppTheme.primary : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.primary.withOpacity(0.2),
                    child: Text(
                      barber.name[0],
                      style: const TextStyle(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    barber.name,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: AppTheme.primary)
                      : null,
                  onTap: () {
                    setState(() {
                      _selectedBarberId = barber.id;
                      _selectedTime = null;
                      _availableTimes = [];
                      _availabilityError = null;
                    });
                    _loadAvailableHours();
                  },
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildProductSelection(List<Product> products) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Productos adicionales',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        if (_selectedProducts.isEmpty)
          const Text('No se han agregado productos.')
        else
          Column(
            children: _selectedProducts.map((product) {
              return ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(product.name),
                subtitle: Text('Cantidad: ${product.quantity}'),
                trailing: Text('\$${product.unitPrice.toStringAsFixed(2)}'),
              );
            }).toList(),
          ),
        const SizedBox(height: 10),
        CustomButton(
          text: 'Agregar o editar productos',
          onPressed: () => _openProductSelector(products),
        ),
      ],
    );
  }

  Future<void> _loadAvailableHours() async {
    if (_selectedBarberId == null) return;

    setState(() {
      _isLoadingHours = true;
      _availableTimes = [];
      _availabilityError = null;
    });

    try {
      final dateString = DateFormat('yyyy-MM-dd').format(_selectedDay);
      final hours = await Provider.of<AppointmentProvider>(context, listen: false)
          .getAvailableHours(_selectedBarberId!, dateString);
      setState(() {
        _availableTimes = hours;
        if (_selectedTime != null && !_availableTimes.contains(_selectedTime)) {
          _selectedTime = null;
        }
        if (hours.isEmpty) {
          _availabilityError = 'No hay horarios disponibles en esta fecha para el barbero seleccionado.';
        }
      });
    } catch (e) {
      setState(() {
        _availabilityError = 'Error al consultar disponibilidad: $e';
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
                          final selectedIndex = _selectedProducts.indexWhere((p) => p.id == product.id);
                          final quantity = selectedIndex != -1 ? _selectedProducts[selectedIndex].quantity : 0;

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
        _selectedProducts.removeWhere((item) => item.id == product.id);
      } else {
        final index = _selectedProducts.indexWhere((item) => item.id == product.id);
        if (index != -1) {
          _selectedProducts[index] = AppointmentProduct(
            id: product.id,
            name: product.name,
            quantity: quantity,
            unitPrice: product.price,
          );
        } else {
          _selectedProducts.add(AppointmentProduct(
            id: product.id,
            name: product.name,
            quantity: quantity,
            unitPrice: product.price,
          ));
        }
      }
    });
  }

  Future<void> _saveChanges() async {
    if (_selectedBarberId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un barbero.')),
      );
      return;
    }
    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona una hora disponible.')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final updatedAppointment = BarberAppointment(
      id: appointment.id,
      clientId: appointment.clientId,
      barberId: _selectedBarberId!,
      serviceId: appointment.serviceId,
      date: _selectedDay,
      hour: _selectedTime!,
      service: appointment.service,
      serviceImageUrl: appointment.serviceImageUrl,
      products: _selectedProducts,
      status: appointment.status,
    );

    final provider = Provider.of<AppointmentProvider>(context, listen: false);
    final success = await provider.updateAppointment(appointment.id, updatedAppointment);

    setState(() {
      _isSaving = false;
    });

    if (!mounted) return;

    if (success) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo actualizar la cita.')),
      );
    }
  }
}
