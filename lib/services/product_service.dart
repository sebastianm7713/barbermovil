import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../core/api.dart';
import '../models/product.dart';

class ProductService {
  /// Obtener todos los productos
  Future<List<Product>> getAllProducts() async {
    try {
      final response = await http.get(Uri.parse('${Api.baseUrl}/productos'));
      print('ProductService getAllProducts response status: ${response.statusCode}');
      print('ProductService getAllProducts response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return (data['data'] as List).map((productJson) {
            final mapped = _mapBackendToFrontend(productJson);
            print('ProductService mapped product: $mapped');
            return Product.fromJson(mapped);
          }).toList();
        }
      }
      return [];
    } catch (e) {
      print('ProductService getAllProducts error: $e');
      return [];
    }
  }
  
  /// Mapear estructura del backend a estructura del frontend
  Map<String, dynamic> _mapBackendToFrontend(dynamic backendData) {
    if (backendData is Map<String, dynamic>) {
      final rawImage = backendData['img'] ?? backendData['imagen'] ?? backendData['imageUrl'] ?? '';
      final imageUrl = _normalizeImageUrl(rawImage?.toString() ?? '');

      return {
        'id': backendData['id_producto'] ?? backendData['id'] ?? 0,
        'name': backendData['nombre'] ?? backendData['name'] ?? '',
        'description': backendData['descripcion'] ?? backendData['description'] ?? '',
        'price': backendData['precio'] ?? backendData['price'] ?? 0,
        'stock': backendData['stock'] ?? 0,
        'imageUrl': imageUrl,
        'category': (backendData['id_categoria'] ?? 'general').toString(),
      };
    }
    return {};
  }

  String _normalizeImageUrl(String imageUrl) {
    final trimmed = imageUrl.trim();
    if (trimmed.isEmpty) return '';
    if (trimmed.startsWith('data:')) {
      return trimmed;
    }
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    if (trimmed.startsWith('//')) {
      return 'http:$trimmed';
    }
    final host = _backendHost;
    if (trimmed.startsWith('/')) {
      return '$host$trimmed';
    }
    return '$host/$trimmed';
  }

  String get _backendHost {
    if (kIsWeb) {
      return 'http://localhost:4000';
    }
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:4000';
    }
    return 'http://localhost:4000';
  }

  /// Obtener productos por categoría
  Future<List<Product>> getProductsByCategory(String category) async {
    final allProducts = await getAllProducts();
    return allProducts.where((product) => product.category == category).toList();
  }

  /// Crear producto
  Future<Product?> createProduct(Product product) async {
    try {
      final response = await http.post(
        Uri.parse('${Api.baseUrl}/productos'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nombre': product.name,
          'precio': product.price,
          'descripcion': product.description,
          'stock': product.stock,
          'img': product.imageUrl,
        }),
      );

      print('ProductService createProduct response status: ${response.statusCode}');
      print('ProductService createProduct response body: ${response.body}');

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final mapped = _mapBackendToFrontend(data['data']);
          return Product.fromJson(mapped);
        }
      }
      return null;
    } catch (e) {
      print('ProductService createProduct error: $e');
      return null;
    }
  }

  /// Actualizar producto
  Future<Product?> updateProduct(int id, Product product) async {
    try {
      final response = await http.put(
        Uri.parse('${Api.baseUrl}/productos/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nombre': product.name,
          'precio': product.price,
          'descripcion': product.description,
          'stock': product.stock,
          'img': product.imageUrl,
        }),
      );

      print('ProductService updateProduct response status: ${response.statusCode}');
      print('ProductService updateProduct response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final mapped = _mapBackendToFrontend(data['data']);
          return Product.fromJson(mapped);
        }
      }
      return null;
    } catch (e) {
      print('ProductService updateProduct error: $e');
      return null;
    }
  }

  /// Eliminar producto
  Future<bool> deleteProduct(int id) async {
    try {
      final response = await http.delete(Uri.parse('${Api.baseUrl}/productos/$id'));
      print('ProductService deleteProduct response status: ${response.statusCode}');
      print('ProductService deleteProduct response body: ${response.body}');
      return response.statusCode == 200;
    } catch (e) {
      print('ProductService deleteProduct error: $e');
      return false;
    }
  }
}
