import 'dart:convert';
import 'package:http/http.dart' as http;

import '../core/api.dart';
import '../models/product.dart';

class ProductService {
  final String baseUrl = "${Api.baseUrl}/products";

  // Obtener todos los productos
  Future<List<Product>> getAllProducts() async {
    final url = Uri.parse(baseUrl);

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Product.fromJson(e)).toList();
    } else {
      throw Exception("Error al obtener productos");
    }
  }

  // Obtener productos por categoría
  Future<List<Product>> getProductsByCategory(String category) async {
    final url = Uri.parse("$baseUrl/category/$category");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Product.fromJson(e)).toList();
    } else {
      throw Exception("Error al obtener productos por categoría");
    }
  }

  // Crear producto
  Future<Product?> createProduct(Product product) async {
    final url = Uri.parse(baseUrl);

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(product.toJson()),
    );

    if (response.statusCode == 201) {
      return Product.fromJson(jsonDecode(response.body));
    } else {
      return null;
    }
  }

  // Actualizar producto
  Future<bool> updateProduct(int id, Product product) async {
    final url = Uri.parse("$baseUrl/$id");

    final response = await http.put(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(product.toJson()),
    );

    return response.statusCode == 200;
  }

  // Eliminar producto
  Future<bool> deleteProduct(int id) async {
    final url = Uri.parse("$baseUrl/$id");

    final response = await http.delete(url);

    return response.statusCode == 200;
  }
}
