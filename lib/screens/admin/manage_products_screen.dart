import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_theme.dart';
import '../../models/product.dart';
import '../../providers/product_provider.dart';

class ManageProductsScreen extends StatefulWidget {
  const ManageProductsScreen({super.key});

  @override
  State<ManageProductsScreen> createState() => _ManageProductsScreenState();
}

class _ManageProductsScreenState extends State<ManageProductsScreen> {
  @override
  void initState() {
    super.initState();
    // Load products when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      if (productProvider.products.isEmpty && !productProvider.isLoading) {
        productProvider.loadProducts();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
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
            onPressed: () => _openForm(context),
          ),

          body: productProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : productProvider.products.isEmpty
                  ? const Center(child: Text("No hay productos disponibles."))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: productProvider.products.length,
                      itemBuilder: (context, index) {
                        final product = productProvider.products[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: product.imageUrl.isNotEmpty
                                ? Image.network(product.imageUrl, width: 50, height: 50, fit: BoxFit.cover)
                                : const Icon(Icons.inventory, size: 50),
                            title: Text(product.name),
                            subtitle: Text(
                              "\nPrecio: \$${product.price.toString()} | Stock: ${product.stock}",
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => _openForm(context, edit: product),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteProduct(context, product),
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

  void _deleteProduct(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Eliminar producto"),
        content: Text("¿Estás seguro de que quieres eliminar '${product.name}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () async {
              final productProvider = Provider.of<ProductProvider>(context, listen: false);
              final success = await productProvider.deleteProduct(product.id);
              Navigator.pop(context);
              if (success) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Producto eliminado')),
                  );
                }
              } else {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Error al eliminar producto')),
                  );
                }
              }
            },
            child: const Text("Eliminar"),
          ),
        ],
      ),
    );
  }

  /// ?? FORM CREAR / EDITAR
  void _openForm(BuildContext context, {Product? edit}) {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
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
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Nombre")),
              TextField(controller: descCtrl, decoration: const InputDecoration(labelText: "Descripci�n")),
              TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Precio")),
              TextField(controller: stockCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Stock")),
              TextField(controller: categoryCtrl, decoration: const InputDecoration(labelText: "Categor�a")),
              TextField(controller: imageCtrl, decoration: const InputDecoration(labelText: "Imagen (URL o asset)")),
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
              final product = Product(
                id: edit?.id ?? 0,
                name: nameCtrl.text,
                description: descCtrl.text,
                price: int.tryParse(priceCtrl.text) ?? 0,
                stock: int.tryParse(stockCtrl.text) ?? 0,
                category: categoryCtrl.text,
                imageUrl: imageCtrl.text,
              );

              bool success;
              if (edit == null) {
                success = await productProvider.createProduct(product);
              } else {
                success = await productProvider.updateProduct(edit.id, product);
              }

              if (success) {
                Navigator.pop(context);
              } else {
                // Show error message
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(edit == null ? 'Error al crear producto' : 'Error al actualizar producto')),
                  );
                }
              }
            },
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }
}
