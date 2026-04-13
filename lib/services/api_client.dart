import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  static const String baseUrl = 'https://your-api.com/api'; // 🔁 replace
  static const _storage = FlutterSecureStorage();

  // ── Token helpers ─────────────────────────────────────────────

  static Future<String?> getToken() => _storage.read(key: 'jwt_token');

  static Future<void> saveToken(String token) =>
      _storage.write(key: 'jwt_token', value: token);

  static Future<void> clearToken() => _storage.delete(key: 'jwt_token');

  // ── Base headers ──────────────────────────────────────────────

  static Future<Map<String, String>> _headers() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ── HTTP helpers ──────────────────────────────────────────────

  static Future<http.Response> get(String path) async {
    final uri = Uri.parse('$baseUrl$path');
    return http.get(uri, headers: await _headers());
  }

  static Future<http.Response> post(String path, Map<String, dynamic> body) async {
    final uri = Uri.parse('$baseUrl$path');
    return http.post(uri,
        headers: await _headers(), body: jsonEncode(body));
  }

  static Future<http.Response> put(String path, Map<String, dynamic> body) async {
    final uri = Uri.parse('$baseUrl$path');
    return http.put(uri,
        headers: await _headers(), body: jsonEncode(body));
  }

  static Future<http.Response> patch(String path, Map<String, dynamic> body) async {
    final uri = Uri.parse('$baseUrl$path');
    return http.patch(uri,
        headers: await _headers(), body: jsonEncode(body));
  }

  static Future<http.Response> delete(String path) async {
    final uri = Uri.parse('$baseUrl$path');
    return http.delete(uri, headers: await _headers());
  }

  // ── Response parser — throws on non-2xx ───────────────────────

  static Map<String, dynamic> parse(http.Response res) {
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode >= 200 && res.statusCode < 300) return body;
    throw ApiException(
      statusCode: res.statusCode,
      message: body['message'] as String? ?? 'Unknown error',
    );
  }

  static List<dynamic> parseList(http.Response res) {
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body) as List<dynamic>;
    }
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    throw ApiException(
      statusCode: res.statusCode,
      message: body['message'] as String? ?? 'Unknown error',
    );
  }
}

// ── Custom exception ──────────────────────────────────────────────

class ApiException implements Exception {
  final int    statusCode;
  final String message;
  const ApiException({required this.statusCode, required this.message});

  @override
  String toString() => 'ApiException($statusCode): $message';
}