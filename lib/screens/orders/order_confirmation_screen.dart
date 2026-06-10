import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../main_navigation_screen.dart';

class OrderConfirmationScreen extends StatelessWidget {
  final Map<String, dynamic> orderData;
  const OrderConfirmationScreen({super.key, required this.orderData});

  @override
  Widget build(BuildContext context) {
    final orderId =
        orderData['id'] ?? orderData['order_id'] ?? orderData['data']?['id'];
    final total = orderData['total'] ??
        orderData['amount'] ??
        orderData['data']?['total'];

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Success icon
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withOpacity(0.3),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 60,
                ),
              ),
              const SizedBox(height: 28),

              const Text(
                'Order Placed!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Thank you for your order. We\'ll notify you when it\'s on its way.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: AppTheme.textMedium,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),

              // Order info card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: AppTheme.cardDecoration,
                child: Column(
                  children: [
                    if (orderId != null)
                      _InfoRow(
                        label: 'Order ID',
                        value: '#$orderId',
                      ),
                    if (total != null) ...[
                      const SizedBox(height: 10),
                      _InfoRow(
                        label: 'Total',
                        value: 'KES $total',
                      ),
                    ],
                    const SizedBox(height: 10),
                    _InfoRow(
                      label: 'Status',
                      value: 'Confirmed',
                      valueColor: Colors.green,
                    ),
                  ],
                ),
              ),

              const Spacer(),

              ElevatedButton.icon(
                onPressed: () => Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
                  (route) => false,
                ),
                icon: const Icon(Icons.storefront_outlined),
                label: const Text('Continue Shopping'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
                  (route) => false,
                ),
                child: const Text('Go to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
                color: AppTheme.textMedium, fontSize: 14)),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? AppTheme.textDark,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}