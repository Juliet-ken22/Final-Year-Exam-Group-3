import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../models/product_model.dart';
import '../../services/product_service.dart';
import 'product_detail_screen.dart';

const _primary = Color(0xFF2E7D32);
const _primaryLight = Color(0xFF4CAF50);
const _textDark = Color(0xFF1A1A1A);
const _textLight = Color(0xFF757575);
const _border = Color(0xFFE0E0E0);

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ProductService _service = ProductService();

  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  List<String> _categories = ['All'];
  String _selectedCategory = 'All';
  String _sortBy = 'Default';
  bool _isLoading = true;
  bool _isGrid = true;
  String _errorMessage = '';

  final List<String> _sortOptions = [
    'Default',
    'Price: Low to High',
    'Price: High to Low',
    'Name: A to Z',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() { _isLoading = true; _errorMessage = ''; });
    try {
      final results = await Future.wait([
        _service.fetchProducts(),
        _service.fetchCategories(),
      ]);
      if (!mounted) return;
      final products = results[0] as List<Product>;
      final cats = results[1] as List<String>;
      setState(() {
        _allProducts = products;
        _filteredProducts = products;
        _categories = ['All', ...cats];
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _errorMessage = e.toString(); _isLoading = false; });
    }
  }

  void _applyFilters() {
    final query = _searchController.text.toLowerCase().trim();
    List<Product> result = _allProducts;

    // Category filter
    if (_selectedCategory != 'All') {
      result = result.where((p) =>
        p.category?.toLowerCase().contains(_selectedCategory.toLowerCase()) ?? false
      ).toList();
    }

    // Search filter
    if (query.isNotEmpty) {
      result = result.where((p) =>
        p.name.toLowerCase().contains(query) ||
        (p.category?.toLowerCase().contains(query) ?? false) ||
        (p.description?.toLowerCase().contains(query) ?? false)
      ).toList();
    }

    // Sort
    double _priceValue(Product p) {
      final normalized = p.formattedPrice.replaceAll(RegExp(r'[^0-9.]'), '');
      return double.tryParse(normalized) ?? 0;
    }

    switch (_sortBy) {
      case 'Price: Low to High':
        result.sort((a, b) => _priceValue(a).compareTo(_priceValue(b)));
        break;
      case 'Price: High to Low':
        result.sort((a, b) => _priceValue(b).compareTo(_priceValue(a)));
        break;
      case 'Name: A to Z':
        result.sort((a, b) => a.name.compareTo(b.name));
        break;
    }

    setState(() => _filteredProducts = result);
  }

  void _onCategorySelected(String cat) {
    setState(() => _selectedCategory = cat);
    _applyFilters();
  }

  void _onSortSelected(String sort) {
    setState(() => _sortBy = sort);
    _applyFilters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          children: [
            // ── App Bar ──────────────────────────────────────────────────
            _buildAppBar(),

            // ── Search Bar ───────────────────────────────────────────────
            _buildSearchBar(),

            const SizedBox(height: 12),

            // ── Category Chips ───────────────────────────────────────────
            _buildCategoryChips(),

            const SizedBox(height: 12),

            // ── Filter Row ───────────────────────────────────────────────
            _buildFilterRow(),

            const SizedBox(height: 12),

            // ── Product List ─────────────────────────────────────────────
            Expanded(
              child: RefreshIndicator(
                color: _primary,
                onRefresh: _loadData,
                child: _buildBody(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── App Bar ──────────────────────────────────────────────────────────────

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _border),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: _textDark),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('All Products', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: _textDark)),
                Text('Quality supplements for you', style: TextStyle(fontSize: 12, color: _textLight)),
              ],
            ),
          ),
          // Cart icon
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _border),
                ),
                child: const Icon(Icons.shopping_cart_outlined, size: 22, color: _textDark),
              ),
              Positioned(
                right: -4,
                top: -4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: Color(0xFFE53935), shape: BoxShape.circle),
                  child: const Text('2', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                ),
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
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _border, width: 1.5),
        ),
        child: TextField(
          controller: _searchController,
          style: const TextStyle(fontSize: 14, color: _textDark),
          decoration: InputDecoration(
            hintText: 'Search products...',
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            prefixIcon: const Icon(Icons.search_rounded, color: _textLight, size: 20),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded, size: 18, color: _textLight),
                    onPressed: () { _searchController.clear(); _applyFilters(); },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }

  // ─── Category Chips ───────────────────────────────────────────────────────

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final selected = _categories[i] == _selectedCategory;
          return GestureDetector(
            onTap: () => _onCategorySelected(_categories[i]),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? _primary : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: selected ? _primary : _border, width: 1.5),
              ),
              child: Text(
                _categories[i],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : _textLight,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ─── Filter Row ───────────────────────────────────────────────────────────

  Widget _buildFilterRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Results count
          Expanded(
            child: Text(
              _isLoading
                  ? 'Loading...'
                  : '${_filteredProducts.length} product${_filteredProducts.length != 1 ? 's' : ''} found',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _textLight),
            ),
          ),

          // Sort dropdown
          GestureDetector(
            onTap: _showSortSheet,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _border, width: 1.5),
              ),
              child: Row(
                children: [
                  const Icon(Icons.sort_rounded, size: 16, color: _textLight),
                  const SizedBox(width: 6),
                  Text(_sortBy, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _textDark)),
                  const SizedBox(width: 4),
                  const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: _textLight),
                ],
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Grid / List toggle
          GestureDetector(
            onTap: () => setState(() => _isGrid = !_isGrid),
            child: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _border, width: 1.5),
              ),
              child: Icon(
                _isGrid ? Icons.view_list_rounded : Icons.grid_view_rounded,
                size: 18,
                color: _textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Sort Bottom Sheet ────────────────────────────────────────────────────

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Sort by', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _textDark)),
            const SizedBox(height: 16),
            ..._sortOptions.map((opt) => ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(opt, style: TextStyle(
                fontSize: 14,
                fontWeight: _sortBy == opt ? FontWeight.w700 : FontWeight.w400,
                color: _sortBy == opt ? _primary : _textDark,
              )),
              trailing: _sortBy == opt
                  ? const Icon(Icons.check_rounded, color: _primary)
                  : null,
              onTap: () {
                Navigator.pop(context);
                _onSortSelected(opt);
              },
            )),
          ],
        ),
      ),
    );
  }

  // ─── Body ─────────────────────────────────────────────────────────────────

  Widget _buildBody() {
    if (_isLoading) return _buildShimmer();
    if (_errorMessage.isNotEmpty) return _buildError();
    if (_filteredProducts.isEmpty) return _buildEmpty();

    return _isGrid ? _buildGrid() : _buildList();
  }

  // ─── Grid View ────────────────────────────────────────────────────────────

  Widget _buildGrid() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _filteredProducts.length,
      itemBuilder: (ctx, i) => _ProductGridCard(
        product: _filteredProducts[i],
        onTap: () => _goToDetail(_filteredProducts[i]),
      ),
    );
  }

  // ─── List View ────────────────────────────────────────────────────────────

  Widget _buildList() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      itemCount: _filteredProducts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (ctx, i) => _ProductListCard(
        product: _filteredProducts[i],
        onTap: () => _goToDetail(_filteredProducts[i]),
      ),
    );
  }

  // ─── Shimmer ──────────────────────────────────────────────────────────────

  Widget _buildShimmer() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: 6,
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: const Color(0xFFE0E0E0),
        highlightColor: const Color(0xFFF5F5F5),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  // ─── Error ────────────────────────────────────────────────────────────────

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 52, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('Failed to load products', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _textDark)),
            const SizedBox(height: 8),
            Text(_errorMessage, style: const TextStyle(fontSize: 13, color: _textLight), textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
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

  // ─── Empty ────────────────────────────────────────────────────────────────

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.grey.withOpacity(0.08), shape: BoxShape.circle),
              child: Icon(Icons.search_off_rounded, size: 52, color: Colors.grey.shade400),
            ),
            const SizedBox(height: 16),
            const Text('No products found', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _textDark)),
            const SizedBox(height: 8),
            Text(
              _searchController.text.isNotEmpty
                  ? 'Try a different search term'
                  : 'No products in this category yet',
              style: const TextStyle(fontSize: 13, color: _textLight),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextButton.icon(
              onPressed: () {
                _searchController.clear();
                _onCategorySelected('All');
              },
              icon: const Icon(Icons.refresh_rounded, color: _primary),
              label: const Text('Clear filters', style: TextStyle(color: _primary, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  void _goToDetail(Product product) {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => ProductDetailScreen(product: product),
    ));
  }
}

// ─── Grid Card ────────────────────────────────────────────────────────────────

class _ProductGridCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  const _ProductGridCard({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE0E0E0), width: 1.5),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(14), topRight: Radius.circular(14)),
                    child: SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child: product.image != null
                          ? Image.network(product.image!, fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _placeholder())
                          : _placeholder(),
                    ),
                  ),
                  // Category badge
                  if (product.category != null)
                    Positioned(
                      top: 8, left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: _primary, borderRadius: BorderRadius.circular(20)),
                        child: Text(product.category!, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  // Out of stock overlay
                  if (!product.inStock)
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(14), topRight: Radius.circular(14)),
                        child: Container(
                          color: Colors.black.withOpacity(0.4),
                          child: const Center(child: Text('Out of Stock', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12))),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _textDark),
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  // Rating
                  if (product.rating != null)
                    Row(children: [
                      const Icon(Icons.star_rounded, size: 13, color: Color(0xFFFFC107)),
                      const SizedBox(width: 3),
                      Text(product.rating!.toStringAsFixed(1),
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _textLight)),
                      if (product.reviewCount != null) ...[
                        const SizedBox(width: 2),
                        Text('(${product.reviewCount})', style: const TextStyle(fontSize: 10, color: _textLight)),
                      ],
                    ]),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(product.formattedPrice,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: _primary)),
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(color: _primary.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.add_shopping_cart_rounded, size: 14, color: _primary),
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

  Widget _placeholder() => Container(
    color: _primaryLight.withOpacity(0.05),
    child: const Center(child: Icon(Icons.spa_rounded, color: _primaryLight, size: 40)),
  );
}

