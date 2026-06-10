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
  final String? category;

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
    // FIX 1: Fixed search bar refresh
    _searchController.addListener(() {
      _applyFilters();
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
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
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    final query = _searchController.text.toLowerCase().trim();
    List<Product> result = List.from(_allProducts);

    if (query.isNotEmpty) {
      result = result
          .where((p) =>
              p.name.toLowerCase().contains(query) ||
              (p.category?.toLowerCase().contains(query) ?? false) ||
              (p.description?.toLowerCase().contains(query) ?? false))
          .toList();
    }

    double priceValue(Product p) {
      final normalized = p.formattedPrice.replaceAll(RegExp(r'[^0-9.]'), '');
      return double.tryParse(normalized) ?? 0;
    }

    switch (_sortBy) {
      case 'Price: Low to High':
        result.sort((a, b) => priceValue(a).compareTo(priceValue(b)));
        break;
      case 'Price: High to Low':
        result.sort((a, b) => priceValue(b).compareTo(priceValue(a)));
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
            const Text('Sort by',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: _textDark)),
            const SizedBox(height: 16),
            ..._sortOptions.map((opt) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(opt,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: _sortBy == opt
                            ? FontWeight.w700
                            : FontWeight.w400,
                        color: _sortBy == opt ? _primary : _textDark,
                      )),
                  trailing: _sortBy == opt
                      ? const Icon(Icons.check_rounded, color: _primary)
                      : null,
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
            _buildAppBar(),
            const SizedBox(height: 10),
            _buildSearchBar(),
            const SizedBox(height: 10),
            _buildFilterRow(),
            const SizedBox(height: 10),
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

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _border),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  size: 16, color: _textDark),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_title,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: _textDark),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text(
                  _isLoading
                      ? 'Loading...'
                      : '${_filteredProducts.length} product${_filteredProducts.length != 1 ? 's' : ''}',
                  style: const TextStyle(fontSize: 11, color: _textLight),
                ),
              ],
            ),
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _border),
                ),
                child: const Icon(Icons.shopping_cart_outlined,
                    size: 20, color: _textDark),
              ),
              Positioned(
                right: -4,
                top: -4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                      color: Color(0xFFE53935), shape: BoxShape.circle),
                  child: const Text('2',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold)),
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
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _border, width: 1.5),
        ),
        child: TextField(
          controller: _searchController,
          style: const TextStyle(fontSize: 13, color: _textDark),
          decoration: InputDecoration(
            hintText: 'Search in $_title...',
            hintStyle:
                TextStyle(color: Colors.grey.shade400, fontSize: 13),
            prefixIcon: const Icon(Icons.search_rounded,
                color: _textLight, size: 18),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded,
                        size: 16, color: _textLight),
                    onPressed: () {
                      _searchController.clear();
                      _applyFilters();
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          if (_hasCategory)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: _primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _primary.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.filter_list_rounded,
                      size: 12, color: _primary),
                  const SizedBox(width: 4),
                  Text(widget.category!,
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _primary)),
                ],
              ),
            ),
          if (_hasCategory) const SizedBox(width: 8),
          const Spacer(),
          GestureDetector(
            onTap: _showSortSheet,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _border, width: 1.5),
              ),
              child: Row(
                children: [
                  const Icon(Icons.sort_rounded,
                      size: 14, color: _textLight),
                  const SizedBox(width: 5),
                  Text(_sortBy,
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _textDark)),
                  const SizedBox(width: 3),
                  const Icon(Icons.keyboard_arrow_down_rounded,
                      size: 14, color: _textLight),
                ],
              ),
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () => setState(() => _isGrid = !_isGrid),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _border, width: 1.5),
              ),
              child: Icon(
                _isGrid
                    ? Icons.view_list_rounded
                    : Icons.grid_view_rounded,
                size: 16,
                color: _textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return _buildShimmer();
    if (_errorMessage.isNotEmpty) return _buildError();
    if (_filteredProducts.isEmpty) return _buildEmpty();
    return _isGrid ? _buildGrid() : _buildList();
  }

  // FIX 2 & 3: Fixed GridView sizing with mainAxisExtent
  Widget _buildGrid() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisExtent: 285, // Fixed height instead of childAspectRatio
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _filteredProducts.length,
      itemBuilder: (_, i) => _ProductGridCard(
        product: _filteredProducts[i],
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => ProductDetailScreen(
                    product: _filteredProducts[i]))),
      ),
    );
  }

  // FIX 4: Fixed ListView bottom gap
  Widget _buildList() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      itemCount: _filteredProducts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _ProductListCard(
        product: _filteredProducts[i],
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => ProductDetailScreen(
                    product: _filteredProducts[i]))),
      ),
    );
  }

  // FIX 3: Fixed Shimmer sizing
  Widget _buildShimmer() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisExtent: 285,
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
            borderRadius: BorderRadius.circular(12),
          ),
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
            const Text('Failed to load products',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _textDark)),
            const SizedBox(height: 8),
            Text(_errorMessage,
                style: const TextStyle(fontSize: 13, color: _textLight),
                textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadProducts,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
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
              decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.08),
                  shape: BoxShape.circle),
              child: Icon(Icons.search_off_rounded,
                  size: 52, color: Colors.grey.shade400),
            ),
            const SizedBox(height: 16),
            const Text('No products found',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _textDark)),
            const SizedBox(height: 8),
            Text(
              _searchController.text.isNotEmpty
                  ? 'Try a different search term'
                  : 'No products in this category yet',
              style: const TextStyle(fontSize: 13, color: _textLight),
              textAlign: TextAlign.center,
            ),
            if (_searchController.text.isNotEmpty) ...[
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () {
                  _searchController.clear();
                  _applyFilters();
                },
                icon: const Icon(Icons.clear_rounded, color: _primary),
                label: const Text('Clear search',
                    style: TextStyle(
                        color: _primary, fontWeight: FontWeight.w700)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// FIXED GRID CARD - NO OVERFLOW, NO BLANK SPACE
class _ProductGridCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  const _ProductGridCard({required this.product, required this.onTap});

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
          return const Icon(Icons.star, size: 12, color: Color(0xFFFFC107));
        } else if (index < rating) {
          return const Icon(Icons.star_half, size: 12, color: Color(0xFFFFC107));
        } else {
          return const Icon(Icons.star_border, size: 12, color: Color(0xFFFFC107));
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
          border: Border.all(color: _border, width: 1),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 4,
                offset: const Offset(0, 2))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // FIX 5: Fixed image height to 110
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 110, 
                child: product.image != null
                    ? Image.network(
                        product.image!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: _primaryLight.withOpacity(0.05),
                          child: const Icon(Icons.spa_rounded, 
                              color: _primaryLight, size: 40),
                        ),
                      )
                    : Container(
                        color: _primaryLight.withOpacity(0.05),
                        child: const Icon(Icons.spa_rounded, 
                            color: _primaryLight, size: 40),
                      ),
              ),
            ),
            
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          product.name,
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: _textDark,
                              height: 1.2),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            _buildRatingStars(_rating),
                            const SizedBox(width: 6),
                            Text(
                              _rating.toStringAsFixed(1),
                              style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: _textLight),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '($_reviewCount)',
                              style: const TextStyle(
                                  fontSize: 10, color: _textLight),
                            ),
                          ],
                        ),
                      ],
                    ),
                    
                    // FIX 6: Prevent long price overflow
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            product.formattedPrice,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: _primary),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _primary.withOpacity(0.10),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                              Icons.add_shopping_cart_rounded,
                              size: 16,
                              color: _primary),
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
}

