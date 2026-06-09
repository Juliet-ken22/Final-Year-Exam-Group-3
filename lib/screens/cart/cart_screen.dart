import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../models/cart_model.dart';
import 'checkout_screen.dart';

const _primary = Color(0xFF2E7D32);
const _primaryLight = Color(0xFF4CAF50);
const _textDark = Color(0xFF1A1A1A);
const _textLight = Color(0xFF757575);
const _border = Color(0xFFE0E0E0);

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ No Scaffold — MainNavigationScreen owns it
    return SafeArea(
      child: Column(
        children: [
          // ── App Bar ────────────────────────────────────────────────────
          _buildAppBar(context),

          // ── Body ───────────────────────────────────────────────────────
          Expanded(
            child: Consumer<CartProvider>(
              builder: (_, cart, __) {
                if (cart.isEmpty) return _buildEmpty(context);
                return Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                        itemCount: cart.items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (_, i) =>
                            _CartItemCard(item: cart.items[i]),
                      ),
                    ),
                    _buildOrderSummary(context, cart),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ─── App Bar ──────────────────────────────────────────────────────────────

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('My Cart',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: _textDark)),
                Text('Review your items',
                    style: TextStyle(fontSize: 12, color: _textLight)),
              ],
            ),
          ),
          Consumer<CartProvider>(
            builder: (ctx, cart, __) => cart.isEmpty
                ? const SizedBox()
                : TextButton(
                    onPressed: () => _confirmClear(ctx),
                    child: const Text('Clear All',
                        style: TextStyle(
                            color: Color(0xFFD32F2F),
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                  ),
          ),
        ],
      ),
    );
  }

  // ─── Order Summary ────────────────────────────────────────────────────────

  Widget _buildOrderSummary(BuildContext context, CartProvider cart) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, -4))
        ],
      ),
      child: Column(
        children: [
          _summaryRow(
              'Subtotal (${cart.totalItems} items)', cart.formattedTotal),
          const SizedBox(height: 6),
          _summaryRow('Delivery Fee', 'Free', valueColor: _primary),
          const SizedBox(height: 12),
          const Divider(height: 1, color: _border),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: _textDark)),
              Text(cart.formattedTotal,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: _primary)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CheckoutScreen()),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shopping_bag_outlined, size: 20),
                  const SizedBox(width: 8),
                  Text('Checkout • ${cart.formattedTotal}',
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
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
        Text(value,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: valueColor ?? _textDark)),
      ],
    );
  }

  // ─── Empty State ──────────────────────────────────────────────────────────

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: _primary.withOpacity(0.06),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.shopping_cart_outlined,
                  size: 60, color: _primary),
            ),
            const SizedBox(height: 20),
            const Text('Your cart is empty',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: _textDark)),
            const SizedBox(height: 8),
            const Text('Add items from the store to get started',
                style: TextStyle(fontSize: 13, color: _textLight),
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.storefront_outlined),
              label: const Text('Browse Products'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Confirm Clear ────────────────────────────────────────────────────────

  void _confirmClear(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Clear Cart?',
            style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Text('Remove all items from your cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                const Text('Cancel', style: TextStyle(color: _textLight)),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<CartProvider>().clear();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}

// ─── Cart Item Card ───────────────────────────────────────────────────────────

class _CartItemCard extends StatelessWidget {
  final CartItem item;
  const _CartItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border, width: 1.5),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          // Product image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 80,
              height: 80,
              child: item.product.image != null
                  ? Image.network(item.product.image!, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholder())
                  : _placeholder(),
            ),
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(item.product.name,
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: _textDark),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                    ),
                    GestureDetector(
                      onTap: () => cart.removeProduct(item.product.id),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        child: const Icon(Icons.close_rounded,
                            size: 16, color: _textLight),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                if (item.product.category != null)
                  Text(item.product.category!,
                      style: const TextStyle(
                          fontSize: 11,
                          color: _primaryLight,
                          fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(item.formattedSubtotal,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: _primary)),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () =>
                                cart.decrement(item.product.id),
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: item.quantity > 1
                                    ? _primary
                                    : Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.remove_rounded,
                                  color: Colors.white, size: 16),
                            ),
                          ),
                          SizedBox(
                            width: 32,
                            child: Text('${item.quantity}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: _textDark)),
                          ),
                          GestureDetector(
                            onTap: () =>
                                cart.increment(item.product.id),
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: _primary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.add_rounded,
                                  color: Colors.white, size: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() => Container(
        color: _primaryLight.withOpacity(0.05),
        child: const Center(
            child: Icon(Icons.spa_rounded, color: _primaryLight, size: 32)),
      );
}