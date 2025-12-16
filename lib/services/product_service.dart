import '../models/product.dart';
import '../mock/mock_products.dart';

class ProductService {
  /// Obtener todos los productos
  Future<List<Product>> getAllProducts() async {
    await Future.delayed(const Duration(milliseconds: 300)); // simula carga
    return mockProducts;
  }

  /// Obtener productos por categoría
  Future<List<Product>> getProductsByCategory(String category) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return mockProducts
        .where((product) => product.category == category)
        .toList();
  }

  /// Crear producto
  Future<Product?> createProduct(Product product) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final newProduct = Product(
      id: mockProducts.length + 1,
      name: product.name,
      description: product.description,
      price: product.price,
      stock: product.stock,
      imageUrl: product.imageUrl,
      category: product.category,
    );

    mockProducts.add(newProduct);
    return newProduct;
  }

  /// Actualizar producto
  Future<bool> updateProduct(int id, Product product) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final index = mockProducts.indexWhere((p) => p.id == id);
    if (index == -1) return false;

    mockProducts[index] = product;
    return true;
  }

  /// Eliminar producto
  Future<bool> deleteProduct(int id) async {
    await Future.delayed(const Duration(milliseconds: 300));

    mockProducts.removeWhere((p) => p.id == id);
    return true;
  }
}
