import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/app_theme.dart';
import '../../mock/mock_services.dart';
import '../../models/service.dart';


class ManageServicesScreen extends StatefulWidget {
  const ManageServicesScreen({super.key});

  @override
  State<ManageServicesScreen> createState() => _ManageServicesScreenState();
}

class _ManageServicesScreenState extends State<ManageServicesScreen> {
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
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
        onPressed: () => _openServiceForm(),
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: mockServices.length,
        itemBuilder: (_, index) {
          final service = mockServices[index];

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
                        onPressed: () => _openServiceForm(service: service),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            mockServices.removeAt(index);
                          });
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
  }

  Widget _buildServiceImage(Service service) {
    if (service.imageFile != null) {
      return FutureBuilder<Uint8List>(
        future: service.imageFile!.readAsBytes(),
        builder: (_, snapshot) {
          if (!snapshot.hasData) {
            return const SizedBox(
              width: 70,
              height: 70,
              child: Center(child: CircularProgressIndicator()),
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

    return Image.asset(
      service.assetImage!,
      width: 70,
      height: 70,
      fit: BoxFit.cover,
    );
  }

  void _openServiceForm({Service? service}) {
    final nameCtrl = TextEditingController(text: service?.name ?? "");
    final priceCtrl =
        TextEditingController(text: service?.price.toString() ?? "");
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
                    controller: priceCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Precio"),
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
                  if (nameCtrl.text.isEmpty ||
                      priceCtrl.text.isEmpty) return;

                  setState(() {
                    if (service == null) {
                      mockServices.add(
                        Service(
                          id: mockServices.length + 1,
                          name: nameCtrl.text,
                          price: int.parse(priceCtrl.text),
                          imageFile: selectedImage,
                        ),
                      );
                    } else {
                      final index = mockServices.indexOf(service);
                      mockServices[index] = Service(
                        id: service.id,
                        name: nameCtrl.text,
                        price: int.parse(priceCtrl.text),
                        imageFile: selectedImage,
                      );
                    }
                  });

                  Navigator.pop(context);
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
