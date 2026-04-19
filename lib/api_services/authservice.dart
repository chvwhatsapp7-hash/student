import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import '../services/api_config.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final _storage = const FlutterSecureStorage();

  late final Dio dio;
  Dio get client => dio;

  String? accessToken;
  String? refreshToken;
  String? userId;
  String? roleId;
  String? fullName;

  /// Call once in main() before runApp.
  Future<void> init() async {
    accessToken = await _storage.read(key: 'accessToken');
    refreshToken = await _storage.read(key: 'refreshToken');
    userId = await _storage.read(key: 'user_id');
    roleId = await _storage.read(key: 'role_id');
    fullName = await _storage.read(key: 'full_name');

    dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (accessToken != null) {
            options.headers['Authorization'] = 'Bearer $accessToken';
          }
          handler.next(options);
        },
        onError: (err, handler) async {
          final response = err.response;
          final requestOptions = err.requestOptions;

          if (requestOptions.path.contains('/auth/refresh')) {
            await clearTokens();
            handler.next(err);
            return;
          }

          if (response?.statusCode == 401 && refreshToken != null) {
            final success = await refreshTokens();
            if (success) {
              final newOptions = requestOptions.copyWith(
                headers: {
                  ...requestOptions.headers,
                  'Authorization': 'Bearer $accessToken',
                },
              );
              try {
                final retried = await dio.fetch(newOptions);
                handler.resolve(retried);
              } on DioException catch (e) {
                handler.reject(e);
              }
            } else {
              await clearTokens();
              handler.next(err);
            }
          } else {
            handler.next(err);
          }
        },
      ),
    );
  }

  /// Returns true if the user has a valid, non-expired access token stored.
  Future<bool> isAuthenticated() async {
    final token = await _storage.read(key: 'accessToken');
    final uid = await _storage.read(key: 'user_id');
    if (token == null || token.isEmpty || uid == null || uid.isEmpty) {
      return false;
    }
    try {
      return !JwtDecoder.isExpired(token);
    } catch (_) {
      return false;
    }
  }

  /// Reload tokens from storage into memory.
  Future<void> loadTokens() async {
    accessToken = await _storage.read(key: 'accessToken');
    refreshToken = await _storage.read(key: 'refreshToken');
    userId = await _storage.read(key: 'user_id');
    roleId = await _storage.read(key: 'role_id');
    fullName = await _storage.read(key: 'full_name');
  }

  /// Save tokens to storage + update in-memory state.
  /// Named params match all existing callers in common_login_screen.dart.
  Future<void> saveTokens({
    required String access,
    String? refresh,
    String? user_id,
    String? role_id,
    String? full_name,
  }) async {
    accessToken = access;
    if (refresh != null) refreshToken = refresh;
    if (user_id != null) userId = user_id;
    if (role_id != null) roleId = role_id;
    if (full_name != null) fullName = full_name;

    await _storage.write(key: 'accessToken', value: access);
    if (refresh != null) {
      await _storage.write(key: 'refreshToken', value: refresh);
    }
    if (user_id != null) {
      await _storage.write(key: 'user_id', value: user_id);
    }
    if (role_id != null) {
      await _storage.write(key: 'role_id', value: role_id);
    }
    if (full_name != null) {
      await _storage.write(key: 'full_name', value: full_name);
    }
  }

  /// Try to refresh the access token using the stored refresh token.
  Future<bool> refreshTokens() async {
    if (refreshToken == null) {
      await clearTokens();
      return false;
    }

    try {
      final response = await dio.post(
        '/auth/refresh',
        options: Options(
          headers: {'Authorization': 'Bearer $refreshToken'},
          sendTimeout: const Duration(seconds: 5),
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final newAccess = data['accessToken'] as String?;
        final newRefresh = data['refreshToken'] as String?;

        if (newAccess == null) {
          await clearTokens();
          return false;
        }

        await saveTokens(access: newAccess, refresh: newRefresh);
        return true;
      } else {
        await clearTokens();
        return false;
      }
    } on DioException {
      await clearTokens();
      return false;
    } catch (_) {
      await clearTokens();
      return false;
    }
  }

  /// Log out: clear all tokens from memory and storage.
  Future<void> logout() async {
    await clearTokens();
  }

  /// Clear tokens in memory and storage.
  Future<void> clearTokens() async {
    accessToken = null;
    refreshToken = null;
    userId = null;
    roleId = null;
    fullName = null;
    await _storage.deleteAll();
  }

  /// Quick in-memory check (use isAuthenticated() for startup checks).
  bool get isLoggedIn => accessToken != null && userId != null;

  // Convenience wrappers
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) =>
      dio.get(path, queryParameters: queryParameters);

  Future<Response> post(String path, dynamic data) =>
      dio.post(path, data: data);
  Future<Response> put(String path, dynamic data) => dio.put(path, data: data);
  Future<Response> delete(String path, Map<String, int> body) =>
      dio.delete(path);
  // ── NEW: called by RoleSelectionScreen after a successful /auth/update-role ── /// Updates role_id in both memory and secure storage without touching /
  // any other stored value (tokens, userId, fullName stay unchanged).
  Future<void> updateRoleId(String newRoleId) async {
    roleId = newRoleId;
    await _storage.write(key: 'role_id', value: newRoleId);
  }
}
