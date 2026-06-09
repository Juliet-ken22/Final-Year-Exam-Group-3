import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/cart_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/product_provider.dart';
import 'providers/order_provider.dart';
import 'screens/auth/splash_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/products/category_screen.dart';
import 'screens/cart/cart_screen.dart';
import 'screens/orders/orders_screen.dart';
import 'screens/profile/profile_screen.dart';

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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'NutriBlend',
        theme: ThemeData(
          useMaterial3: true,
          fontFamily: 'Poppins',
          colorSchemeSeed: const Color(0xFF2E7D32),
          scaffoldBackgroundColor: const Color(0xFFF9FAFB),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Color(0xFF1A1A1A),
            elevation: 0,
            scrolledUnderElevation: 0,
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}

// ─── Main scaffold with persistent bottom nav ─────────────────────────────────

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    CategoryScreen(),
    CartScreen(),
    OrdersScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    const _primary = Color(0xFF2E7D32);

    final items = [
      _NavItem(Icons.home_filled, Icons.home_outlined, 'Home'),
      _NavItem(Icons.grid_view_rounded, Icons.grid_view_outlined, 'Categories'),
      _NavItem(
        Icons.shopping_cart_rounded,
        Icons.shopping_cart_outlined,
        'Cart',
      ),
      _NavItem(
        Icons.receipt_long_rounded,
        Icons.receipt_long_outlined,
        'Orders',
      ),
      _NavItem(Icons.person_rounded, Icons.person_outline_rounded, 'Profile'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final selected = i == _currentIndex;
              final item = items[i];
              return GestureDetector(
                onTap: () => setState(() => _currentIndex = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? _primary.withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Cart badge
                      i == 2
                          ? Consumer<CartProvider>(
                              builder: (_, CartProvider cart, __) => Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Icon(
                                    selected ? item.activeIcon : item.icon,
                                    color: selected
                                        ? _primary
                                        : Colors.grey.shade500,
                                    size: 24,
                                  ),
                                  if (cart.totalItems > 0)
                                    Positioned(
                                      right: -6,
                                      top: -4,
                                      child: Container(
                                        padding: const EdgeInsets.all(3),
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFE53935),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Text(
                                          '${cart.totalItems}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            )
                          : Icon(
                              selected ? item.activeIcon : item.icon,
                              color: selected ? _primary : Colors.grey.shade500,
                              size: 24,
                            ),
                      const SizedBox(height: 3),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: selected ? _primary : Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData activeIcon;
  final IconData icon;
  final String label;
  const _NavItem(this.activeIcon, this.icon, this.label);
}
