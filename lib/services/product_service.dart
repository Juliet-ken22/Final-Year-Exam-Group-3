import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product_model.dart';

class ProductService {
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

  // ─── Fetch all products ───────────────────────────────────────────────────
  Future<List<Product>> fetchProducts({String? category}) async {
    try {
      final uri = Uri.parse('$_baseUrl/products').replace(
        queryParameters: category != null ? {'category': category} : null,
      );
      final response = await http.get(uri, headers: await _authHeaders());
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List list = data['data'] ?? data['products'] ?? data ?? [];
        return list.map((e) => Product.fromJson(e)).toList();
      }
      throw Exception('Failed to load products');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // ─── Fetch single product ─────────────────────────────────────────────────
  Future<Product> fetchProduct(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/products/$id'),
        headers: await _authHeaders(),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Product.fromJson(data['data'] ?? data);
      }
      throw Exception('Product not found');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // ─── Fetch categories ─────────────────────────────────────────────────────
  Future<List<String>> fetchCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/categories'),
        headers: await _authHeaders(),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List list = data['data'] ?? data['categories'] ?? data ?? [];
        return list.map((e) => e['name']?.toString() ?? '').toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}