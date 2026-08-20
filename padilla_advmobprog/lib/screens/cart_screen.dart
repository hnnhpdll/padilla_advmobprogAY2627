import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/cart.dart';
import '../services/cart_service.dart';
import '../services/product_service.dart';
import '../widgets/custom_text.dart';
import 'product_detail_screen.dart';

class CartScreen extends StatefulWidget {
  final int userId;

  const CartScreen({
    super.key,
    required this.userId,
  });

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartService _cartService = CartService();
  final ProductService _productService = ProductService();

  Cart? _cart;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

// ENHANCEMENT: Load and render only the cart associated with the current user's ID.
  Future<void> _loadCart() async {
    try {
      final cart =
          await _cartService.getCartByUserId(widget.userId);

      if (!mounted) return;

      setState(() {
        _cart = cart;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load cart: $e'),
        ),
      );
    }
  }

  Future<void> _openProduct(int productId) async {
    try {
      final product =
          await _productService.getProductById(productId);

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductDetailScreen(
            product: product,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load product: $e'),
        ),
      );
    }
  }

  Future<void> _updateQuantity(
  int productId,
  int newQuantity,
) async {
  if (_cart == null || newQuantity < 1) {
    return;
  }

  try {
    // Update the cart using DummyJSON
    await _cartService.updateCart(
      cartId: _cart!.id,
      productId: productId,
      quantity: newQuantity,
    );

    if (!mounted) return;

    setState(() {
      final updatedProducts = _cart!.products.map((product) {
        if (product.id == productId) {
          final newTotal = product.price * newQuantity;

          final newDiscountedTotal =
              newTotal *
              (1 - product.discountPercentage / 100);

          return product.copyWith(
            quantity: newQuantity,
            total: newTotal,
            discountedTotal: newDiscountedTotal,
          );
        }

        // Keep the other products unchanged
        return product;
      }).toList();

      final newTotalQuantity = updatedProducts.fold<int>(
        0,
        (sum, product) => sum + product.quantity,
      );

      final newTotal = updatedProducts.fold<double>(
        0.0,
        (sum, product) => sum + product.total,
      );

      final newDiscountedTotal = updatedProducts.fold<double>(
        0.0,
        (sum, product) => sum + product.discountedTotal,
      );

      _cart = Cart(
        id: _cart!.id,
        products: updatedProducts,
        total: newTotal,
        discountedTotal: newDiscountedTotal,
        userId: _cart!.userId,
        totalProducts: updatedProducts.length,
        totalQuantity: newTotalQuantity,
      );
    });
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Failed to update quantity: $e',
        ),
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_cart == null || _cart!.products.isEmpty) {
      return Center(
        child: CustomText(
          text: 'Your cart is empty',
          fontSize: 18.sp,
          fontWeight: FontWeight.w500,
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(16.r),
            itemCount: _cart!.products.length,
            itemBuilder: (context, index) {
              final product = _cart!.products[index];

              return _buildCartItem(product);
            },
          ),
        ),

        _buildCartSummary(),
      ],
    );
  }

  Widget _buildCartItem(CartProduct product) {
    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Product image
          GestureDetector(
            onTap: () {
              _openProduct(product.id);
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Image.network(
                product.thumbnail,
                width: 85.w,
                height: 100.h,
                fit: BoxFit.contain,
                errorBuilder:
                    (context, error, stackTrace) {
                  return Container(
                    width: 85.w,
                    height: 100.h,
                    color: Colors.grey.shade200,
                    child: Icon(
                      Icons.image,
                      size: 35.sp,
                    ),
                  );
                },
              ),
            ),
          ),

          SizedBox(width: 12.w),

          // Product information
          Expanded(
            child: GestureDetector(
              onTap: () {
                _openProduct(product.id);
              },
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: product.title,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),

                  SizedBox(height: 7.h),

                  CustomText(
                    text:
                        '\$${product.price.toStringAsFixed(2)}',
                    fontSize: 17.sp,
                    fontWeight: FontWeight.bold,
                  ),

                  SizedBox(height: 5.h),

                  CustomText(
                    text:
                        '${product.discountPercentage.toStringAsFixed(0)}% off • '
                        '\$${product.total.toStringAsFixed(2)} total',
                    fontSize: 12.sp,
                  ),
                ],
              ),
            ),
          ),

          SizedBox(width: 8.w),

          // Quantity controls
          Column(
            children: [
              SizedBox(
                width: 40.w,
                height: 40.h,
                child: ElevatedButton(
                  onPressed: () {
                    _updateQuantity(
                      product.id,
                      product.quantity + 1,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(10.r),
                    ),
                  ),
                  child: Icon(
                    Icons.add,
                    size: 20.sp,
                  ),
                ),
              ),

              SizedBox(height: 6.h),

              CustomText(
                text: product.quantity.toString(),
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),

              SizedBox(height: 6.h),

              SizedBox(
                width: 40.w,
                height: 40.h,
                child: ElevatedButton(
                  onPressed: product.quantity <= 1
                      ? null
                      : () {
                          _updateQuantity(
                            product.id,
                            product.quantity - 1,
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(10.r),
                    ),
                  ),
                  child: Icon(
                    Icons.remove,
                    size: 20.sp,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCartSummary() {
    final subtotal = _cart!.products.fold<double>(
      0.0,
      (sum, product) =>
          sum + (product.price * product.quantity),
    );

    return Container(
      padding: EdgeInsets.fromLTRB(
        18.w,
        12.h,
        18.w,
        18.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              CustomText(
                text: 'Subtotal:',
                fontSize: 16.sp,
              ),
              CustomText(
                text:
                    '\$${subtotal.toStringAsFixed(2)}',
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ],
          ),

          SizedBox(height: 12.h),

          SizedBox(
            width: double.infinity,
            height: 50.h,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  const SnackBar(
                    content:
                        Text('Order confirmation coming soon'),
                  ),
                );
              },
              child: CustomText(
                text: 'Confirm Order',
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}