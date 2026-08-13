import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/product.dart';
import '../services/product_service.dart';
import '../widgets/custom_text.dart';

// Enhancement 2: Import connected screen
import 'product_detail_screen.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  late Future<List<Product>> _productsFuture;

  // ENHANCEMENT 1: Search Bar
  final TextEditingController _searchController =
      TextEditingController();

  // ENHANCEMENT 1: Stores the current search text
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();

    _productsFuture = ProductService().getAllProducts();

    // ENHANCEMENT 1: Listen for changes in the search bar
    _searchController.addListener(() {
      setState(() {
        _searchQuery =
            _searchController.text.toLowerCase();
      });
    });
  }

  // ENHANCEMENT 1: Dispose the search controller
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 16.h,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ENHANCEMENT 1: Search bar added above the product list
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: Icon(
                  Icons.search,
                  size: 24.sp,
                ),

                // ENHANCEMENT 1: Clear search button
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          size: 22.sp,
                        ),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,

                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(12.r),
                ),
              ),
            ),

            SizedBox(height: 16.h),

            FutureBuilder<List<Product>>(
              future: _productsFuture,
              builder: (context, snapshot) {
                // Loading state
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.r),
                      child:
                          const CircularProgressIndicator(),
                    ),
                  );
                }

                // ENHANCEMENT: Error message
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.r),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.shopping_bag_outlined,
                            size: 56.sp,
                            color: Colors.deepPurple,
                          ),

                          SizedBox(height: 12.h),

                          CustomText(
                            text:
                                'Oops! We couldn’t load the products.',
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            textAlign: TextAlign.center,
                          ),

                          SizedBox(height: 8.h),

                          CustomText(
                            text:
                                'Please check your internet connection and give it another try.',
                            fontSize: 14.sp,
                            textAlign: TextAlign.center,
                          ),

                          SizedBox(height: 16.h),

                          // ENHANCEMENT: Retry loading products
                          ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                _productsFuture =
                                    ProductService()
                                        .getAllProducts();
                              });
                            },
                            icon: const Icon(
                              Icons.refresh,
                            ),
                            label: const Text(
                              'Try Again',
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final products =
                    snapshot.data ?? [];

                // ENHANCEMENT 1: Filter products
                // based on the search query
                final filteredProducts =
                    products.where((product) {
                  return product.title
                      .toLowerCase()
                      .contains(_searchQuery);
                }).toList();

                if (filteredProducts.isEmpty) {
                  return Center(
                    child: Padding(
                      padding:
                          EdgeInsets.all(32.r),
                      child: CustomText(
                        text: _searchQuery.isEmpty
                            ? 'No products found.'
                            : 'No products found for '
                                '"$_searchQuery".',
                        fontSize: 14.sp,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                return GridView.builder(
                  shrinkWrap: true,
                  physics:
                      const NeverScrollableScrollPhysics(),
                  itemCount:
                      filteredProducts.length,
                  gridDelegate:
                      SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10.w,
                    mainAxisSpacing: 10.h,
                    childAspectRatio: 0.75,
                  ),
                  itemBuilder:
                      (context, index) {
                    final product =
                        filteredProducts[index];

                    // ENHANCEMENT 2:
                    // Make the product card clickable
                    return InkWell(
                      borderRadius:
                          BorderRadius.circular(12.r),

                      onTap: () {
                        // ENHANCEMENT 2:
                        // Open the product details page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ProductDetailScreen(
                              product: product,
                            ),
                          ),
                        );
                      },

                      child: Card(
                        elevation: 2,
                        clipBehavior:
                            Clip.antiAlias,
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                                  12.r),
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            Expanded(
                              child: Image.network(
                                product.thumbnail,
                                fit: BoxFit.cover,
                                width:
                                    double.infinity,
                                errorBuilder:
                                    (context, error,
                                        stackTrace) {
                                  return Center(
                                    child: Icon(
                                      Icons.image,
                                      size: 24.sp,
                                    ),
                                  );
                                },
                              ),
                            ),

                            Padding(
                              padding:
                                  EdgeInsets.all(8.r),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [
                                  CustomText(
                                    text:
                                        product.title,
                                    fontSize: 14.sp,
                                    fontWeight:
                                        FontWeight.bold,
                                    maxLines: 1,
                                    overflow:
                                        TextOverflow
                                            .ellipsis,
                                  ),

                                  SizedBox(height: 4.h),

                                  CustomText(
                                    text:
                                        '\$${product.price.toStringAsFixed(2)}',
                                    fontSize: 13.sp,
                                    fontWeight:
                                        FontWeight.w600,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
