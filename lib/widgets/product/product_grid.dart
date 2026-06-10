import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import 'product_card.dart'; // adjust path if needed

class ProductGrid extends StatelessWidget {
  final List<Product> products;
  final Function(Product)? onTap;

  const ProductGrid({
    super.key,
    required this.products,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(12), // compact padding
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // 2 columns
        crossAxisSpacing: 10, // smaller spacing
        mainAxisSpacing: 10, // smaller spacing
        childAspectRatio: 0.72, // IMPORTANT: controls height
      ),
      itemBuilder: (context, index) {
        final product = products[index];

        return ProductCard(
          product: product,
          onTap: () {
            if (onTap != null) {
              onTap!(product);
            }
          },
        );
      },
    );
  }
}