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

class ProductListScreen extends StatefulWidget {
  final String? category; // null means all products

  const ProductListScreen({super.key, this.category});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ProductService _service = ProductService();

  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = true;
  bool _isGrid = true;
  String _errorMessage = '';
  String _sortBy = 'Default';

  final List<String> _sortOptions = [
    'Default',
    'Price: Low to High',
    'Price: High to Low',
    'Name: A to Z',
  ];

  String get _title => widget.category ?? 'All Products';
  bool get _hasCategory => widget.category != null;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _searchController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() { _isLoading = true; _errorMessage = ''; });
    try {
      final products = await _service.fetchProducts(
        category: _hasCategory ? widget.category : null,
      );
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

  void _applyFilters() {
    final query = _searchController.text.toLowerCase().trim();
    List<Product> result = List.from(_allProducts);

    if (query.isNotEmpty) {
      result = result.where((p) =>
        p.name.toLowerCase().contains(query) ||
        (p.category?.toLowerCase().contains(query) ?? false) ||
        (p.description?.toLowerCase().contains(query) ?? false)
      ).toList();
    }

    switch (_sortBy) {
      case 'Price: Low to High':
        result.sort((a, b) => a.formattedPrice.compareTo(b.formattedPrice));
        break;
      case 'Price: High to Low':
        result.sort((a, b) => b.formattedPrice.compareTo(a.formattedPrice));
        break;
      case 'Name: A to Z':
        result.sort((a, b) => a.name.compareTo(b.name));
        break;
    }

    setState(() => _filteredProducts = result);
  }

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
              trailing: _sortBy == opt ? const Icon(Icons.check_rounded, color: _primary) : null,
              onTap: () {
                Navigator.pop(context);
                setState(() => _sortBy = opt);
                _applyFilters();
              },
            )),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          children: [
            // ── App Bar ────────────────────────────────────────────────
            _buildAppBar(),
            const SizedBox(height: 12),

            // ── Search Bar ─────────────────────────────────────────────
            _buildSearchBar(),
            const SizedBox(height: 12),

            // ── Filter Row ─────────────────────────────────────────────
            _buildFilterRow(),
            const SizedBox(height: 12),

            // ── Body ───────────────────────────────────────────────────
            Expanded(
              child: RefreshIndicator(
                color: _primary,
                onRefresh: _loadProducts,
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
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_title,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: _textDark),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(
                  _isLoading ? 'Loading...' : '${_filteredProducts.length} products',
                  style: const TextStyle(fontSize: 12, color: _textLight),
                ),
              ],
            ),
          ),
          // Cart
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
                right: -4, top: -4,
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
            hintText: 'Search in $_title...',
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

  // ─── Filter Row ───────────────────────────────────────────────────────────

  Widget _buildFilterRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Category pill (if filtered)
          if (_hasCategory)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _primary.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.filter_list_rounded, size: 13, color: _primary),
                  const SizedBox(width: 4),
                  Text(widget.category!, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _primary)),
                ],
              ),
            ),
          if (_hasCategory) const SizedBox(width: 8),

          const Spacer(),

          // Sort
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
                size: 18, color: _textDark,
              ),
            ),
          ),
        ],
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
      itemBuilder: (_, i) => _ProductGridCard(
        product: _filteredProducts[i],
        onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => ProductDetailScreen(product: _filteredProducts[i]))),
      ),
    );
  }

  Widget _buildList() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      itemCount: _filteredProducts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _ProductListCard(
        product: _filteredProducts[i],
        onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => ProductDetailScreen(product: _filteredProducts[i]))),
      ),
    );
  }

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
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }

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
              onPressed: _loadProducts,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary, foregroundColor: Colors.white,
                elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
              _searchController.text.isNotEmpty ? 'Try a different search term' : 'No products in this category yet',
              style: const TextStyle(fontSize: 13, color: _textLight),
              textAlign: TextAlign.center,
            ),
            if (_searchController.text.isNotEmpty) ...[
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: _searchController.clear,
                icon: const Icon(Icons.clear_rounded, color: _primary),
                label: const Text('Clear search', style: TextStyle(color: _primary, fontWeight: FontWeight.w700)),
              ),
            ],
          ],
        ),
      ),
    );
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
          border: Border.all(color: _border, width: 1.5),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(14), topRight: Radius.circular(14)),
                    child: SizedBox(
                      width: double.infinity, height: double.infinity,
                      child: product.image != null
                          ? Image.network(product.image!, fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _placeholder())
                          : _placeholder(),
                    ),
                  ),
                  if (product.category != null)
                    Positioned(
                      top: 8, left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(color: _primary, borderRadius: BorderRadius.circular(20)),
                        child: Text(product.category!, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700)),
                      ),
                    ),
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
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _textDark),
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                  if (product.rating != null) ...[
                    const SizedBox(height: 3),
                    Row(children: [
                      const Icon(Icons.star_rounded, size: 12, color: Color(0xFFFFC107)),
                      const SizedBox(width: 3),
                      Text(product.rating!.toStringAsFixed(1), style: const TextStyle(fontSize: 11, color: _textLight, fontWeight: FontWeight.w600)),
                    ]),
                  ],
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(product.formattedPrice, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: _primary)),
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
          border: Border.all(color: _border, width: 1.5),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 90, height: 90,
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
                  if (product.rating != null) ...[
                    const SizedBox(height: 4),
                    Row(children: [
                      const Icon(Icons.star_rounded, size: 13, color: Color(0xFFFFC107)),
                      const SizedBox(width: 3),
                      Text(product.rating!.toStringAsFixed(1), style: const TextStyle(fontSize: 11, color: _textLight, fontWeight: FontWeight.w600)),
                    ]),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(product.formattedPrice, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: _primary)),
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