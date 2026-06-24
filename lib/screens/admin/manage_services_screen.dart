import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/app_theme.dart';
import '../../models/service.dart';
import '../../providers/service_provider.dart';

class ManageServicesScreen extends StatefulWidget {
  const ManageServicesScreen({super.key});

  @override
  State<ManageServicesScreen> createState() => _ManageServicesScreenState();
}

class _ManageServicesScreenState extends State<ManageServicesScreen> {
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Load services when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final serviceProvider = Provider.of<ServiceProvider>(context, listen: false);
      if (serviceProvider.services.isEmpty && !serviceProvider.isLoading) {
        serviceProvider.loadServices();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ServiceProvider>(
      builder: (context, serviceProvider, child) {
        return Scaffold(
          backgroundColor: AppTheme.background,
          appBar: AppBar(
            title: const Text("Servicios"),
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
          ),

          floatingActionButton: FloatingActionButton(
            backgroundColor: AppTheme.primary,
            child: const Icon(Icons.add),
            onPressed: () => _openServiceForm(context),
          ),

          body: serviceProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : serviceProvider.services.isEmpty
                  ? const Center(child: Text("No hay servicios disponibles."))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: serviceProvider.services.length,
                      itemBuilder: (_, index) {
                        final service = serviceProvider.services[index];

                        return Card(
                          margin: const EdgeInsets.only(bottom: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                // IMAGEN
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: _buildServiceImage(service),
                                ),

                                const SizedBox(width: 14),

                                // INFO
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        service.name,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        "\$${service.price}",
                                        style: const TextStyle(color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),

                                // ACCIONES
                                Column(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blue),
                                      onPressed: () => _openServiceForm(context, service: service),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () async {
                                        final success = await serviceProvider.deleteService(service.id);
                                        if (!success && mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Error al eliminar servicio')),
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
        );
      },
    );
  }

  Widget _buildServiceImage(Service service) {
    // Imagen subida desde galería
    if (service.imageFile != null) {
      return FutureBuilder<Uint8List>(
        future: service.imageFile!.readAsBytes(),
        builder: (_, snapshot) {
          if (!snapshot.hasData) {
            return const SizedBox(
              width: 70,
              height: 70,
              child: CircularProgressIndicator(),
            );
          }
          return Image.memory(
            snapshot.data!,
            width: 70,
            height: 70,
            fit: BoxFit.cover,
          );
        },
      );
    }

    // Imagen desde URL o data URI
    if (service.imageUrl.isNotEmpty) {
      if (service.imageUrl.startsWith('data:')) {
        try {
          final commaIndex = service.imageUrl.indexOf(',');
          final base64Data = commaIndex != -1 ? service.imageUrl.substring(commaIndex + 1) : '';
          final bytes = base64Decode(base64Data);
          return Image.memory(
            bytes,
            width: 70,
            height: 70,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 70,
              height: 70,
              color: Colors.grey[300],
              child: const Icon(Icons.image),
            ),
          );
        } catch (_) {
          return Container(
            width: 70,
            height: 70,
            color: Colors.grey[300],
            child: const Icon(Icons.broken_image),
          );
        }
      }

      return Image.network(
        service.imageUrl,
        width: 70,
        height: 70,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: 70,
          height: 70,
          color: Colors.grey[300],
          child: const Icon(Icons.image),
        ),
      );
    }

    // Imagen desde assets
    if (service.assetImage != null) {
      return Image.asset(
        service.assetImage!,
        width: 70,
        height: 70,
        fit: BoxFit.cover,
      );
    }

    // Fallback (NUNCA vuelve a romper)
    return Container(
      width: 70,
      height: 70,
      color: Colors.grey.shade300,
      child: const Icon(Icons.image_not_supported),
    );
  }

  void _openServiceForm(BuildContext context, {Service? service}) {
    final serviceProvider = Provider.of<ServiceProvider>(context, listen: false);
    final nameCtrl = TextEditingController(text: service?.name ?? "");
    final priceCtrl = TextEditingController(text: service?.price.toString() ?? "");
    final descriptionCtrl = TextEditingController(text: service?.description ?? "");
    final durationCtrl = TextEditingController(text: service?.duration.toString() ?? "");
    final imageCtrl = TextEditingController(text: service?.imageUrl ?? "");
    XFile? selectedImage = service?.imageFile;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) {
          return AlertDialog(
            title: Text(service == null ? "Nuevo servicio" : "Editar servicio"),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () async {
                      final img = await _picker.pickImage(
                        source: ImageSource.gallery,
                        imageQuality: 70,
                      );
                      if (img != null) {
                        setModalState(() => selectedImage = img);
                      }
                    },
                    child: Container(
                      height: 120,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: selectedImage == null
                          ? const Center(
                              child: Icon(Icons.add_a_photo, size: 40),
                            )
                          : FutureBuilder<Uint8List>(
                              future: selectedImage!.readAsBytes(),
                              builder: (_, snapshot) {
                                if (!snapshot.hasData) return const SizedBox();
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.memory(
                                    snapshot.data!,
                                    fit: BoxFit.cover,
                                  ),
                                );
                              },
                            ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: "Nombre"),
                  ),

                  TextField(
                    controller: descriptionCtrl,
                    decoration: const InputDecoration(labelText: "Descripción"),
                  ),

                  TextField(
                    controller: priceCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Precio"),
                  ),

                  TextField(
                    controller: durationCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Duración (minutos)"),
                  ),

                  TextField(
                    controller: imageCtrl,
                    decoration: const InputDecoration(labelText: "Imagen (URL)"),
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
                  if (nameCtrl.text.isEmpty || priceCtrl.text.isEmpty) return;

                  final newService = Service(
                    id: service?.id ?? 0,
                    name: nameCtrl.text,
                    description: descriptionCtrl.text,
                    price: int.tryParse(priceCtrl.text) ?? 0,
                    duration: int.tryParse(durationCtrl.text) ?? 30,
                    imageUrl: imageCtrl.text,
                    imageFile: selectedImage,
                  );

                  bool success;
                  if (service == null) {
                    success = await serviceProvider.createService(newService);
                  } else {
                    success = await serviceProvider.updateService(service.id, newService);
                  }

                  if (success) {
                    Navigator.pop(context);
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(service == null ? 'Error al crear servicio' : 'Error al actualizar servicio')),
                      );
                    }
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
}
