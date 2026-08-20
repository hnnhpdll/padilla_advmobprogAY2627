import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/product.dart';
import '../constants.dart';

class ProductService {
  Future<List<Product>> getAllProducts() async {
    final response = await http
        .get(
          Uri.parse('$host/products'),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data =
          jsonDecode(response.body);

      final List productsJson = data['products'] ?? [];

      return productsJson
          .map((json) => Product.fromJson(json))
          .toList();
    } else {
      throw Exception(
        'Failed to load products: ${response.statusCode}',
      );
    }
  }

  Future<Product> getProductById(int productId) async {
    final response = await http
        .get(
          Uri.parse('$host/products/$productId'),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data =
          jsonDecode(response.body);

      return Product.fromJson(data);
    } else {
      throw Exception(
        'Failed to load product: ${response.statusCode}',
      );
    }
  }
}