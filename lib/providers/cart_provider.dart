import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../models/cart_model.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get totalItems =>
      _items.fold<int>(0, (sum, item) => sum + item.quantity);

  bool get isEmpty => _items.isEmpty;

  String get formattedTotal {
    double total = 0;

    for (final item in _items) {
      final cleaned = item.product.formattedPrice
          .replaceAll('UGX', '')
          .replaceAll(',', '')
          .trim();

      total += (double.tryParse(cleaned) ?? 0.0) * item.quantity;
    }

    return 'UGX ${total.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    )}';
  }

  // ─── Add to cart ──────────────────────────────────────────────────────────
  void addProduct(Product product) {
    final index = _items.indexWhere((i) => i.product.id == product.id);

    if (index >= 0) {
      _items[index].quantity++;
    } else {
      _items.add(CartItem(product: product));
    }

    notifyListeners();
  }

  // ─── Remove from cart ─────────────────────────────────────────────────────
  void removeProduct(int productId) {
    _items.removeWhere((i) => i.product.id == productId);
    notifyListeners();
  }

  // ─── Increment quantity ───────────────────────────────────────────────────
  void increment(int productId) {
    final index = _items.indexWhere((i) => i.product.id == productId);

    if (index >= 0) {
      _items[index].quantity++;
      notifyListeners();
    }
  }

  // ─── Decrement quantity ───────────────────────────────────────────────────
  void decrement(int productId) {
    final index = _items.indexWhere((i) => i.product.id == productId);

    if (index >= 0) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
      } else {
        _items.removeAt(index);
      }

      notifyListeners();
    }
  }

  // ─── Clear cart ───────────────────────────────────────────────────────────
  void clear() {
    _items.clear();
    notifyListeners();
  }

  // ─── Check if product is in cart ──────────────────────────────────────────
  bool contains(int productId) {
    return _items.any((i) => i.product.id == productId);
  }

  int quantityOf(int productId) {
    final index = _items.indexWhere((i) => i.product.id == productId);
    return index >= 0 ? _items[index].quantity : 0;
  }
}

class CartItem {
  final Product product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });

  /// Subtotal for this cart item
  double get subtotal {
    final cleaned = product.formattedPrice
        .replaceAll('UGX', '')
        .replaceAll(',', '')
        .trim();

    final price = double.tryParse(cleaned) ?? 0.0;

    return price * quantity;
  }

  /// Formatted subtotal display
  String get formattedSubtotal {
    return 'UGX ${subtotal.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    )}';
  }
}