// FIX 7: Fixed list card image distortion
class _ProductListCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  const _ProductListCard({required this.product, required this.onTap});

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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _border, width: 1),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 4,
                offset: const Offset(0, 2))
          ],
        ),
        child: Row(
          children: [
            // FIX 7: Fixed image size to 80x80 (was 80x40)
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 80,
                height: 80,
                child: product.image != null
                    ? Image.network(
                        product.image!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: _primaryLight.withOpacity(0.05),
                          child: const Icon(Icons.spa_rounded,
                              color: _primaryLight, size: 30),
                        ),
                      )
                    : Container(
                        color: _primaryLight.withOpacity(0.05),
                        child: const Icon(Icons.spa_rounded,
                            color: _primaryLight, size: 30),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (product.category != null)
                    Text(
                      product.category!.toUpperCase(),
                      style: const TextStyle(
                          color: _primaryLight,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    product.name,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _textDark),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _buildRatingStars(_rating),
                      const SizedBox(width: 6),
                      Text(
                        _rating.toStringAsFixed(1),
                        style: const TextStyle(
                            fontSize: 12,
                            color: _textLight,
                            fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '($_reviewCount)',
                        style: const TextStyle(
                            fontSize: 11, color: _textLight),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          product.formattedPrice,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: _primary),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                            color: _primary,
                            borderRadius: BorderRadius.circular(8)),
                        child: const Text('Add',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700)),
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