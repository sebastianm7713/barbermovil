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

  // ===============================
  // CARGAR TODOS LOS PRODUCTOS
  // ===============================
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

  // ===============================
  // CARGAR POR CATEGORÍA
  // ===============================
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

  // ===============================
  // CREAR PRODUCTO (ADMIN)
  // ===============================
  Future<bool> createProduct(Product product) async {
    try {
      final newProduct = await _productService.createProduct(product);
      if (newProduct != null) {
        _products.add(newProduct);
        notifyListeners();
        return true;
      }
    } catch (e) {
      // Handle error
    }
    return false;
  }

  // ===============================
  // ACTUALIZAR PRODUCTO (ADMIN)
  // ===============================
  Future<bool> updateProduct(int id, Product product) async {
    try {
      final updatedProduct = await _productService.updateProduct(id, product);
      if (updatedProduct != null) {
        final index = _products.indexWhere((p) => p.id == id);
        if (index != -1) {
          _products[index] = updatedProduct;
          notifyListeners();
          return true;
        }
      }
    } catch (e) {
      print('ProductProvider updateProduct error: $e');
    }
    return false;
  }

  // ===============================
  // ELIMINAR PRODUCTO (ADMIN)
  // ===============================
  Future<bool> deleteProduct(int id) async {
    try {
      final success = await _productService.deleteProduct(id);
      if (success) {
        _products.removeWhere((p) => p.id == id);
        notifyListeners();
        return true;
      }
    } catch (e) {
      // Handle error
    }
    return false;
  }
}
