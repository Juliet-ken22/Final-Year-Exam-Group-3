import 'package:flutter/material.dart';
import '../common/shimmer_widgets.dart';
import 'package:shimmer/shimmer.dart';
class ProductShimmer extends StatelessWidget {
  const ProductShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Shimmer.fromColors(
          baseColor: const Color(0xFFE0E0E0),
          highlightColor: const Color(0xFFF5F5F5),
          child: Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),

        const SizedBox(height: 8),

        Shimmer.fromColors(
          baseColor: const Color(0xFFE0E0E0),
          highlightColor: const Color(0xFFF5F5F5),
          child: Container(
            width: 50,
            height: 10,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        ),
      ],
    );
  }
}