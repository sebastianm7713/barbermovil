import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product_service.dart';

class ProductProvider extends ChangeNotifier {
  final ProductService _productService = ProductService();

  List<Product> _products = [];
  bool _isLoading = false;

  // GETTERS
  List<Product> get products => _products;
  bool get isLoading => _isLoading;

  // Cargar todos los productos
  Future<void> loadProducts() async {
    _isLoading = true;
    notifyListeners();

    try {
      _products = await _productService.getAllProducts();
    } catch (e) {
      _products = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  // Cargar productos por categoría
  Future<void> loadProductsByCategory(String category) async {
    _isLoading = true;
    notifyListeners();

    try {
      _products = await _productService.getProductsByCategory(category);
    } catch (e) {
      _products = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  // Crear producto
  Future<bool> createProduct(Product product) async {
    final created = await _productService.createProduct(product);

    if (created != null) {
      _products.add(created);
      notifyListeners();
      return true;
    }

    return false;
  }

  // Actualizar producto
  Future<bool> updateProduct(int id, Product product) async {
    final updated = await _productService.updateProduct(id, product);

    if (updated) {
      final index = _products.indexWhere((p) => p.id == id);
      if (index != -1) {
        _products[index] = product;
        notifyListeners();
      }
      return true;
    }

    return false;
  }

  // Eliminar producto
  Future<bool> deleteProduct(int id) async {
    final deleted = await _productService.deleteProduct(id);

    if (deleted) {
      _products.removeWhere((p) => p.id == id);
      notifyListeners();
      return true;
    }

    return false;
  }
}
