import 'package:flutter/material.dart';
import '../../services/product_service.dart';
import '../../models/product_model.dart';
import '../products/product_detail_screen.dart';
import '../../widgets/common/promo_banner_carousel.dart';
import '../../widgets/common/category_chips.dart';
import '../../widgets/common/shimmer_widgets.dart';
import '../../widgets/product/product_card.dart';
import '../products/products_screen.dart';

const _primary = Color(0xFF2E7D32);
const _primaryLight = Color(0xFF4CAF50);
const _textDark = Color(0xFF1A1A1A);
const _textLight = Color(0xFF757575);
const _cardBg = Color(0xFFFFFFFF);
const _borderLight = Color(0xFFEEEEEE);

class HomeScreen extends StatefulWidget {
  /// Callback so HomeScreen can ask MainNavigationScreen to switch tabs.
  final void Function(int)? onNavigateToTab;

  const HomeScreen({super.key, this.onNavigateToTab});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  List<Product>? _allProducts;
  List<Product> _filteredProducts = [];
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final products = await ProductService().fetchProducts();
      if (!mounted) return;
      setState(() {
        _allProducts = products;
        _filteredProducts = products;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      _filteredProducts = query.isEmpty
          ? (_allProducts ?? [])
          : (_allProducts ?? []).where((p) {
              return p.name.toLowerCase().contains(query) ||
                  (p.category?.toLowerCase().contains(query) ?? false);
            }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      // ── No bottomNavigationBar here — it lives in MainNavigationScreen ──
      body: SafeArea(
        child: RefreshIndicator(
          color: _primary,
          onRefresh: _loadProducts,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAppBar(),
                const SizedBox(height: 12),
                _buildSearchBar(),
                const SizedBox(height: 20),
                if (_searchController.text.isNotEmpty) ...[
                  _buildSearchResults(),
                ] else ...[
                  const PromoBannerCarousel(),
                  const SizedBox(height: 24),
                  const CategoryChips(
                    onCategorySelected: null, // Handled internally
                  ),
                  const SizedBox(height: 24),
                  _buildSectionHeader(
                    'Best Sellers ⭐',
                    onSeeAll: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ProductsScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildHorizontalProductList(),
                  const SizedBox(height: 32),
                  _buildSectionHeader(
                    'New Arrivals 🆕',
                    onSeeAll: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ProductsScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildProductGrid(),
                  const SizedBox(height: 32),
                  _buildSectionHeader('Quick Actions', showSeeAll: false),
                  const SizedBox(height: 12),
                  _buildQuickActions(),
                  const SizedBox(height: 32),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('🌿', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 6),
                  Text(
                    'Hello there 👋',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: _textLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              const Text(
                'NutriBlend',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: _textDark,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                'Quality products for a healthier you',
                style: TextStyle(fontSize: 12, color: _textLight),
              ),
            ],
          ),
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(Icons.notifications_outlined,
                        size: 22, color: _textDark),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE53935),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // Tapping the avatar navigates to Profile tab (index 4)
              GestureDetector(
                onTap: () => widget.onNavigateToTab?.call(4),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: _primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _primary.withOpacity(0.2)),
                  ),
                  child: const Icon(
                    Icons.person_outline_rounded,
                    color: _primary,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Material(
              elevation: 0,
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocus,
                style: const TextStyle(fontSize: 14, color: _textDark),
                decoration: InputDecoration(
                  hintText: 'Search products, categories...',
                  hintStyle:
                      TextStyle(color: Colors.grey.shade400, fontSize: 14),
                  prefixIcon: const Icon(Icons.search_rounded,
                      color: _textDark, size: 20),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded,
                              color: Colors.black54, size: 18),
                          onPressed: _searchController.clear,
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                        color: Color(0xFFE0E0E0), width: 1.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                        color: Color(0xFFE0E0E0), width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                        const BorderSide(color: _primary, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: _primary,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: _primary.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.tune_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    String title, {
    VoidCallback? onSeeAll,
    bool showSeeAll = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: _textDark)),
          if (showSeeAll)
            GestureDetector(
              onTap: onSeeAll,
              child: const Text('See All →',
                  style: TextStyle(color: _primaryLight, fontSize: 13, fontWeight: FontWeight.w700)),
            ),
        ],
      ),
    );
  }

  // ─── Horizontal Product List ──────────────────────────────────────────────

  Widget _buildHorizontalProductList() {
    if (_isLoading) {
      return SizedBox(
        height: 190,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: 4,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (_, __) => const CompactProductCardSkeleton(),
        ),
      );
    }
    if (_errorMessage.isNotEmpty) return _buildError();
    final products = (_allProducts ?? []).take(6).toList();
    if (products.isEmpty) return _buildEmpty();

    return SizedBox(
      height: 210,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: products.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (ctx, i) => ProductCard(
          product: products[i],
          onTap: () => _goToDetail(ctx, products[i]),
        ),
      ),
    );
  }

  // ─── Product Grid ─────────────────────────────────────────────────────────

  Widget _buildProductGrid() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: CompactProductGridSkeleton(),
      );
    }
    if (_errorMessage.isNotEmpty) return _buildError();
    final products = (_allProducts ?? []).reversed.take(6).toList();
    if (products.isEmpty) return _buildEmpty();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, childAspectRatio: 0.75,
          crossAxisSpacing: 12, mainAxisSpacing: 12,
        ),
        itemCount: products.length,
        itemBuilder: (ctx, i) => CompactProductGridCard(
          product: products[i],
          onTap: () => _goToDetail(ctx, products[i]),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Results (${_filteredProducts.length})',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: _textDark)),
              Text('for "${_searchController.text}"',
                  style: const TextStyle(color: _textLight, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 16),
          if (_filteredProducts.isEmpty)
            _buildNoResults()
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, childAspectRatio: 0.75,
                crossAxisSpacing: 12, mainAxisSpacing: 12,
              ),
              itemCount: _filteredProducts.length,
              itemBuilder: (ctx, i) => CompactProductGridCard(
                product: _filteredProducts[i],
                onTap: () => _goToDetail(ctx, _filteredProducts[i]),
              ),
            ),
          const SizedBox(height: 28),
        ],
      ),
    );
  }

  // ─── Quick Actions ────────────────────────────────────────────────────────
  // FIX: Replaced Container with fixed right margin inside a Row with
  // Expanded children. Using minmax(0, 1fr) semantics in Flutter means each
  // tile gets exactly 1 equal share of available width with zero overflow risk.

  Widget _buildQuickActions() {
    final actions = [
      _QuickActionData(Icons.shopping_bag_outlined, 'My Orders', 'Track & manage', null),
      _QuickActionData(Icons.local_offer_outlined,  'Deals',     'Save more',      null),
      _QuickActionData(Icons.favorite_outlined,     'Wishlist',  'Saved items',    2),   // → tab 2
      _QuickActionData(Icons.support_agent_rounded, 'Support',   "We're here",     null),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: List.generate(actions.length, (index) {
          final a = actions[index];
          final isLast = index == actions.length - 1;
          return Expanded(
            // FIX: Expanded ensures every tile is exactly (available width / 4).
            // The old code used a fixed right margin on a non-Expanded container
            // which could push the row wider than the screen on small devices.
            child: GestureDetector(
              onTap: () {
                if (a.tabIndex != null) {
                  widget.onNavigateToTab?.call(a.tabIndex!);
                }
              },
              child: Container(
                margin: EdgeInsets.only(right: isLast ? 0 : 10),
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _borderLight, width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(a.icon, color: _primaryLight, size: 26),
                    const SizedBox(height: 8),
                    Text(a.label, textAlign: TextAlign.center,
                        style: const TextStyle(color: _textDark, fontSize: 11, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(a.sub, textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  void _goToDetail(BuildContext ctx, Product product) {
    Navigator.push(ctx,
        MaterialPageRoute(
            builder: (_) => ProductDetailScreen(product: product)));
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        child: Column(
          children: [
            const Icon(Icons.wifi_off_rounded, size: 40, color: Colors.grey),
            const SizedBox(height: 12),
            Text(
              _errorMessage,
              style: const TextStyle(color: Colors.redAccent, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: _loadProducts,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() => const Center(
    child: Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Text('No products available.', style: TextStyle(color: Colors.grey)),
    ),
  );

  Widget _buildNoResults() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 52,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 16),
            const Text('No products found',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _textDark)),
            const SizedBox(height: 6),
            Text(
              'Try a different search term',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _searchController.clear,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Clear Search'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryLight,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== COMPACT PRODUCT CARDS ====================

/// Compact horizontal product card (smaller, professional)
class CompactProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const CompactProductCard({
    super.key,
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _borderLight, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image area (smaller)
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: Image.network(
                product.image ?? '',
                height: 100,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 100,
                  color: Colors.grey.shade100,
                  child: const Icon(
                    Icons.image_not_supported,
                    size: 32,
                    color: Colors.grey,
                  ),
                ),
                loadingBuilder: (_, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    height: 100,
                    color: Colors.grey.shade100,
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  if (product.category != null)
                    Text(
                      product.category!,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        product.formattedPrice,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
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
}

/// Compact grid product card (vertical, smaller)
class CompactProductGridCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const CompactProductGridCard({
    super.key,
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _borderLight, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image area
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: Image.network(
                product.image ?? '',
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 120,
                  color: Colors.grey.shade100,
                  child: const Icon(
                    Icons.image_not_supported,
                    size: 40,
                    color: Colors.grey,
                  ),
                ),
                loadingBuilder: (_, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    height: 120,
                    color: Colors.grey.shade100,
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  if (product.category != null)
                    Text(
                      product.category!,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        product.formattedPrice,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: _primary,
                        ),
                      ),
                      // If there's a previous price to show, ensure Product exposes it
                      // Currently Product has no `oldPrice` getter, so omit the old price display.
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Quick add button (optional)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primary.withOpacity(0.1),
                        foregroundColor: _primary,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        minimumSize: Size.zero,
                      ),
                      child: const Text(
                        'View',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
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

// ==================== SKELETON LOADERS ====================

class CompactProductCardSkeleton extends StatelessWidget {
  const CompactProductCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderLight, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 100, height: 12, color: Colors.grey.shade200),
                const SizedBox(height: 6),
                Container(width: 80, height: 10, color: Colors.grey.shade200),
                const SizedBox(height: 6),
                Container(width: 60, height: 14, color: Colors.grey.shade200),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CompactProductGridSkeleton extends StatelessWidget {
  const CompactProductGridSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.68,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: 4,
      itemBuilder: (_, __) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _borderLight, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 14,
                    color: Colors.grey.shade200,
                  ),
                  const SizedBox(height: 6),
                  Container(width: 80, height: 12, color: Colors.grey.shade200),
                  const SizedBox(height: 8),
                  Container(
                    width: 100,
                    height: 16,
                    color: Colors.grey.shade200,
                  ),
                  const SizedBox(height: 8),
                  Container(height: 28, color: Colors.grey.shade200),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionData {
  final IconData icon;
  final String label;
  final String sub;
  final int? tabIndex;
  const _QuickActionData(this.icon, this.label, this.sub, this.tabIndex);
}
