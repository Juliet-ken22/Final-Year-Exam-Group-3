import 'package:flutter/material.dart';
import '../../models/product_model.dart';

const _primary = Color(0xFF2E7D32);
const _primaryLight = Color(0xFF4CAF50);
const _textDark = Color(0xFF1A1A1A);
const _textLight = Color(0xFF757575);

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final double width;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.width = 150, // Reduced from 160
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12), // Reduced from 16
          border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section - REDUCED HEIGHT
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 100, // Reduced from 120
                child: product.image != null
                    ? Image.network(
                        product.image!,
                        fit: BoxFit.cover,
                        loadingBuilder: (_, child, p) => p == null
                            ? child
                            : Container(
                                color: _primaryLight.withOpacity(0.05),
                                child: const Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation(_primaryLight),
                                    ),
                                  ),
                                ),
                              ),
                        errorBuilder: (_, __, ___) => _placeholder(),
                      )
                    : _placeholder(),
              ),
            ),

            // Info section - REDUCED PADDING
            Padding(
              padding: const EdgeInsets.all(8), // Reduced from 10
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (product.category != null)
                    Text(
                      product.category!.toUpperCase(),
                      style: const TextStyle(
                        color: _primaryLight,
                        fontSize: 8, // Reduced from 9
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 2), // Reduced from 3
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 11, // Reduced from 12
                      fontWeight: FontWeight.w700,
                      color: _textDark,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4), // Reduced from 6
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        product.formattedPrice,
                        style: const TextStyle(
                          fontSize: 12, // Reduced from 13
                          fontWeight: FontWeight.w900,
                          color: _primary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(4), // Reduced from 5
                        decoration: BoxDecoration(
                          color: _primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.add_shopping_cart_rounded,
                          size: 12, // Reduced from 14
                          color: _primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: _primaryLight.withOpacity(0.05),
      child: const Center(
        child: Icon(Icons.spa_rounded, color: _primaryLight, size: 32),
      ),
    );
  }
}

class ProductGridCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;

  const ProductGridCard({super.key, required this.product, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section with fixed height
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 120, // Reduced from 140
                child: product.image != null
                    ? Image.network(
                        product.image!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: _primaryLight.withOpacity(0.05),
                          child: const Center(
                            child: Icon(Icons.spa_rounded, color: _primaryLight, size: 32),
                          ),
                        ),
                      )
                    : Container(
                        color: _primaryLight.withOpacity(0.05),
                        child: const Center(
                          child: Icon(Icons.spa_rounded, color: _primaryLight, size: 32),
                        ),
                      ),
              ),
            ),
            // Protein badge
            if (product.category?.toLowerCase().contains('protein') == true)
              Padding(
                padding: const EdgeInsets.only(left: 8, top: 6),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '32g Protein',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            // Info section
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (product.category != null)
                    Text(
                      product.category!.toUpperCase(),
                      style: const TextStyle(
                        color: _primaryLight,
                        fontWeight: FontWeight.w700,
                        fontSize: 8,
                        letterSpacing: 0.5,
                      ),
                    ),
                  const SizedBox(height: 2),
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                      color: _textDark,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        product.formattedPrice,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          color: _primary,
                          fontSize: 12,
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 12,
                        color: _primaryLight,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}