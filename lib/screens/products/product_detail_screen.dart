import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../models/product_model.dart';

const _primary = Color(0xFF2E7D32);
const _primaryLight = Color(0xFF4CAF50);
const _textDark = Color(0xFF1A1A1A);
const _textLight = Color(0xFF757575);
const _divider = Color(0xFFEEEEEE);

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;
  bool _isWishlisted = false;
  bool _isAddingToCart = false;
  bool _descriptionExpanded = false;

  Product get product => widget.product;

  Future<void> _handleAddToCart() async {
    setState(() => _isAddingToCart = true);

    // ✅ Add to CartProvider
    final cart = context.read<CartProvider>();
    for (int i = 0; i < _quantity; i++) {
      cart.addProduct(product);
    }

    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    setState(() => _isAddingToCart = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '${product.name} added to cart!',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: _primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'View Cart',
          textColor: Colors.white,
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: CustomScrollView(
        slivers: [
          // ── Hero Image App Bar ───────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  // Product image
                  Container(
                    color: _primary.withOpacity(0.05),
                    child: product.image != null
                        ? Padding(
                            padding: const EdgeInsets.all(24),
                            child: Image.network(
                              product.image!,
                              fit: BoxFit.contain,
                              loadingBuilder: (_, child, p) => p == null
                                  ? child
                                  : const Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation(_primary),
                                      ),
                                    ),
                              errorBuilder: (_, __, ___) => _buildPlaceholder(),
                            ),
                          )
                        : _buildPlaceholder(),
                  ),
                  // Category badge
                  if (product.category != null)
                    Positioned(
                      bottom: 16,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: _primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          product.category!,
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Action buttons on app bar
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)],
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: _textDark),
              ),
            ),
            actions: [
              // Wishlist
              GestureDetector(
                onTap: () => setState(() => _isWishlisted = !_isWishlisted),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)],
                  ),
                  child: Icon(
                    _isWishlisted ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    size: 20,
                    color: _isWishlisted ? Colors.red : _textDark,
                  ),
                ),
              ),
              // Share
              Container(
                margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)],
                ),
                child: const Icon(Icons.share_outlined, size: 20, color: _textDark),
              ),
            ],
          ),

          // ── Product Info ─────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Name & Price ─────────────────────────────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: _textDark,
                            height: 1.3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        product.formattedPrice,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: _primary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // ── Rating & Stock ───────────────────────────────────────
                  Row(
                    children: [
                      if (product.rating != null) ...[
                        const Icon(Icons.star_rounded, size: 16, color: Color(0xFFFFC107)),
                        const SizedBox(width: 4),
                        Text(
                          product.rating!.toStringAsFixed(1),
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _textDark),
                        ),
                        if (product.reviewCount != null) ...[
                          const SizedBox(width: 4),
                          Text(
                            '(${product.reviewCount} reviews)',
                            style: const TextStyle(fontSize: 12, color: _textLight),
                          ),
                        ],
                        const SizedBox(width: 16),
                      ],
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: product.inStock
                              ? _primary.withOpacity(0.1)
                              : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              product.inStock
                                  ? Icons.check_circle_outline_rounded
                                  : Icons.cancel_outlined,
                              size: 12,
                              color: product.inStock ? _primary : Colors.red,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              product.inStock ? 'In Stock' : 'Out of Stock',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: product.inStock ? _primary : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  const Divider(color: _divider),
                  const SizedBox(height: 20),

                  // ── Description ──────────────────────────────────────────
                  const Text(
                    'Description',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _textDark),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    (product.description != null && product.description!.isNotEmpty)
                        ? product.description!
                        : 'No description available for this product.',
                    style: const TextStyle(color: _textLight, fontSize: 14, height: 1.6),
                    maxLines: _descriptionExpanded ? null : 3,
                    overflow: _descriptionExpanded ? null : TextOverflow.ellipsis,
                  ),
                  if (product.description != null && product.description!.length > 120)
                    GestureDetector(
                      onTap: () => setState(() => _descriptionExpanded = !_descriptionExpanded),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          _descriptionExpanded ? 'Show less' : 'Read more',
                          style: const TextStyle(
                            color: _primaryLight,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 20),
                  const Divider(color: _divider),
                  const SizedBox(height: 20),

                  // ── Quantity Selector ────────────────────────────────────
                  Row(
                    children: [
                      const Text(
                        'Quantity',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _textDark),
                      ),
                      const Spacer(),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            // Minus
                            GestureDetector(
                              onTap: () {
                                if (_quantity > 1) setState(() => _quantity--);
                              },
                              child: Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: _quantity > 1 ? _primary : Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.remove_rounded, color: Colors.white, size: 18),
                              ),
                            ),
                            // Count
                            SizedBox(
                              width: 44,
                              child: Text(
                                _quantity.toString(),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: _textDark,
                                ),
                              ),
                            ),
                            // Plus
                            GestureDetector(
                              onTap: () => setState(() => _quantity++),
                              child: Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: _primary,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.add_rounded, color: Colors.white, size: 18),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  const Divider(color: _divider),
                  const SizedBox(height: 20),

                  // ── Why NutriBlend ───────────────────────────────────────
                  const Text(
                    'Why NutriBlend?',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _textDark),
                  ),
                  const SizedBox(height: 12),
                  _buildFeatureTile(Icons.verified_outlined, 'Premium Quality', 'Lab-tested and expert approved'),
                  _buildFeatureTile(Icons.eco_outlined, 'Natural Ingredients', 'No artificial additives'),
                  _buildFeatureTile(Icons.local_shipping_outlined, 'Fast Delivery', 'Delivered to your doorstep'),

                  const SizedBox(height: 100), // space for bottom bar
                ],
              ),
            ),
          ),
        ],
      ),

      // ── Bottom Add to Cart Bar ─────────────────────────────────────────────
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, -4))],
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Total price
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total', style: TextStyle(fontSize: 12, color: _textLight)),
                  const SizedBox(height: 2),
                  Text(
                    product.formattedPrice,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: _primary),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              // Add to Cart button
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: product.inStock && !_isAddingToCart ? _handleAddToCart : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade300,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _isAddingToCart
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.shopping_cart_outlined, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                product.inStock ? 'Add to Cart' : 'Out of Stock',
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: _primary.withOpacity(0.06),
      child: const Center(child: Icon(Icons.spa_outlined, size: 80, color: _primary)),
    );
  }

  Widget _buildFeatureTile(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: _primary, size: 18),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _textDark)),
              Text(subtitle, style: const TextStyle(fontSize: 12, color: _textLight)),
            ],
          ),
        ],
      ),
    );
  }
}