// ─── List Card ────────────────────────────────────────────────────────────────

class _ProductListCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  const _ProductListCard({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE0E0E0), width: 1.5),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 90,
                height: 90,
                child: product.image != null
                    ? Image.network(product.image!, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: _primaryLight.withOpacity(0.05),
                          child: const Icon(Icons.spa_rounded, color: _primaryLight, size: 32),
                        ))
                    : Container(
                        color: _primaryLight.withOpacity(0.05),
                        child: const Icon(Icons.spa_rounded, color: _primaryLight, size: 32),
                      ),
              ),
            ),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (product.category != null)
                    Text(product.category!.toUpperCase(),
                        style: const TextStyle(color: _primaryLight, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                  const SizedBox(height: 3),
                  Text(product.name,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _textDark),
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  if (product.rating != null)
                    Row(children: [
                      const Icon(Icons.star_rounded, size: 13, color: Color(0xFFFFC107)),
                      const SizedBox(width: 3),
                      Text(product.rating!.toStringAsFixed(1),
                          style: const TextStyle(fontSize: 11, color: _textLight, fontWeight: FontWeight.w600)),
                    ]),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(product.formattedPrice,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: _primary)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(color: _primary, borderRadius: BorderRadius.circular(10)),
                        child: const Text('Add', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
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