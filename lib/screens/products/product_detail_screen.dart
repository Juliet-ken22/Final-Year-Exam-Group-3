import 'package:flutter/material.dart';
import '../../models/product_model.dart';

const _primary = Color(0xFF2D6A4F);
const _textDark = Color(0xFF1A1A1A);
const _textLight = Color(0xFF757575);
const _divider = Color(0xFFEEEEEE);

class ProductDetailPage extends StatelessWidget {
  final Product product;

  const ProductDetailPage({super.key, required this.product});

  // ← removed "static" so it works inside build()
  Widget _placeholder() {
    return Container(
      color: const Color(0xFF2D6A4F).withOpacity(0.08),
      child: const Center(
        child: Icon(Icons.spa_outlined, size: 80, color: Color(0xFF2D6A4F)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: Colors.white,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Icon(Icons.arrow_back, size: 20),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: const Color(0xFF2D6A4F).withOpacity(0.06),
                child: product.image != null
                    ? Padding(
                        padding: const EdgeInsets.all(24),
                        child: Image.network(
                          product.image!,
                          fit: BoxFit.contain,
                          loadingBuilder: (ctx, child, p) => p == null
                              ? child
                              : const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Color(0xFF2D6A4F),
                                    ),
                                  ),
                                ),
                          errorBuilder: (_, _, _) => _placeholder(),
                        ),
                      )
                    : _placeholder(),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name & Price
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: _textDark,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        product.formattedPrice,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: _primary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  const Divider(color: _divider),
                  const SizedBox(height: 24),

                  // Description
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _textDark,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    (product.description != null &&
                            product.description!.isNotEmpty)
                        ? product.description!
                        : 'No description available for this product.',
                    style: const TextStyle(
                      color: _textLight,
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Add to Cart button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Add to Cart',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
