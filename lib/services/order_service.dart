import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/order_model.dart';

class OrderService {
  static const String _baseUrl =
      'https://corsproxy.io/?https://admin.rasmuspharmaceuticals.com/api/v1';

  Future<Map<String, String>> _authHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  // ─── Fetch all orders ─────────────────────────────────────────────────────
  Future<List<Order>> fetchOrders() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/orders'),
        headers: await _authHeaders(),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List list = data['data'] ?? data['orders'] ?? data ?? [];
        return list.map((e) => Order.fromJson(e)).toList();
      }
      throw Exception('Failed to load orders: ${response.statusCode}');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // ─── Fetch single order ───────────────────────────────────────────────────
  Future<Order> fetchOrder(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/orders/$id'),
        headers: await _authHeaders(),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Order.fromJson(data['data'] ?? data);
      }
      throw Exception('Order not found');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // ─── Place order ──────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> placeOrder({
    required List<Map<String, dynamic>> items,
    required String shippingAddress,
    String? paymentMethod,
    String? notes,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/orders'),
        headers: await _authHeaders(),
        body: jsonEncode({
          'items': items,
          'shipping_address': shippingAddress,
          if (paymentMethod != null) 'payment_method': paymentMethod,
          if (notes != null) 'notes': notes,
        }),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': data};
      }
      return {'success': false, 'message': data['message'] ?? 'Failed to place order.'};
    } catch (e) {
      return {'success': false, 'message': 'Network error. Please check your connection.'};
    }
  }

  // ─── Cancel order ─────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> cancelOrder(int id) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/orders/$id/cancel'),
        headers: await _authHeaders(),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message'] ?? 'Order cancelled.'};
      }
      return {'success': false, 'message': data['message'] ?? 'Could not cancel order.'};
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
}