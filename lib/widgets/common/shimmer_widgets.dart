import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/app_theme.dart';

/// ===============================
/// SAFE SHIMMER BOX
/// ===============================
class ShimmerBox extends StatelessWidget {
  final double? width;
  final double height;
  final double radius;

  const ShimmerBox({
    super.key,
    this.width,
    required this.height,
    this.radius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppTheme.shimmerBase,
      highlightColor: AppTheme.shimmerHighlight,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppTheme.shimmerBase,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

/// ===============================
/// PRODUCT CARD SKELETON
/// ===============================
class ProductCardSkeleton extends StatelessWidget {
  const ProductCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerBox(
            height: 140,
            radius: 16,
          ),

          const SizedBox(height: 10),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                ShimmerBox(height: 14),
                SizedBox(height: 6),
                ShimmerBox(width: 100, height: 12),
                SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ShimmerBox(width: 70, height: 16),
                    ShimmerBox(width: 36, height: 36, radius: 10),
                  ],
                ),

                SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ===============================
/// PRODUCT GRID SKELETON
/// ===============================
class ProductGridSkeleton extends StatelessWidget {
  const ProductGridSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
      ),
      itemCount: 6,
      itemBuilder: (_, __) => const ProductCardSkeleton(),
    );
  }
}

/// ===============================
/// CART ITEM SKELETON
/// ===============================
class CartItemSkeleton extends StatelessWidget {
  const CartItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: AppTheme.cardDecoration,
      child: Row(
        children: const [
          ShimmerBox(width: 72, height: 72, radius: 12),
          SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(height: 14),
                SizedBox(height: 8),
                ShimmerBox(width: 80, height: 12),
                SizedBox(height: 10),
                ShimmerBox(width: 120, height: 32, radius: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}