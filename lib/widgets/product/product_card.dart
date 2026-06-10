import 'package:flutter/material.dart';
import '../../models/product_model.dart';

const _primary = Color(0xFF2E7D32);
const _primaryLight = Color(0xFF4CAF50);
const _textDark = Color(0xFF1A1A1A);
const _textLight = Color(0xFF757575);

// ─── ProductCard (Best Sellers - horizontal list) - NO OVERFLOW ─────────────

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final double width;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.width = 140,
  });

  double get _rating {
    if (product.rating != null && product.rating! > 0) {
      return product.rating!;
    }
    return 4.0 + ((product.id % 10) / 10.0);
  }

  int get _reviewCount {
    if (product.reviewCount != null && product.reviewCount! > 0) {
      return product.reviewCount!;
    }
    return (product.id % 50) + 10;
  }

  Widget _buildRatingStars(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (index < rating.floor()) {
          return const Icon(Icons.star, size: 10, color: Color(0xFFFFC107));
        } else if (index < rating) {
          return const Icon(Icons.star_half, size: 10, color: Color(0xFFFFC107));
        } else {
          return const Icon(Icons.star_border, size: 10, color: Color(0xFFFFC107));
        }
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE0E0E0), width: 0.8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fixed image at top - height reduced to 100
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 100,
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
              
              // Content - Using Expanded with spaceBetween
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Top content group
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (product.category != null)
                            Text(
                              product.category!.toUpperCase(),
                              style: const TextStyle(
                                color: _primaryLight,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.4,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          const SizedBox(height: 4),
                          Text(
                            product.name,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: _textDark,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              _buildRatingStars(_rating),
                              const SizedBox(width: 4),
                              Text(
                                _rating.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  color: _textLight,
                                ),
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '($_reviewCount)',
                                style: const TextStyle(
                                  fontSize: 8,
                                  color: _textLight,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      
                      // Bottom content - Price with overflow protection
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              product.formattedPrice,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: _primary,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: _primary.withOpacity(0.10),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(
                              Icons.add_shopping_cart_rounded,
                              size: 14,
                              color: _primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: _primaryLight.withOpacity(0.05),
      child: const Center(
        child: Icon(Icons.spa_rounded, color: _primaryLight, size: 30),
      ),
    );
  }
}

// ─── ProductGridCard (New Arrivals - grid) - NO OVERFLOW ────────────────────

class ProductGridCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;

  const ProductGridCard({super.key, required this.product, this.onTap});

  double get _rating {
    if (product.rating != null && product.rating! > 0) {
      return product.rating!;
    }
    return 4.0 + ((product.id % 10) / 10.0);
  }

  int get _reviewCount {
    if (product.reviewCount != null && product.reviewCount! > 0) {
      return product.reviewCount!;
    }
    return (product.id % 50) + 10;
  }

  Widget _buildRatingStars(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (index < rating.floor()) {
          return const Icon(Icons.star, size: 10, color: Color(0xFFFFC107));
        } else if (index < rating) {
          return const Icon(Icons.star_half, size: 10, color: Color(0xFFFFC107));
        } else {
          return const Icon(Icons.star_border, size: 10, color: Color(0xFFFFC107));
        }
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE0E0E0), width: 0.8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fixed image at top - height reduced to 100
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 100,
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
            
            // Content - Using Expanded with spaceBetween
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top content group
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (product.category != null)
                          Text(
                            product.category!.toUpperCase(),
                            style: const TextStyle(
                              color: _primaryLight,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.4,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        const SizedBox(height: 4),
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: _textDark,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            _buildRatingStars(_rating),
                            const SizedBox(width: 4),
                            Text(
                              _rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: _textLight,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '($_reviewCount)',
                              style: const TextStyle(
                                fontSize: 8,
                                color: _textLight,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    
                    // Bottom content - Price with overflow protection
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            product.formattedPrice,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: _primary,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: _primary.withOpacity(0.10),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.add_shopping_cart_rounded,
                            size: 14,
                            color: _primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
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
        child: Icon(Icons.spa_rounded, color: _primaryLight, size: 30),
      ),
    );
  }
}