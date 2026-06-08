import 'package:flutter/material.dart';
import '../../models/order_model.dart';
import '../home/home_screen.dart';
import 'orders_screen.dart';

const _primary = Color(0xFF2E7D32);
const _primaryLight = Color(0xFF4CAF50);
const _textDark = Color(0xFF1A1A1A);
const _textLight = Color(0xFF757575);
const _border = Color(0xFFEEEEEE);

class OrderConfirmationScreen extends StatefulWidget {
  final Order order;
  const OrderConfirmationScreen({super.key, required this.order});

  @override
  State<OrderConfirmationScreen> createState() => _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  Order get order => widget.order;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _scaleAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6, curve: Curves.elasticOut)),
    );

    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.4, 1.0, curve: Curves.easeIn)),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
          child: Column(
            children: [
              // ── Success Animation ──────────────────────────────────────
              AnimatedBuilder(
                animation: _controller,
                builder: (_, __) => ScaleTransition(
                  scale: _scaleAnim,
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE8F5E9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_circle_rounded, color: _primary, size: 60),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ── Title ──────────────────────────────────────────────────
              FadeTransition(
                opacity: _fadeAnim,
                child: Column(
                  children: [
                    const Text(
                      'Order Placed! 🎉',
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: _textDark),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Thank you for your order. We\'ll process it right away.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.5),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ── Order Number Card ──────────────────────────────────────
              FadeTransition(
                opacity: _fadeAnim,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _primary.withOpacity(0.2)),
                  ),
                  child: Column(
                    children: [
                      const Text('Order Number', style: TextStyle(fontSize: 12, color: _textLight)),
                      const SizedBox(height: 4),
                      Text(order.orderNumber,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: _primary)),
                      const SizedBox(height: 4),
                      Text('Placed on ${order.createdAt}',
                          style: const TextStyle(fontSize: 12, color: _textLight)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ── Order Items ────────────────────────────────────────────
              FadeTransition(
                opacity: _fadeAnim,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE0E0E0), width: 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.fromLTRB(14, 14, 14, 0),
                        child: Text('Items Ordered',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _textDark)),
                      ),
                      const SizedBox(height: 10),
                      ...List.generate(order.items.length, (i) {
                        final item = order.items[i];
                        final isLast = i == order.items.length - 1;
                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(14, 6, 14, 6),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: SizedBox(
                                      width: 48, height: 48,
                                      child: item.productImage != null
                                          ? Image.network(item.productImage!, fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) => Container(
                                                color: _primary.withOpacity(0.05),
                                                child: const Icon(Icons.spa_rounded, color: _primaryLight, size: 22)))
                                          : Container(color: _primary.withOpacity(0.05),
                                              child: const Icon(Icons.spa_rounded, color: _primaryLight, size: 22)),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(item.productName,
                                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _textDark),
                                            maxLines: 1, overflow: TextOverflow.ellipsis),
                                        Text('Qty: ${item.quantity}',
                                            style: const TextStyle(fontSize: 12, color: _textLight)),
                                      ],
                                    ),
                                  ),
                                  Text(item.formattedSubtotal,
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: _primary)),
                                ],
                              ),
                            ),
                            if (!isLast) const Divider(height: 1, color: _border),
                          ],
                        );
                      }),
                      const Divider(height: 1, color: _border),
                      Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: _textDark)),
                            Text(order.formattedTotal,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: _primary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ── What's Next ────────────────────────────────────────────
              FadeTransition(
                opacity: _fadeAnim,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE0E0E0), width: 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("What's Next?",
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _textDark)),
                      const SizedBox(height: 12),
                      _whatNextTile(Icons.email_outlined, 'Confirmation Email',
                          'A confirmation has been sent to your email.'),
                      _whatNextTile(Icons.autorenew_rounded, 'Order Processing',
                          'We\'ll prepare your order within 24 hours.'),
                      _whatNextTile(Icons.local_shipping_outlined, 'Delivery',
                          'Your order will be delivered to your address.'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // ── Actions ────────────────────────────────────────────────
              FadeTransition(
                opacity: _fadeAnim,
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const OrdersScreen())),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text('Track My Order',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const HomeScreen()),
                          (route) => false,
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFE0E0E0), width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          foregroundColor: _textDark,
                        ),
                        child: const Text('Continue Shopping',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _whatNextTile(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: _primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: _primary, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _textDark)),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: _textLight, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}