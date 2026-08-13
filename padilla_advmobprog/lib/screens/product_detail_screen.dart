
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/product.dart';
import '../widgets/custom_text.dart';

// ENHANCEMENT 2: Product details screen
class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: CustomText(
          text: 'Product Details',
          fontSize: 20.sp,
          fontWeight: FontWeight.w600,
        ),
      ),

      // ENHANCEMENT 2: Display product information
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ENHANCEMENT 2: Product image
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

            // ENHANCEMENT 2: Product title
            CustomText(
              text: product.title,
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
            ),

            SizedBox(height: 8.h),

            // ENHANCEMENT 2: Product price
            CustomText(
              text:
                  '\$${product.price.toStringAsFixed(2)}',
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
            ),

            SizedBox(height: 16.h),

            // ENHANCEMENT 2: Product rating and stock
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

            // ENHANCEMENT 2: Product description
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

            // ENHANCEMENT 2: Product information
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
          ],
        ),
      ),
    );
  }
}
