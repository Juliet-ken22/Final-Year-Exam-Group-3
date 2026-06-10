import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ApiService {
  static const String _baseUrl =
      'https://testing.rasmuspharmaceuticals.com/api/v1';
  static const Duration _timeout = Duration(seconds: 15);

  // ─── Helpers ──────────────────────────────────────────────────────────────

  Map<String, String> get _publicHeaders => const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  Future<Map<String, String>> get _authHeaders async {
    final token = await AuthService().getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Map<String, dynamic>? _tryDecode(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) return decoded;
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Unwrap list from common API response shapes:
  /// { data: [...] }  or  { products: [...] }  or  plain [...]
  List<dynamic> _extractList(dynamic body, [String? key]) {
    if (body is List) return body;
    if (body is Map<String, dynamic>) {
      if (key != null && body[key] is List) return body[key] as List;
      if (body['data'] is List) return body['data'] as List;
    }
    return [];
  }

  String _httpErrorMessage(int statusCode) {
    switch (statusCode) {
      case 401: return 'Unauthorised. Please log in again.';
      case 403: return 'Access denied.';
      case 404: return 'Resource not found.';
      case 422: return 'Validation error. Please check your input.';
      case 429: return 'Too many requests. Please wait a moment.';
      case 500:
      case 502:
      case 503: return 'Server error. Please try again later.';
      default:  return 'Something went wrong (error $statusCode).';
    }
  }

  // ─── Products ─────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getProducts() async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/products'),
            headers: _publicHeaders,
          )
          .timeout(_timeout);

      final data = _tryDecode(response.body);

      if (response.statusCode == 200 && data != null) {
        return {'success': true, 'data': _extractList(data, 'products')};
      }

      return {
        'success': false,
        'message': data?['message'] as String? ??
            _httpErrorMessage(response.statusCode),
      };
    } on SocketException {
      return {'success': false, 'message': 'No internet connection.'};
    } catch (e) {
      return {'success': false, 'message': 'Failed to load products.'};
    }
  }

  // ─── Regions ──────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getRegions() async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/regions'),
            headers: _publicHeaders,
          )
          .timeout(_timeout);

      final data = _tryDecode(response.body);

      if (response.statusCode == 200 && data != null) {
        return {'success': true, 'data': _extractList(data, 'regions')};
      }

      return {
        'success': false,
        'message': data?['message'] as String? ??
            _httpErrorMessage(response.statusCode),
      };
    } on SocketException {
      return {'success': false, 'message': 'No internet connection.'};
    } catch (e) {
      return {'success': false, 'message': 'Failed to load regions.'};
    }
  }

  // ─── Towns by Region ──────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getTownsByRegion(int regionId) async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/regions/$regionId/towns'),
            headers: _publicHeaders,
          )
          .timeout(_timeout);

      final data = _tryDecode(response.body);

      if (response.statusCode == 200 && data != null) {
        return {'success': true, 'data': _extractList(data, 'towns')};
      }

      return {
        'success': false,
        'message': data?['message'] as String? ??
            _httpErrorMessage(response.statusCode),
      };
    } on SocketException {
      return {'success': false, 'message': 'No internet connection.'};
    } catch (e) {
      return {'success': false, 'message': 'Failed to load towns.'};
    }
  }

  // ─── Place Order ──────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> placeOrder({
    required List<Map<String, dynamic>> items,
    required String deliveryMethod,
    required int deliveryRegionId,
    required int deliveryTownId,
    required String deliveryAddress,
  }) async {
    try {
      final headers = await _authHeaders;
      final response = await http
          .post(
            Uri.parse('$_baseUrl/orders'),
            headers: headers,
            body: jsonEncode({
              'items': items,
              'delivery_method': deliveryMethod,
              'delivery_region_id': deliveryRegionId,
              'delivery_town_id': deliveryTownId,
              'delivery_address': deliveryAddress,
            }),
          )
          .timeout(_timeout);

      print('PlaceOrder [${response.statusCode}]: ${response.body}');

      final data = _tryDecode(response.body);

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          data != null) {
        return {'success': true, 'data': data};
      }

      // Laravel validation errors
      if (data != null && data['errors'] is Map) {
        final errors = data['errors'] as Map;
        final firstField = errors.values.first;
        final firstMsg = firstField is List && firstField.isNotEmpty
            ? firstField.first.toString()
            : data['message']?.toString() ?? 'Validation error.';
        return {'success': false, 'message': firstMsg};
      }

      return {
        'success': false,
        'message': data?['message'] as String? ??
            _httpErrorMessage(response.statusCode),
      };
    } on SocketException {
      return {'success': false, 'message': 'No internet connection.'};
    } catch (e) {
      return {'success': false, 'message': 'Failed to place order.'};
    }
  }
}