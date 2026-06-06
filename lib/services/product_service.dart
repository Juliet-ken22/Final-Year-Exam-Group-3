import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';

class ProductService {
  static const _baseUrl = 'https://corsproxy.io/?https://admin.rasmuspharmaceuticals.com/api/v1';

  Future<List<Product>> fetchProducts() async {
    final response = await http.get(Uri.parse('$_baseUrl/products'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['data'] as List).map((p) => Product.fromJson(p)).toList();
    }
    throw Exception('Failed to load products: ${response.statusCode}');
  }
}