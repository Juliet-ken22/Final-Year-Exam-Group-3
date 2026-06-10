import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/region_model.dart';
import '../../models/product_model.dart';
import '../../providers/cart_provider.dart';
import '../../services/api_service.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/common/shimmer_widgets.dart';
import '../orders/order_confirmation_screen.dart';

class AuthProvider {
  final String? token;

  AuthProvider({this.token});
}


class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();

  List<Region> _regions = [];
  List<Town> _towns = [];
  Region? _selectedRegion;
  Town? _selectedTown;

  bool _loadingRegions = true;
  bool _loadingTowns = false;
  bool _submitting = false;
  String? _errorMessage;
  String _deliveryMethod = 'delivery';

  @override
  void initState() {
    super.initState();
    _fetchRegions();
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _fetchRegions() async {
    setState(() {
      _loadingRegions = true;
      _errorMessage = null;
    });
    try {
      final apiService = ApiService();
      final raw = await apiService.getRegions();
      final regionsJson = raw is List
          ? raw
          : raw is Map
          ? raw['regions'] ?? raw['data'] ?? []
          : [];
      setState(() {
        _regions = (regionsJson as List)
            .map((e) => Region.fromJson(e as Map<String, dynamic>))
            .toList();
        _loadingRegions = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load regions: ${e.toString()}';
        _loadingRegions = false;
      });
    }
  }

  Future<void> _onRegionChanged(Region? region) async {
    setState(() {
      _selectedRegion = region;
      _selectedTown = null;
      _towns = [];
    });
    if (region == null) return;

    setState(() => _loadingTowns = true);
    try {
      final apiService = ApiService();
      final raw = await apiService.getTownsByRegion(region.id);
      final townsJson = raw is List
          ? raw
          : raw is Map
          ? raw['towns'] ?? raw['data'] ?? []
          : [];
      setState(() {
        _towns = (townsJson as List)
            .map((e) => Town.fromJson(e as Map<String, dynamic>))
            .toList();
        _loadingTowns = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load towns: ${e.toString()}';
        _loadingTowns = false;
      });
    }
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRegion == null) {
      setState(() => _errorMessage = 'Please select a region');
      return;
    }
    if (_selectedTown == null) {
      setState(() => _errorMessage = 'Please select a town');
      return;
    }

    setState(() {
      _submitting = true;
      _errorMessage = null;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.token == null) {
        setState(() => _errorMessage = 'Authentication token not found');
        return;
      }
      final cartItems = context
          .read<CartProvider>()
          .items
          .map(
            (item) => {
              'product_id': item.product.id,
              'quantity': item.quantity,
            },
          )
          .toList();

      final apiService = ApiService();
      final data = await apiService.placeOrder(
        items: cartItems,
        deliveryMethod: _deliveryMethod,
        deliveryRegionId: _selectedRegion!.id,
        deliveryTownId: _selectedTown!.id,
        deliveryAddress: _addressController.text.trim(),
      );

      if (!mounted) return;
      context.read<CartProvider>().clear();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => OrderConfirmationScreen(orderData: data),
        ),
      );
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Checkout')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order summary card
              _SummaryCard(cart: cart),
              const SizedBox(height: 20),

              if (_errorMessage != null) ...[
                ErrorBanner(message: _errorMessage!),
                const SizedBox(height: 12),
              ],

              // Delivery method
              const Text(
                'Delivery Method',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _DeliveryOption(
                    label: 'Delivery',
                    value: 'delivery',
                    icon: Icons.local_shipping_outlined,
                    selected: _deliveryMethod == 'delivery',
                    onTap: () => setState(() => _deliveryMethod = 'delivery'),
                  ),
                  const SizedBox(width: 12),
                  _DeliveryOption(
                    label: 'Pickup',
                    value: 'pickup',
                    icon: Icons.storefront_outlined,
                    selected: _deliveryMethod == 'pickup',
                    onTap: () => setState(() => _deliveryMethod = 'pickup'),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Region dropdown
              const Text(
                'Delivery Location',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 10),

              if (_loadingRegions)
                const ShimmerBox(width: double.infinity, height: 52)
              else
                DropdownButtonFormField<Region>(
                  value: _selectedRegion,
                  decoration: const InputDecoration(
                    labelText: 'Select Region',
                    prefixIcon: Icon(Icons.map_outlined),
                  ),
                  items: _regions
                      .map(
                        (r) => DropdownMenuItem(value: r, child: Text(r.name)),
                      )
                      .toList(),
                  onChanged: _onRegionChanged,
                  validator: (v) => v == null ? 'Please select a region' : null,
                ),
              const SizedBox(height: 14),

              // Towns dropdown (cascades from region)
              if (_loadingTowns)
                const ShimmerBox(width: double.infinity, height: 52)
              else
                DropdownButtonFormField<Town>(
                  value: _selectedTown,
                  decoration: InputDecoration(
                    labelText: _selectedRegion == null
                        ? 'Select region first'
                        : 'Select Town',
                    prefixIcon: const Icon(Icons.location_city_outlined),
                  ),
                  items: _towns
                      .map(
                        (t) => DropdownMenuItem(value: t, child: Text(t.name)),
                      )
                      .toList(),
                  onChanged: _selectedRegion == null
                      ? null
                      : (t) => setState(() => _selectedTown = t),
                  validator: (v) => v == null ? 'Please select a town' : null,
                ),
              const SizedBox(height: 14),

              // Delivery address
              TextFormField(
                controller: _addressController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Delivery Address',
                  hintText: 'Street, building, apartment…',
                  prefixIcon: Icon(Icons.home_outlined),
                  alignLabelWithHint: true,
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Delivery address is required'
                    : null,
              ),
              const SizedBox(height: 28),

              // Order total
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.primary.withOpacity(0.15)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Order Total',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textDark,
                      ),
                    ),
                    Text(
                      cart.formattedTotal,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              LoadingButton(
                isLoading: _submitting,
                onPressed: _placeOrder,
                label: 'Place Order',
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final CartProvider cart;
  const _SummaryCard({required this.cart});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.receipt_long_outlined,
                color: AppTheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Order Summary',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark,
                ),
              ),
              const Spacer(),
              Text(
                '${cart.items.length} item${cart.items.length == 1 ? '' : 's'}',
                style: const TextStyle(
                  color: AppTheme.textMedium,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          ...cart.items.map(
            (item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${item.product.name} × ${item.quantity}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ),
                  Text(
                    item.formattedSubtotal,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textDark,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeliveryOption extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _DeliveryOption({
    required this.label,
    required this.value,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? AppTheme.primary : AppTheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppTheme.primary : AppTheme.divider,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: selected ? Colors.white : AppTheme.textMedium),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: selected ? Colors.white : AppTheme.textMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
