import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants.dart';
import '../models/cart.dart';

class CartService {
  // Get all carts 
  Future<List<Cart>> getAllCarts() async {
    final response = await http
        .get(
          Uri.parse('$host/carts'),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data =
          jsonDecode(response.body);

      final List cartsJson = data['carts'] ?? [];

      return cartsJson
          .map((json) => Cart.fromJson(json))
          .toList();
    } else {
      throw Exception(
        'Failed to load carts: ${response.statusCode}',
      );
    }
  }

  // Get one user's cart belonging to the specified user ID using the DummyJSON /carts/user/{userId} endpoint.
  Future<Cart?> getCartByUserId(int userId) async {
    final response = await http
        .get(
          Uri.parse('$host/carts/user/$userId'),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data =
          jsonDecode(response.body);

      final List cartsJson = data['carts'] ?? [];

      if (cartsJson.isEmpty) {
        return null;
      }

      return Cart.fromJson(cartsJson[0]);
    } else {
      throw Exception(
        'Failed to load user cart: ${response.statusCode}',
      );
    }
  }

  // Add product to cart by passing the user ID, product ID, and quantity to the DummyJSON cart endpoint
  Future<Cart> addToCart({
    required int userId,
    required int productId,
    required int quantity,
  }) async {
    final response = await http
        .post(
          Uri.parse('$host/carts/add'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'userId': userId,
            'products': [
              {
                'id': productId,
                'quantity': quantity,
              },
            ],
          }),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200 ||
        response.statusCode == 201) {
      return Cart.fromJson(
        jsonDecode(response.body),
      );
    } else {
      throw Exception(
        'Failed to add product to cart: '
        '${response.statusCode}',
      );
    }
  }

  /// ENHANCEMENT:
  // Updates the quantity of a specific product in the cart
  // using the DummyJSON PUT /carts/{cartId} endpoint.
  // The merge option preserves the other products in the cart
  // when the selected product quantity is updated.
  Future<Cart> updateCart({
  required int cartId,
  required int productId,
  required int quantity,
}) async {
  final response = await http
      .put(
        Uri.parse('$host/carts/$cartId'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'merge': true,
          'products': [
            {
              'id': productId,
              'quantity': quantity,
            },
          ],
        }),
      )
      .timeout(const Duration(seconds: 10));

  if (response.statusCode == 200) {
    return Cart.fromJson(
      jsonDecode(response.body),
    );
  } else {
    throw Exception(
      'Failed to update cart: ${response.statusCode}',
    );
  }
}
}