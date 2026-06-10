import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../services/product_service.dart';
import '../../models/product_model.dart';
import 'product_list_screen.dart';

const _primary      = Color(0xFF2E7D32);
const _primaryLight = Color(0xFF4CAF50);
const _textDark     = Color(0xFF1A1A1A);
const _textLight    = Color(0xFF757575);
const _border       = Color(0xFFE0E0E0);

class _CategoryItem {
  final String name;
  final IconData icon;
  final Color color;
  final Color bgColor;
  const _CategoryItem({required this.name, required this.icon, required this.color, required this.bgColor});
}

_CategoryItem _mapCategory(String name) {
  final lower = name.toLowerCase();
  if (lower.contains('protein') || lower.contains('whey'))
    return _CategoryItem(name: name, icon: Icons.fitness_center_rounded,
        color: const Color(0xFF1565C0), bgColor: const Color(0xFFE3F2FD));
  if (lower.contains('vitamin') || lower.contains('supplement'))
    return _CategoryItem(name: name, icon: Icons.local_pharmacy_outlined,
        color: const Color(0xFF6A1B9A), bgColor: const Color(0xFFF3E5F5));
  if (lower.contains('omega') || lower.contains('fish'))
    return _CategoryItem(name: name, icon: Icons.water_drop_outlined,
        color: const Color(0xFF00838F), bgColor: const Color(0xFFE0F7FA));
  if (lower.contains('probiotic') || lower.contains('gut'))
    return _CategoryItem(name: name, icon: Icons.spa_rounded,
        color: const Color(0xFF2E7D32), bgColor: const Color(0xFFE8F5E9));
  if (lower.contains('superfood') || lower.contains('greens'))
    return _CategoryItem(name: name, icon: Icons.eco_rounded,
        color: const Color(0xFF558B2F), bgColor: const Color(0xFFF1F8E9));
  if (lower.contains('bundle') || lower.contains('pack'))
    return _CategoryItem(name: name, icon: Icons.inventory_2_outlined,
        color: const Color(0xFFBF360C), bgColor: const Color(0xFFFBE9E7));
  if (lower.contains('weight') || lower.contains('fat'))
    return _CategoryItem(name: name, icon: Icons.monitor_weight_outlined,
        color: const Color(0xFFF57C00), bgColor: const Color(0xFFFFF3E0));
  return _CategoryItem(name: name, icon: Icons.category_outlined,
      color: _primary, bgColor: const Color(0xFFE8F5E9));
}

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final ProductService _service = ProductService();
  List<String> _categories = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() { _isLoading = true; _errorMessage = ''; });
    try {
      final cats = await _service.fetchCategories();
      if (!mounted) return;
      setState(() { _categories = cats; _isLoading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _errorMessage = e.toString(); _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── App Bar ────────────────────────────────────────────────
            Padding(
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
                      child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: _textDark),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Categories', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: _textDark)),
                      Text('Browse by product type', style: TextStyle(fontSize: 11, color: _textLight)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Featured Banner ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1B4332), Color(0xFF2D6A4F)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('All Products', style: TextStyle(color: Colors.white70, fontSize: 11)),
                          const SizedBox(height: 4),
                          const Text('Browse everything', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 10),
                          GestureDetector(
                            onTap: () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const ProductListScreen())),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text('Shop All', style: TextStyle(color: Color(0xFF1B4332), fontSize: 11, fontWeight: FontWeight.w700)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Text('🛍️', style: TextStyle(fontSize: 44)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                _isLoading
                    ? 'Loading categories...'
                    : '${_categories.length} categories',
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _textLight),
              ),
            ),

            const SizedBox(height: 10),

            // ── Grid ── 3 COLUMNS WITH SMALLER CARDS ───────────────────
            Expanded(
              child: RefreshIndicator(
                color: _primary,
                onRefresh: _loadCategories,
                child: _buildBody(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return _buildShimmer();
    if (_errorMessage.isNotEmpty) return _buildError();
    if (_categories.isEmpty) return _buildEmpty();

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // Changed to 3 columns
        childAspectRatio: 0.85, // Adjusted for smaller cards
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _categories.length,
      itemBuilder: (_, i) {
        final cat = _mapCategory(_categories[i]);
        return _CategoryCard(
          item: cat,
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => ProductListScreen(category: cat.name))),
        );
      },
    );
  }

  Widget _buildShimmer() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.85,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
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
            const Text('Failed to load categories', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _textDark)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadCategories,
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

  Widget _buildEmpty() {
    return const Center(
      child: Text('No categories found.', style: TextStyle(color: _textLight, fontSize: 14)),
    );
  }
}

// ─── SMALLER CATEGORY CARD (3 columns) ────────────────────────────────────────

class _CategoryCard extends StatelessWidget {
  final _CategoryItem item;
  final VoidCallback onTap;
  const _CategoryCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE0E0E0), width: 0.8),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 4,
                offset: const Offset(0, 2))
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // SMALLER ICON CONTAINER
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: item.bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                item.icon,
                color: item.color,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            // SMALLER TEXT
            Text(
              item.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: _textDark,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              'View →',
              style: TextStyle(
                fontSize: 9,
                color: item.color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}