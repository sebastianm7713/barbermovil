import 'package:flutter/material.dart';
import '../models/product.dart';
import '../mock/mock_products.dart';

class ProductProvider extends ChangeNotifier {
  List<Product> _products = [];
  bool _isLoading = false;

  // GETTERS
  List<Product> get products => _products;
  bool get isLoading => _isLoading;

  // ===============================
  // CARGAR TODOS LOS PRODUCTOS
  // ===============================
  Future<void> loadProducts() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));
    _products = List<Product>.from(mockProducts);

    _isLoading = false;
    notifyListeners();
  }

  // ===============================
  // CARGAR POR CATEGORÍA
  // ===============================
  Future<void> loadProductsByCategory(String category) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 300));
    _products = mockProducts
        .where((p) => p.category == category)
        .toList();

    _isLoading = false;
    notifyListeners();
  }

  // ===============================
  // CREAR PRODUCTO (ADMIN)
  // ===============================
  void createProduct(Product product) {
    mockProducts.add(product);
    _products = List<Product>.from(mockProducts);
    notifyListeners();
  }

  // ===============================
  // ACTUALIZAR PRODUCTO
  // ===============================
  void updateProduct(Product product) {
    final index = mockProducts.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      mockProducts[index] = product;
      _products = List<Product>.from(mockProducts);
      notifyListeners();
    }
  }

  // ===============================
  // ELIMINAR PRODUCTO
  // ===============================
  void deleteProduct(int id) {
    mockProducts.removeWhere((p) => p.id == id);
    _products = List<Product>.from(mockProducts);
    notifyListeners();
  }
}
