import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/product.dart';
import '../services/cart_service.dart';
import '../widgets/custom_text.dart';

// ENHANCEMENT 2: Product details screen
class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState
    extends State<ProductDetailScreen> {
  final CartService _cartService = CartService();

  bool _isAddingToCart = false;

  // Temporary user ID for testing.
  // We will replace this with the actual logged-in user ID later.
  final int userId = 1;

  Future<void> _addToCart() async {
    setState(() {
      _isAddingToCart = true;
    });

    try {
      await _cartService.addToCart(
        userId: userId,
        productId: widget.product.id,
        quantity: 1,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product added to cart'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add product: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isAddingToCart = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Scaffold(
      appBar: AppBar(
        title: CustomText(
          text: 'Product Details',
          fontSize: 20.sp,
          fontWeight: FontWeight.w600,
        ),
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Image.network(
                product.thumbnail,
                width: double.infinity,
                height: 250.h,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: double.infinity,
                    height: 250.h,
                    color: Colors.grey.shade200,
                    child: Icon(
                      Icons.image,
                      size: 50.sp,
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 16.h),

            CustomText(
              text: product.title,
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
            ),

            SizedBox(height: 8.h),

            CustomText(
              text:
                  '\$${product.price.toStringAsFixed(2)}',
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
            ),

            SizedBox(height: 16.h),

            Row(
              children: [
                Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: 20.sp,
                ),
                SizedBox(width: 4.w),

                CustomText(
                  text: product.rating.toString(),
                  fontSize: 14.sp,
                ),

                SizedBox(width: 16.w),

                CustomText(
                  text: 'Stock: ${product.stock}',
                  fontSize: 14.sp,
                ),
              ],
            ),

            SizedBox(height: 20.h),

            CustomText(
              text: 'Description',
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),

            SizedBox(height: 8.h),

            CustomText(
              text: product.description,
              fontSize: 14.sp,
            ),

            SizedBox(height: 20.h),

            CustomText(
              text: 'Product Information',
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),

            SizedBox(height: 10.h),

            CustomText(
              text: 'Brand: ${product.brand}',
              fontSize: 14.sp,
            ),

            SizedBox(height: 6.h),

            CustomText(
              text: 'Category: ${product.category}',
              fontSize: 14.sp,
            ),

            SizedBox(height: 6.h),

            CustomText(
              text:
                  'Availability: ${product.availabilityStatus}',
              fontSize: 14.sp,
            ),

            SizedBox(height: 6.h),

            CustomText(
              text:
                  'Shipping: ${product.shippingInformation}',
              fontSize: 14.sp,
            ),

            SizedBox(height: 6.h),

            CustomText(
              text:
                  'Warranty: ${product.warrantyInformation}',
              fontSize: 14.sp,
            ),

            SizedBox(height: 6.h),

            CustomText(
              text:
                  'Return Policy: ${product.returnPolicy}',
              fontSize: 14.sp,
            ),

            SizedBox(height: 30.h),

            // ENHANCEMENT 3: Add to Cart
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton.icon(
                onPressed:
                    _isAddingToCart ? null : _addToCart,
                icon: _isAddingToCart
                    ? SizedBox(
                        width: 20.w,
                        height: 20.h,
                        child:
                            const CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(
                        Icons.shopping_cart,
                      ),
                label: CustomText(
                  text: _isAddingToCart
                      ? 'Adding...'
                      : 'Add to Cart',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}