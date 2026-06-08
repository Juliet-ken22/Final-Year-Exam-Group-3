import 'package:flutter/material.dart';
import '../../models/order_model.dart';
import '../../services/order_service.dart';
import 'order_confirmation_screen.dart';

const _primary = Color(0xFF2E7D32);
const _primaryLight = Color(0xFF4CAF50);
const _textDark = Color(0xFF1A1A1A);
const _textLight = Color(0xFF757575);
const _border = Color(0xFFEEEEEE);

class OrderDetailScreen extends StatefulWidget {
  final Order order;
  const OrderDetailScreen({super.key, required this.order});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  bool _isCancelling = false;

  Order get order => widget.order;

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

  Future<void> _handleCancel() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Cancel Order?', style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Text('Are you sure you want to cancel this order? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep Order', style: TextStyle(color: _textLight)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    setState(() => _isCancelling = true);
    final result = await OrderService().cancelOrder(order.id);
    if (!mounted) return;
    setState(() => _isCancelling = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result['message'] ?? (result['success'] ? 'Order cancelled.' : 'Failed to cancel.')),
        backgroundColor: result['success'] ? _primary : const Color(0xFFD32F2F),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );

    if (result['success']) Navigator.pop(context);
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
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE0E0E0)),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: _textDark),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Order Details', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: _textDark)),
                        Text(order.orderNumber, style: const TextStyle(fontSize: 12, color: _textLight)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Status Card ────────────────────────────────────────
                    _buildStatusCard(),

                    const SizedBox(height: 16),

                    // ── Order Progress ─────────────────────────────────────
                    if (!order.isCancelled) _buildOrderProgress(),

                    if (!order.isCancelled) const SizedBox(height: 16),

                    // ── Order Items ────────────────────────────────────────
                    _buildSectionTitle('Order Items'),
                    const SizedBox(height: 10),
                    _buildOrderItems(),

                    const SizedBox(height: 16),

                    // ── Order Summary ──────────────────────────────────────
                    _buildSectionTitle('Order Summary'),
                    const SizedBox(height: 10),
                    _buildOrderSummary(),

                    const SizedBox(height: 16),

                    // ── Shipping Info ──────────────────────────────────────
                    if (order.shippingAddress != null) ...[
                      _buildSectionTitle('Shipping Address'),
                      const SizedBox(height: 10),
                      _buildInfoCard(
                        icon: Icons.location_on_outlined,
                        content: order.shippingAddress!,
                      ),
                      const SizedBox(height: 16),
                    ],

                    // ── Payment Method ─────────────────────────────────────
                    if (order.paymentMethod != null) ...[
                      _buildSectionTitle('Payment Method'),
                      const SizedBox(height: 10),
                      _buildInfoCard(
                        icon: Icons.payment_outlined,
                        content: order.paymentMethod!,
                      ),
                      const SizedBox(height: 16),
                    ],

                    // ── Notes ──────────────────────────────────────────────
                    if (order.notes != null && order.notes!.isNotEmpty) ...[
                      _buildSectionTitle('Notes'),
                      const SizedBox(height: 10),
                      _buildInfoCard(
                        icon: Icons.notes_rounded,
                        content: order.notes!,
                      ),
                      const SizedBox(height: 16),
                    ],

                    // ── Cancel Button ──────────────────────────────────────
                    if (order.isPending || order.isProcessing)
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton(
                          onPressed: _isCancelling ? null : _handleCancel,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFD32F2F), width: 1.5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            foregroundColor: const Color(0xFFD32F2F),
                          ),
                          child: _isCancelling
                              ? const SizedBox(width: 20, height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFD32F2F)))
                              : const Text('Cancel Order', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                        ),
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

  // ─── Status Card ──────────────────────────────────────────────────────────

  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(_statusIcon, color: _statusColor, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(order.statusLabel,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _statusColor)),
                const SizedBox(height: 3),
                Text('Placed on ${order.createdAt}',
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
            child: Text(order.orderNumber,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _statusColor)),
          ),
        ],
      ),
    );
  }

  // ─── Order Progress ───────────────────────────────────────────────────────

  Widget _buildOrderProgress() {
    final steps = [
      _ProgressStep('Order Placed', Icons.receipt_outlined, true),
      _ProgressStep('Processing', Icons.autorenew_rounded, order.isProcessing || order.isShipped || order.isDelivered),
      _ProgressStep('Shipped', Icons.local_shipping_outlined, order.isShipped || order.isDelivered),
      _ProgressStep('Delivered', Icons.check_circle_outline_rounded, order.isDelivered),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Order Progress', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _textDark)),
          const SizedBox(height: 16),
          Row(
            children: List.generate(steps.length, (i) {
              final step = steps[i];
              final isLast = i == steps.length - 1;
              return Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            width: 36, height: 36,
                            decoration: BoxDecoration(
                              color: step.done ? _primary : const Color(0xFFE0E0E0),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(step.icon, size: 18,
                                color: step.done ? Colors.white : const Color(0xFFBBBBBB)),
                          ),
                          const SizedBox(height: 6),
                          Text(step.label,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: step.done ? FontWeight.w700 : FontWeight.w400,
                                color: step.done ? _primary : _textLight,
                              )),
                        ],
                      ),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          height: 2,
                          margin: const EdgeInsets.only(bottom: 22),
                          color: steps[i + 1].done ? _primary : const Color(0xFFE0E0E0),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ─── Order Items ──────────────────────────────────────────────────────────

  Widget _buildOrderItems() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1.5),
      ),
      child: Column(
        children: List.generate(order.items.length, (i) {
          final item = order.items[i];
          final isLast = i == order.items.length - 1;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: SizedBox(
                        width: 56, height: 56,
                        child: item.productImage != null
                            ? Image.network(item.productImage!, fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: _primary.withOpacity(0.05),
                                  child: const Icon(Icons.spa_rounded, color: _primaryLight, size: 24)))
                            : Container(color: _primary.withOpacity(0.05),
                                child: const Icon(Icons.spa_rounded, color: _primaryLight, size: 24)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.productName,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _textDark),
                              maxLines: 2, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Text('${item.formattedPrice} × ${item.quantity}',
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
      ),
    );
  }

  // ─── Order Summary ────────────────────────────────────────────────────────

  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1.5),
      ),
      child: Column(
        children: [
          _summaryRow('Subtotal', order.formattedTotal),
          const SizedBox(height: 8),
          _summaryRow('Delivery Fee', 'Free', valueColor: _primary),
          const SizedBox(height: 12),
          const Divider(height: 1, color: _border),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: _textDark)),
              Text(order.formattedTotal,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: _primary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: _textLight)),
        Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
            color: valueColor ?? _textDark)),
      ],
    );
  }

  // ─── Info Card ────────────────────────────────────────────────────────────

  Widget _buildInfoCard({required IconData icon, required String content}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1.5),
      ),
      child: Row(
        children: [
          Icon(icon, color: _primary, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(content, style: const TextStyle(fontSize: 13, color: _textDark, height: 1.5))),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: _textDark));
  }
}

class _ProgressStep {
  final String label;
  final IconData icon;
  final bool done;
  const _ProgressStep(this.label, this.icon, this.done);
}