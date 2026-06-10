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
const _discount = Color(0xFFF44336);

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
    _searchController.addListener(() {
      _applyFilters();
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
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
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    final query = _searchController.text.toLowerCase().trim();
    List<Product> result = _allProducts;

    if (_selectedCategory != 'All') {
      result = result
          .where((p) =>
              p.category
                  ?.toLowerCase()
                  .contains(_selectedCategory.toLowerCase()) ??
              false)
          .toList();
    }

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
            _buildAppBar(),
            _buildSearchBar(),
            const SizedBox(height: 10),
            _buildCategoryChips(),
            const SizedBox(height: 10),
            _buildFilterRow(),
            const SizedBox(height: 10),
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

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
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
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('All Products',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: _textDark)),
                Text('Quality supplements for you',
                    style: TextStyle(fontSize: 11, color: _textLight)),
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
            hintText: 'Search products...',
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            prefixIcon:
                const Icon(Icons.search_rounded, color: _textLight, size: 18),
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

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (_, i) {
          final selected = _categories[i] == _selectedCategory;
          return GestureDetector(
            onTap: () => _onCategorySelected(_categories[i]),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: selected ? _primary : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border:
                    Border.all(color: selected ? _primary : _border, width: 1.5),
              ),
              child: Text(
                _categories[i],
                style: TextStyle(
                  fontSize: 11,
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

  Widget _buildFilterRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _isLoading
                  ? 'Loading...'
                  : '${_filteredProducts.length} product${_filteredProducts.length != 1 ? 's' : ''} found',
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _textLight),
            ),
          ),
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
                    _onSortSelected(opt);
                  },
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return _buildShimmer();
    if (_errorMessage.isNotEmpty) return _buildError();
    if (_filteredProducts.isEmpty) return _buildEmpty();

    return _isGrid ? _buildGrid() : _buildList();
  }

  // UPDATED GRID VIEW - Reduced spacing, Taller cards for full image visibility
  Widget _buildGrid() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisExtent: 320, // Increased to fit whole image
        crossAxisSpacing: 6, // Reduced spacing
        mainAxisSpacing: 6, // Reduced spacing
      ),
      itemCount: _filteredProducts.length,
      itemBuilder: (ctx, i) => _ProductGridCard(
        product: _filteredProducts[i],
        onTap: () => _goToDetail(_filteredProducts[i]),
      ),
    );
  }

  Widget _buildList() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      itemCount: _filteredProducts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (ctx, i) => _ProductListCard(
        product: _filteredProducts[i],
        onTap: () => _goToDetail(_filteredProducts[i]),
      ),
    );
  }

  Widget _buildShimmer() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisExtent: 320,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
      ),
      itemCount: 9,
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
              onPressed: _loadData,
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
            const SizedBox(height: 20),
            TextButton.icon(
              onPressed: () {
                _searchController.clear();
                _onCategorySelected('All');
              },
              icon: const Icon(Icons.refresh_rounded, color: _primary),
              label: const Text('Clear filters',
                  style: TextStyle(
                      color: _primary, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  void _goToDetail(Product product) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => ProductDetailScreen(product: product)));
  }
}

// GRID CARD - Taller image, reduced spacing
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

  String get _discountPercent {
    return '-${10 + (product.id % 40)}%';
  }

  double get _oldPriceValue {
    final normalized = product.formattedPrice.replaceAll(RegExp(r'[^0-9.]'), '');
    final currentPrice = double.tryParse(normalized) ?? 0;
    return currentPrice * 1.25;
  }

  Widget _buildRatingStars(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (index < rating.floor()) {
          return const Icon(Icons.star, size: 10, color: Color(0xFFFFC107));
        } else if (index < rating) {
          return const Icon(Icons.star_half, size: 10, color: Color(0xFFFFC107));
        } else {
          return const Icon(Icons.star_border, size: 10, color: Color(0xFFFFC107));
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
          border: Border.all(color: _border, width: 0.5),
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
            // IMAGE SECTION - Increased height for visibility
            SizedBox(
              height: 180, // Increased from 140 to 180
              width: double.infinity,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    child: product.image != null
                        ? Image.network(
                            product.image!,
                            fit: BoxFit.cover, // Ensures whole visible area is filled
                            width: double.infinity,
                            height: double.infinity,
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
                  // DISCOUNT BADGE
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _discount,
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 2,
                          )
                        ],
                      ),
                      child: Text(
                        _discountPercent,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // DETAILS SECTION
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(6), // Reduced padding from 8 to 6
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Product Name
                    Text(
                      product.name,
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _textDark,
                          height: 1.2),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 2),
                    
                    // RATING STARS
                    Row(
                      children: [
                        _buildRatingStars(_rating),
                        const SizedBox(width: 4),
                        Text(
                          _rating.toStringAsFixed(1),
                          style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: _textLight),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '($_reviewCount)',
                          style: const TextStyle(
                              fontSize: 8, color: _textLight),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 6),
                    
                    // PRICE SECTION WITH OLD PRICE
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.formattedPrice,
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: _primary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              _formatPrice(_oldPriceValue),
                              style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.grey,
                                  decoration: TextDecoration.lineThrough),
                            ),
                          ],
                        ),
                        // CART ICON
                        GestureDetector(
                          onTap: onTap,
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: _primary.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                                Icons.add_shopping_cart,
                                size: 15,
                                color: _primary),
                          ),
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

// LIST CARD - Spacing adjustments
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

  String get _discountPercent {
    return '-${10 + (product.id % 40)}%';
  }

  double get _oldPriceValue {
    final normalized = product.formattedPrice.replaceAll(RegExp(r'[^0-9.]'), '');
    final currentPrice = double.tryParse(normalized) ?? 0;
    return currentPrice * 1.25;
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
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _border, width: 0.8),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 3,
                offset: const Offset(0, 1))
          ],
        ),
        child: Row(
          children: [
            // Image with Discount Badge
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 85,
                    height: 85,
                    child: product.image != null
                        ? Image.network(
                            product.image!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: _primaryLight.withOpacity(0.05),
                              child: const Icon(Icons.spa_rounded,
                                  color: _primaryLight, size: 28),
                            ),
                          )
                        : Container(
                            color: _primaryLight.withOpacity(0.05),
                            child: const Icon(Icons.spa_rounded,
                                color: _primaryLight, size: 28),
                          ),
                  ),
                ),
                Positioned(
                  top: 4,
                  left: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: _discount,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      _discountPercent,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            
            // Content
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
                          letterSpacing: 0.4),
                    ),
                  const SizedBox(height: 2),
                  Text(
                    product.name,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _textDark),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  
                  // RATING STARS
                  Row(
                    children: [
                      _buildRatingStars(_rating),
                      const SizedBox(width: 5),
                      Text(
                        _rating.toStringAsFixed(1),
                        style: const TextStyle(
                            fontSize: 10,
                            color: _textLight,
                            fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '($_reviewCount)',
                        style: const TextStyle(
                            fontSize: 9, color: _textLight),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 6),
                  
                  // Price and Add button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.formattedPrice,
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                color: _primary),
                          ),
                          Text(
                            _formatPrice(_oldPriceValue),
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey,
                                decoration: TextDecoration.lineThrough),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                            color: _primary,
                            borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.add_shopping_cart,
                            color: Colors.white, size: 16),
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

String _formatPrice(double price) {
  return 'UGX ${price.toStringAsFixed(0)}';
}