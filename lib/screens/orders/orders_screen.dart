import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../models/order_model.dart';
import '../../services/order_service.dart';
import 'order_detail_screen.dart';

const _primary = Color(0xFF2E7D32);
const _primaryLight = Color(0xFF4CAF50);
const _textDark = Color(0xFF1A1A1A);
const _textLight = Color(0xFF757575);
const _border = Color(0xFFE0E0E0);

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final OrderService _service = OrderService();

  List<Order> _allOrders = [];
  bool _isLoading = true;
  String _errorMessage = '';

  final List<String> _tabs = ['All', 'Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _loadOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    setState(() { _isLoading = true; _errorMessage = ''; });
    try {
      final orders = await _service.fetchOrders();
      if (!mounted) return;
      setState(() { _allOrders = orders; _isLoading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _errorMessage = e.toString(); _isLoading = false; });
    }
  }

  List<Order> _filterOrders(String tab) {
    if (tab == 'All') return _allOrders;
    return _allOrders.where((o) =>
      o.status.toLowerCase() == tab.toLowerCase()
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          children: [
            // ── App Bar ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('My Orders', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: _textDark)),
                        Text('Track your purchases', style: TextStyle(fontSize: 12, color: _textLight)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Tab Bar ──────────────────────────────────────────────────
            TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelColor: _primary,
              unselectedLabelColor: _textLight,
              labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              indicatorColor: _primary,
              indicatorWeight: 2.5,
              dividerColor: _border,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              tabs: _tabs.map((t) {
                final count = _filterOrders(t).length;
                return Tab(
                  child: Row(
                    children: [
                      Text(t),
                      if (!_isLoading && count > 0) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text('$count', style: const TextStyle(fontSize: 10, color: _primary, fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ],
                  ),
                );
              }).toList(),
            ),

            // ── Tab Views ────────────────────────────────────────────────
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: _tabs.map((t) => RefreshIndicator(
                  color: _primary,
                  onRefresh: _loadOrders,
                  child: _buildTabContent(t),
                )).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(String tab) {
    if (_isLoading) return _buildShimmer();
    if (_errorMessage.isNotEmpty) return _buildError();
    final orders = _filterOrders(tab);
    if (orders.isEmpty) return _buildEmpty(tab);

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      itemCount: orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _OrderCard(
        order: orders[i],
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => OrderDetailScreen(order: orders[i])),
        ).then((_) => _loadOrders()),
      ),
    );
  }

  Widget _buildShimmer() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      itemCount: 4,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: const Color(0xFFE0E0E0),
        highlightColor: const Color(0xFFF5F5F5),
        child: Container(
          height: 120,
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
            const Text('Failed to load orders', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _textDark)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadOrders,
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

  Widget _buildEmpty(String tab) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: Colors.grey.withOpacity(0.08), shape: BoxShape.circle),
              child: Icon(Icons.receipt_long_outlined, size: 52, color: Colors.grey.shade400),
            ),
            const SizedBox(height: 16),
            Text(
              tab == 'All' ? 'No orders yet' : 'No $tab orders',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _textDark),
            ),
            const SizedBox(height: 8),
            Text(
              tab == 'All' ? 'Your order history will appear here' : 'You have no $tab orders at the moment',
              style: const TextStyle(fontSize: 13, color: _textLight),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Order Card ───────────────────────────────────────────────────────────────

class _OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback onTap;
  const _OrderCard({required this.order, required this.onTap});

  Color get _statusColor {
    switch (order.status.toLowerCase()) {
      case 'delivered': return const Color(0xFF2E7D32);
      case 'shipped': return const Color(0xFF1565C0);
      case 'processing': return const Color(0xFFF57C00);
      case 'cancelled': return const Color(0xFFD32F2F);
      default: return const Color(0xFF757575);
    }
  }

  IconData get _statusIcon {
    switch (order.status.toLowerCase()) {
      case 'delivered': return Icons.check_circle_rounded;
      case 'shipped': return Icons.local_shipping_rounded;
      case 'processing': return Icons.autorenew_rounded;
      case 'cancelled': return Icons.cancel_rounded;
      default: return Icons.access_time_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _border, width: 1.5),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(_statusIcon, color: _statusColor, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(order.orderNumber,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: _textDark)),
                      const SizedBox(height: 2),
                      Text(order.createdAt,
                          style: const TextStyle(fontSize: 12, color: _textLight)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(order.statusLabel,
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _statusColor)),
                ),
              ],
            ),

            if (order.items.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(height: 1, color: Color(0xFFEEEEEE)),
              const SizedBox(height: 12),
              ...order.items.take(2).map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: 40, height: 40,
                        child: item.productImage != null
                            ? Image.network(item.productImage!, fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: _primary.withOpacity(0.05),
                                  child: const Icon(Icons.spa_rounded, size: 18, color: _primaryLight)))
                            : Container(color: _primary.withOpacity(0.05),
                                child: const Icon(Icons.spa_rounded, size: 18, color: _primaryLight)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(item.productName,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _textDark),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                    Text('x${item.quantity}',
                        style: const TextStyle(fontSize: 12, color: _textLight, fontWeight: FontWeight.w600)),
                  ],
                ),
              )),
              if (order.items.length > 2)
                Text('+${order.items.length - 2} more items',
                    style: const TextStyle(fontSize: 11, color: _textLight)),
            ],

            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFFEEEEEE)),
            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(order.formattedTotal,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: _primary)),
                const Row(
                  children: [
                    Text('View Details', style: TextStyle(fontSize: 12, color: _textLight, fontWeight: FontWeight.w600)),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward_ios_rounded, size: 12, color: _textLight),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}