import 'package:flutter/material.dart';
import '../../services/product_service.dart';
import '../../models/product_model.dart';
import '../products/product_detail_screen.dart';
import '../../widgets/common/promo_banner_carousel.dart';
import '../../widgets/common/category_chips.dart';
import '../../widgets/common/shimmer_widgets.dart';
import '../../widgets/product/product_card.dart';
import '../../widgets/nutrition/nutrition_tip_banner.dart';

const _primary = Color(0xFF2E7D32);
const _primaryLight = Color(0xFF4CAF50);
const _textDark = Color(0xFF1A1A1A);
const _textLight = Color(0xFF757575);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Product>? _allProducts;
  List<Product> _filteredProducts = [];
  bool _isLoading = false;
  String _errorMessage = '';
  int _navIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    if (!mounted) return;
    setState(() { _isLoading = true; _errorMessage = ''; });
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
      setState(() { _errorMessage = e.toString(); _isLoading = false; });
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
      body: SafeArea(
        child: RefreshIndicator(
          color: _primary,
          onRefresh: _loadProducts,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── App Bar ────────────────────────────────────────────────
                _buildAppBar(),

                const SizedBox(height: 16),

                // ── Search Bar ─────────────────────────────────────────────
                _buildSearchBar(),

                const SizedBox(height: 20),

                if (_searchController.text.isNotEmpty) ...[
                  _buildSearchResults(),
                ] else ...[
                  // ── Promo Banner Carousel ────────────────────────────────
                  const PromoBannerCarousel(),

                  const SizedBox(height: 20),

                  // ── Category Chips ───────────────────────────────────────
                  CategoryChips(
                    onCategorySelected: (cat) {
                      if (cat == 'All') {
                        setState(() => _filteredProducts = _allProducts ?? []);
                      } else {
                        setState(() {
                          _filteredProducts = (_allProducts ?? [])
                              .where((p) => p.category?.toLowerCase()
                                  .contains(cat.toLowerCase()) ?? false)
                              .toList();
                        });
                      }
                    },
                  ),

                  const SizedBox(height: 28),

                  // ── Featured / Best Sellers ──────────────────────────────
                  _buildSectionHeader('Best Sellers ⭐', onSeeAll: () {}),
                  const SizedBox(height: 14),
                  _buildHorizontalProductList(),

                  const SizedBox(height: 28),

                  // ── Nutrition Tip Banner ─────────────────────────────────
                  const NutritionTipBanner(),

                  const SizedBox(height: 28),

                  // ── New Arrivals Grid ────────────────────────────────────
                  _buildSectionHeader('New Arrivals 🆕', onSeeAll: () {}),
                  const SizedBox(height: 14),
                  _buildProductGrid(),

                  const SizedBox(height: 28),

                  // ── Quick Actions ────────────────────────────────────────
                  _buildSectionHeader('Quick Actions', showSeeAll: false),
                  const SizedBox(height: 14),
                  _buildQuickActions(),

                  const SizedBox(height: 28),
                ],
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ─── App Bar ──────────────────────────────────────────────────────────────

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
              // Notification bell
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(Icons.notifications_outlined, size: 22, color: _textDark),
                    Positioned(
                      top: 8,
                      right: 8,
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
              // Avatar
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: _primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _primary.withOpacity(0.2)),
                ),
                child: const Icon(Icons.person_outline_rounded, color: _primary, size: 22),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Search Bar ───────────────────────────────────────────────────────────

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE0E0E0), width: 1.5),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(fontSize: 14, color: _textDark),
                decoration: InputDecoration(
                  hintText: 'Search products, categories...',
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                  prefixIcon: const Icon(Icons.search_rounded, color: _textDark, size: 20),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, color: Colors.black54, size: 18),
                          onPressed: _searchController.clear,
                        )
                      : null,
                  border: InputBorder.none,
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
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.tune_rounded, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  // ─── Section Header ───────────────────────────────────────────────────────

  Widget _buildSectionHeader(String title, {VoidCallback? onSeeAll, bool showSeeAll = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: _textDark),
          ),
          if (showSeeAll)
            GestureDetector(
              onTap: onSeeAll,
              child: const Text(
                'See All →',
                style: TextStyle(color: _primaryLight, fontSize: 13, fontWeight: FontWeight.w700),
              ),
            ),
        ],
      ),
    );
  }

  // ─── Horizontal Product List (Best Sellers) ───────────────────────────────

  Widget _buildHorizontalProductList() {
    if (_isLoading) return const ShimmerHorizontalList();
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

  // ─── Product Grid (New Arrivals) ──────────────────────────────────────────

  Widget _buildProductGrid() {
    if (_isLoading) return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: const ShimmerProductGrid(count: 4),
    );
    if (_errorMessage.isNotEmpty) return _buildError();
    final products = (_allProducts ?? []).reversed.take(4).toList();
    if (products.isEmpty) return _buildEmpty();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: products.length,
        itemBuilder: (ctx, i) => ProductGridCard(
          product: products[i],
          onTap: () => _goToDetail(ctx, products[i]),
        ),
      ),
    );
  }

  // ─── Search Results ───────────────────────────────────────────────────────

  Widget _buildSearchResults() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Results (${_filteredProducts.length})',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: _textDark),
              ),
              Text(
                'for "${_searchController.text}"',
                style: const TextStyle(color: _textLight, fontSize: 13),
              ),
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
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _filteredProducts.length,
              itemBuilder: (ctx, i) => ProductGridCard(
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

  Widget _buildQuickActions() {
    final actions = [
      _QuickActionData(Icons.shopping_bag_outlined, 'My Orders', 'Track & manage'),
      _QuickActionData(Icons.local_offer_outlined, 'Deals', 'Save more'),
      _QuickActionData(Icons.history_rounded, 'History', 'Quick access'),
      _QuickActionData(Icons.support_agent_rounded, 'Support', "We're here"),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: actions.map((a) => Expanded(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              margin: EdgeInsets.only(right: a != actions.last ? 10 : 0),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE0E0E0), width: 1.5),
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
        )).toList(),
      ),
    );
  }

  // ─── Bottom Nav ───────────────────────────────────────────────────────────

  Widget _buildBottomNav() {
    final items = [
      _NavItem(Icons.home_filled, Icons.home_outlined, 'Home'),
      _NavItem(Icons.grid_view_rounded, Icons.grid_view_outlined, 'Categories'),
      _NavItem(Icons.favorite_rounded, Icons.favorite_border_rounded, 'Wishlist'),
      _NavItem(Icons.shopping_cart_rounded, Icons.shopping_cart_outlined, 'Cart', badge: 2),
      _NavItem(Icons.person_rounded, Icons.person_outline_rounded, 'Account'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final selected = i == _navIndex;
              final item = items[i];
              return GestureDetector(
                onTap: () => setState(() => _navIndex = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: selected ? _primary.withOpacity(0.1) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Icon(
                            selected ? item.activeIcon : item.icon,
                            color: selected ? _primary : Colors.grey.shade500,
                            size: 24,
                          ),
                          if (item.badge != null)
                            Positioned(
                              right: -6,
                              top: -4,
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: const BoxDecoration(color: Color(0xFFE53935), shape: BoxShape.circle),
                                child: Text(
                                  item.badge.toString(),
                                  style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                          color: selected ? _primary : Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  void _goToDetail(BuildContext ctx, Product product) {
    Navigator.push(ctx, MaterialPageRoute(builder: (_) => ProductDetailPage(product: product)));
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        child: Column(
          children: [
            const Icon(Icons.wifi_off_rounded, size: 40, color: Colors.grey),
            const SizedBox(height: 12),
            Text(_errorMessage, style: const TextStyle(color: Colors.redAccent, fontSize: 13), textAlign: TextAlign.center),
            const SizedBox(height: 12),
            TextButton.icon(onPressed: _loadProducts, icon: const Icon(Icons.refresh_rounded), label: const Text('Retry')),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Text('No products available.', style: TextStyle(color: Colors.grey)),
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.grey.withOpacity(0.08), shape: BoxShape.circle),
              child: Icon(Icons.search_off_rounded, size: 52, color: Colors.grey.shade400),
            ),
            const SizedBox(height: 16),
            const Text('No products found', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _textDark)),
            const SizedBox(height: 6),
            Text('Try a different search term', style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _searchController.clear,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Clear Search'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryLight,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Data Classes ─────────────────────────────────────────────────────────────

class _QuickActionData {
  final IconData icon;
  final String label;
  final String sub;
  const _QuickActionData(this.icon, this.label, this.sub);
}

class _NavItem {
  final IconData activeIcon;
  final IconData icon;
  final String label;
  final int? badge;
  const _NavItem(this.activeIcon, this.icon, this.label, {this.badge});
}