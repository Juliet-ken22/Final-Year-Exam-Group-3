import 'package:flutter/material.dart';
import 'screens/auth/splash_screen.dart'; // ← changed

void main() {
  runApp(const MyApp());
}

// Minimal local CartProvider to satisfy references when the external
// providers/cart_provider.dart is missing or has a different class name.
// This mirrors the expected API used in this file: extends ChangeNotifier
// and exposes an integer totalItems getter.
class CartProvider extends ChangeNotifier {
  int _totalItems = 0;

  int get totalItems => _totalItems;

  void addItem() {
    _totalItems++;
    notifyListeners();
  }

  void removeItem() {
    if (_totalItems > 0) {
      _totalItems--;
      notifyListeners();
    }
  }
}

// Minimal local AuthProvider, ProductProvider, and OrderProvider to satisfy
// references when the external provider files are missing or have different
// class names. They mirror a simple ChangeNotifier API used by this file.
class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;

  void login() {
    _isAuthenticated = true;
    notifyListeners();
  }

  void logout() {
    _isAuthenticated = false;
    notifyListeners();
  }
}

class ProductProvider extends ChangeNotifier {
  // minimal placeholder; expand in real implementation
  List<dynamic> _products = [];

  List<dynamic> get products => _products;

  void setProducts(List<dynamic> items) {
    _products = items;
    notifyListeners();
  }
}

class OrderProvider extends ChangeNotifier {
  // minimal placeholder; expand in real implementation
  List<dynamic> _orders = [];

  List<dynamic> get orders => _orders;

  void addOrder(dynamic order) {
    _orders.add(order);
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NutriBlend',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF2D6A4F),
        scaffoldBackgroundColor: const Color(0xFFFAFAFA),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF1A1A1A),
          elevation: 0,
        ),
      ),
      home: const SplashScreen(), // ← changed
    );
  }
}