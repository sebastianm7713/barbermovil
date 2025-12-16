import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../../models/product.dart';
import '../../mock/mock_products.dart';

class ManageProductsScreen extends StatefulWidget {
  const ManageProductsScreen({super.key});

  @override
  State<ManageProductsScreen> createState() => _ManageProductsScreenState();
}

class _ManageProductsScreenState extends State<ManageProductsScreen> {

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
                    child: Image.asset(
                      product.imageUrl,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                    ),
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
                          "Categoría: ${product.category}",
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

  /// 🧾 FORM CREAR / EDITAR
  void _openForm({Product? edit}) {
    final nameCtrl = TextEditingController(text: edit?.name);
    final descCtrl = TextEditingController(text: edit?.description);
    final priceCtrl = TextEditingController(text: edit?.price.toString());
    final stockCtrl = TextEditingController(text: edit?.stock.toString());
    final categoryCtrl = TextEditingController(text: edit?.category);
    final imageCtrl = TextEditingController(text: edit?.imageUrl);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(edit == null ? "Nuevo producto" : "Editar producto"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Nombre")),
              TextField(controller: descCtrl, decoration: const InputDecoration(labelText: "Descripción")),
              TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Precio")),
              TextField(controller: stockCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Stock")),
              TextField(controller: categoryCtrl, decoration: const InputDecoration(labelText: "Categoría")),
              TextField(controller: imageCtrl, decoration: const InputDecoration(labelText: "Imagen (asset)")),
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
                      category: categoryCtrl.text,
                      imageUrl: imageCtrl.text,
                    ),
                  );
                } else {
                  edit.name = nameCtrl.text;
                  edit.description = descCtrl.text;
                  edit.price = int.parse(priceCtrl.text);
                  edit.stock = int.parse(stockCtrl.text);
                  edit.category = categoryCtrl.text;
                  edit.imageUrl = imageCtrl.text;
                }
              });
              Navigator.pop(context);
            },
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }
}
