import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _baseUrl =
      'https://testing.rasmuspharmaceuticals.com/api/v1';
  static const String _tokenKey = 'token';
  static const String _userKey = 'user_data';
  static const Duration _timeout = Duration(seconds: 15);

  // ─── Helpers ──────────────────────────────────────────────────────────────

  /// Safely decode JSON; returns null on failure instead of throwing.
  Map<String, dynamic>? _tryDecode(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) return decoded;
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Extract the auth token from various API response shapes.
  String _extractToken(Map<String, dynamic> data) {
    return (data['token'] ??
            data['access_token'] ??
            data['data']?['token'] ??
            data['data']?['access_token'] ??
            '') as String;
  }

  /// Extract the user object from various API response shapes.
  Map<String, dynamic> _extractUser(Map<String, dynamic> data) {
    final user = data['user'] ?? data['data']?['user'] ?? {};
    return user is Map<String, dynamic> ? user : {};
  }

  bool _isEmail(String value) =>
      RegExp(r'^[\w\-.]+@([\w\-]+\.)+[\w\-]{2,}$').hasMatch(value);

  Map<String, String> get _headers => const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  // ─── Login ────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> login({
    required String emailOrContact,
    required String password,
  }) async {
    try {
      final body = <String, dynamic>{'password': password};
      if (_isEmail(emailOrContact)) {
        body['email'] = emailOrContact;
      } else {
        body['contact'] = emailOrContact;
      }

      final response = await http
          .post(
            Uri.parse('$_baseUrl/auth/login'),
            headers: _headers,
            body: jsonEncode(body),
          )
          .timeout(_timeout);

      print('Login [${response.statusCode}]: ${response.body}');

      final data = _tryDecode(response.body);

      if (response.statusCode == 200 && data != null) {
        final token = _extractToken(data);
        final prefs = await SharedPreferences.getInstance();
        if (token.isNotEmpty) {
          await prefs.setString(_tokenKey, token);
        }
        await prefs.setString(_userKey, jsonEncode(_extractUser(data)));
        return {'success': true, 'data': data, 'token': token};
      }

      final message = data?['message'] as String? ??
          _httpErrorMessage(response.statusCode);
      return {'success': false, 'message': message};
    } on SocketException {
      return {
        'success': false,
        'message': 'No internet connection. Please check your network.',
      };
    } on HttpException {
      return {
        'success': false,
        'message': 'Could not reach the server. Please try again.',
      };
    } catch (e) {
      print('Login error: $e');
      return {
        'success': false,
        'message': 'Something went wrong. Please try again.',
      };
    }
  }

  // ─── Register ─────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> register({
    required String name,
    required String emailOrContact,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final body = <String, dynamic>{
        'name': name,
        'password': password,
        'password_confirmation': passwordConfirmation,
      };
      if (_isEmail(emailOrContact)) {
        body['email'] = emailOrContact;
      } else {
        body['contact'] = emailOrContact;
      }

      final response = await http
          .post(
            Uri.parse('$_baseUrl/auth/register'),
            headers: _headers,
            body: jsonEncode(body),
          )
          .timeout(_timeout);

      print('Register [${response.statusCode}]: ${response.body}');

      final data = _tryDecode(response.body);

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          data != null) {
        final token = _extractToken(data);
        final prefs = await SharedPreferences.getInstance();
        if (token.isNotEmpty) {
          await prefs.setString(_tokenKey, token);
        }
        await prefs.setString(_userKey, jsonEncode(_extractUser(data)));
        return {'success': true, 'data': data};
      }

      // Handle Laravel-style validation errors: {"errors": {"email": ["..."]}}
      if (data != null && data['errors'] is Map) {
        final errors = data['errors'] as Map;
        final firstField = errors.values.first;
        final firstMsg = firstField is List && firstField.isNotEmpty
            ? firstField.first.toString()
            : data['message']?.toString() ?? 'Validation error.';
        return {'success': false, 'message': firstMsg};
      }

      final message = data?['message'] as String? ??
          _httpErrorMessage(response.statusCode);
      return {'success': false, 'message': message};
    } on SocketException {
      return {
        'success': false,
        'message': 'No internet connection. Please check your network.',
      };
    } on HttpException {
      return {
        'success': false,
        'message': 'Could not reach the server. Please try again.',
      };
    } catch (e) {
      print('Register error: $e');
      return {
        'success': false,
        'message': 'Something went wrong. Please try again.',
      };
    }
  }

  // ─── Forgot Password ──────────────────────────────────────────────────────
  Future<Map<String, dynamic>> forgotPassword({required String email}) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/auth/forgot-password'),
            headers: _headers,
            body: jsonEncode({'email': email}),
          )
          .timeout(_timeout);

      final data = _tryDecode(response.body);
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data?['message'] as String? ?? 'OTP sent to your email.',
        };
      }
      return {
        'success': false,
        'message': data?['message'] as String? ?? 'Email not found.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error. Please check your connection.',
      };
    }
  }

  // ─── Verify OTP ───────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/auth/verify-otp'),
            headers: _headers,
            body: jsonEncode({'email': email, 'otp': otp}),
          )
          .timeout(_timeout);

      final data = _tryDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'data': data ?? {}};
      }
      return {
        'success': false,
        'message': data?['message'] as String? ?? 'Invalid OTP.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error. Please check your connection.',
      };
    }
  }

  // ─── Reset Password ───────────────────────────────────────────────────────
  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/auth/reset-password'),
            headers: _headers,
            body: jsonEncode({
              'email': email,
              'otp': otp,
              'password': newPassword,
              'password_confirmation': newPassword,
            }),
          )
          .timeout(_timeout);

      final data = _tryDecode(response.body);
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message':
              data?['message'] as String? ?? 'Password reset successfully.',
        };
      }
      return {
        'success': false,
        'message': data?['message'] as String? ?? 'Reset failed.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error. Please check your connection.',
      };
    }
  }

  // ─── Local helpers ────────────────────────────────────────────────────────
  String _httpErrorMessage(int statusCode) {
    switch (statusCode) {
      case 401:
        return 'Invalid credentials. Please try again.';
      case 403:
        return 'Access denied.';
      case 404:
        return 'Service not found. Please contact support.';
      case 422:
        return 'Validation error. Please check your input.';
      case 429:
        return 'Too many attempts. Please wait a moment and try again.';
      case 500:
      case 502:
      case 503:
        return 'Server error. Please try again later.';
      default:
        return 'Something went wrong (error $statusCode).';
    }
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString(_userKey);
    if (userString != null && userString.isNotEmpty) {
      return _tryDecode(userString);
    }
    return null;
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }
}