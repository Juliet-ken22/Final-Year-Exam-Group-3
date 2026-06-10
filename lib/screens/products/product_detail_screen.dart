import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../models/product_model.dart';

const _primary = Color(0xFF2E7D32);
const _primaryLight = Color(0xFF4CAF50);
const _textDark = Color(0xFF1A1A1A);
const _textLight = Color(0xFF757575);
const _divider = Color(0xFFEEEEEE);
const _border = Color(0xFFE0E0E0);

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
            const Icon(Icons.check_circle_rounded,
                color: Colors.white, size: 18),
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
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

  Widget _buildRatingStars(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (index < rating.floor()) {
          return const Icon(Icons.star, size: 14, color: Color(0xFFFFC107));
        } else if (index < rating) {
          return const Icon(Icons.star_half, size: 14, color: Color(0xFFFFC107));
        } else {
          return const Icon(Icons.star_border, size: 14, color: Color(0xFFFFC107));
        }
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: CustomScrollView(
        slivers: [
          // Hero Section with Horizontal Layout
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: _primary.withOpacity(0.05),
                child: Row(
                  children: [
                    // Left side - Product Image
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: product.image != null
                            ? Image.network(
                                product.image!,
                                fit: BoxFit.contain,
                                loadingBuilder: (_, child, loadingProgress) =>
                                    loadingProgress == null
                                        ? child
                                        : const Center(
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation(_primary),
                                            ),
                                          ),
                                errorBuilder: (_, __, ___) => _buildPlaceholder(),
                              )
                            : _buildPlaceholder(),
                      ),
                    ),
                    
                    // Right side - Quick Info
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (product.category != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _primary,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  product.category!,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700),
                                ),
                              ),
                            const SizedBox(height: 12),
                            Text(
                              product.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: _textDark,
                                height: 1.3,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            if (product.rating != null) ...[
                              Row(
                                children: [
                                  _buildRatingStars(product.rating!),
                                  const SizedBox(width: 5),
                                  Text(
                                    product.rating!.toStringAsFixed(1),
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: _textDark),
                                  ),
                                  if (product.reviewCount != null) ...[
                                    const SizedBox(width: 4),
                                    Text(
                                      '(${product.reviewCount} reviews)',
                                      style: const TextStyle(
                                          fontSize: 11, color: _textLight),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 8),
                            ],
                            Text(
                              product.formattedPrice,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: _primary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 9, vertical: 4),
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
                                    size: 11,
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
                      ),
                    ),
                  ],
                ),
              ),
            ),
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.1), blurRadius: 8)
                  ],
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    size: 16, color: _textDark),
              ),
            ),
            actions: [
              GestureDetector(
                onTap: () => setState(() => _isWishlisted = !_isWishlisted),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8)
                    ],
                  ),
                  child: Icon(
                    _isWishlisted
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    size: 18,
                    color: _isWishlisted ? Colors.red : _textDark,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.1), blurRadius: 8)
                  ],
                ),
                child: const Icon(Icons.share_outlined,
                    size: 18, color: _textDark),
              ),
            ],
          ),

          // Detailed Info Section
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Description',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _textDark),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    (product.description != null &&
                            product.description!.isNotEmpty)
                        ? product.description!
                        : 'No description available for this product.',
                    style: const TextStyle(
                        color: _textLight, fontSize: 13, height: 1.6),
                    maxLines: _descriptionExpanded ? null : 3,
                    overflow: _descriptionExpanded
                        ? null
                        : TextOverflow.ellipsis,
                  ),
                  if (product.description != null &&
                      product.description!.length > 120)
                    GestureDetector(
                      onTap: () => setState(
                          () => _descriptionExpanded = !_descriptionExpanded),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Text(
                          _descriptionExpanded ? 'Show less' : 'Read more',
                          style: const TextStyle(
                            color: _primaryLight,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  const Divider(color: _divider),
                  const SizedBox(height: 14),

                  const Text(
                    'Product Details',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _textDark),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _border, width: 0.5),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        _buildDetailRow('Category', product.category ?? 'N/A'),
                        const Divider(height: 12),
                        _buildDetailRow('Availability', 
                            product.inStock ? 'In Stock' : 'Out of Stock'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: _divider),
                  const SizedBox(height: 14),

                  Row(
                    children: [
                      const Text(
                        'Quantity',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: _textDark),
                      ),
                      const Spacer(),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (_quantity > 1)
                                  setState(() => _quantity--);
                              },
                              child: Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: _quantity > 1
                                      ? _primary
                                      : Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(9),
                                ),
                                child: const Icon(Icons.remove_rounded,
                                    color: Colors.white, size: 16),
                              ),
                            ),
                            SizedBox(
                              width: 40,
                              child: Text(
                                _quantity.toString(),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: _textDark,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => setState(() => _quantity++),
                              child: Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: _primary,
                                  borderRadius: BorderRadius.circular(9),
                                ),
                                child: const Icon(Icons.add_rounded,
                                    color: Colors.white, size: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: _divider),
                  const SizedBox(height: 14),

                  const Text(
                    'Why NutriBlend?',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _textDark),
                  ),
                  const SizedBox(height: 10),
                  _buildFeatureTile(Icons.verified_outlined,
                      'Premium Quality', 'Lab-tested and expert approved'),
                  _buildFeatureTile(Icons.eco_outlined,
                      'Natural Ingredients', 'No artificial additives'),
                  _buildFeatureTile(Icons.local_shipping_outlined,
                      'Fast Delivery', 'Delivered to your doorstep'),
                  const SizedBox(height: 90),
                ],
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, -4))
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total',
                      style: TextStyle(fontSize: 11, color: _textLight)),
                  const SizedBox(height: 2),
                  Text(
                    product.formattedPrice,
                    style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: _primary),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: product.inStock && !_isAddingToCart
                        ? _handleAddToCart
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade300,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isAddingToCart
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2.5),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.shopping_cart_outlined,
                                  size: 18),
                              const SizedBox(width: 8),
                              Text(
                                product.inStock
                                    ? 'Add to Cart'
                                    : 'Out of Stock',
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700),
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
      child: const Center(
          child: Icon(Icons.spa_outlined, size: 72, color: _primary)),
    );
  }

  Widget _buildFeatureTile(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: _primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: _primary, size: 16),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _textDark)),
              Text(subtitle,
                  style: const TextStyle(fontSize: 11, color: _textLight)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _textDark,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: _textLight,
            ),
          ),
        ),
      ],
    );
  }
}