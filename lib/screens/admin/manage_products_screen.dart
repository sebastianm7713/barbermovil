import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/app_theme.dart';
import '../../mock/mock_products.dart';

class ManageProductsScreen extends StatefulWidget {
  const ManageProductsScreen({super.key});

  @override
  State<ManageProductsScreen> createState() => _ManageProductsScreenState();
}

class _ManageProductsScreenState extends State<ManageProductsScreen> {
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text("Productos"),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.add),
        onPressed: () => _openForm(),
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: mockProducts.length,
        itemBuilder: (_, index) {
          final product = mockProducts[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  /// 🖼️ IMAGEN
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: _buildProductImage(product),
                  ),

                  const SizedBox(width: 14),

                  /// INFO
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(product.description),
                        const SizedBox(height: 4),
                        Text(
                          "\$${product.price} · Stock: ${product.stock}",
                          style: const TextStyle(color: Colors.grey),
                        ),
                        Text(
                          "Proveedor: ${product.provider}",
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),

                  /// ACCIONES
                  Column(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _openForm(edit: product),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            mockProducts.removeAt(index);
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

  /// 🖼️ IMAGEN PRODUCTO
  Widget _buildProductImage(Product product) {
    if (product.imageFile != null) {
      return FutureBuilder<Uint8List>(
        future: product.imageFile!.readAsBytes(),
        builder: (_, snapshot) {
          if (!snapshot.hasData) {
            return const SizedBox(width: 70, height: 70);
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
      product.assetImage ?? "assets/images/products/gomina.png",
      width: 70,
      height: 70,
      fit: BoxFit.cover,
    );
  }

  /// 🧾 FORM CREAR / EDITAR
  void _openForm({Product? edit}) {
    final nameCtrl = TextEditingController(text: edit?.name);
    final descCtrl = TextEditingController(text: edit?.description);
    final priceCtrl =
        TextEditingController(text: edit?.price.toString());
    final stockCtrl =
        TextEditingController(text: edit?.stock.toString());
    final providerCtrl =
        TextEditingController(text: edit?.provider);

    XFile? selectedImage = edit?.imageFile;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setModal) {
          return AlertDialog(
            title: Text(edit == null ? "Nuevo producto" : "Editar producto"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// 📷 IMAGEN
                  GestureDetector(
                    onTap: () async {
                      final img = await _picker.pickImage(
                        source: ImageSource.gallery,
                        imageQuality: 70,
                      );
                      if (img != null) {
                        setModal(() => selectedImage = img);
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
                              builder: (_, snap) {
                                if (!snap.hasData) return const SizedBox();
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.memory(
                                    snap.data!,
                                    fit: BoxFit.cover,
                                  ),
                                );
                              },
                            ),
                    ),
                  ),

                  const SizedBox(height: 12),
                  TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Nombre")),
                  TextField(controller: descCtrl, decoration: const InputDecoration(labelText: "Descripción")),
                  TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Precio")),
                  TextField(controller: stockCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Cantidad")),
                  TextField(controller: providerCtrl, decoration: const InputDecoration(labelText: "Proveedor")),
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
                  setState(() {
                    if (edit == null) {
                      mockProducts.add(
                        Product(
                          id: mockProducts.length + 1,
                          name: nameCtrl.text,
                          description: descCtrl.text,
                          price: int.parse(priceCtrl.text),
                          stock: int.parse(stockCtrl.text),
                          provider: providerCtrl.text,
                          imageFile: selectedImage,
                        ),
                      );
                    } else {
                      edit.name = nameCtrl.text;
                      edit.description = descCtrl.text;
                      edit.price = int.parse(priceCtrl.text);
                      edit.stock = int.parse(stockCtrl.text);
                      edit.provider = providerCtrl.text;
                      edit.imageFile = selectedImage;
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
