import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../services/api_config.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final _storage = const FlutterSecureStorage();

  late final Dio dio;
  Dio get client => dio; // expose this for widget calls

  String? accessToken;
  String? refreshToken;
  String? userId;
  String? roleId;
  String? fullName;

  /// Initialize once when app starts; loads tokens and sets up Dio.
  Future<void> init() async {
    // Load saved tokens from storage
    accessToken = await _storage.read(key: 'accessToken');
    refreshToken = await _storage.read(key: 'refreshToken');
    userId = await _storage.read(key: 'user_id');
    roleId = await _storage.read(key: 'role_id');
    fullName = await _storage.read(key: 'full_name');

    // Setup Dio
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );

    // Auth interceptor
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

          // Avoid infinite loops when calling /auth/refresh
          if (requestOptions.path.contains('/auth/refresh')) {
            await clearTokens();
            handler.next(err);
            return;
          }

          if (response?.statusCode == 401 && refreshToken != null) {
            final success = await refreshTokens();
            if (success) {
              // Retry the original request with new token
              final newOptions = requestOptions.copyWith(
                headers: {
                  ...requestOptions.headers,
                  'Authorization': 'Bearer $accessToken',
                },
              );
              try {
                final response = await dio.fetch(newOptions);
                handler.resolve(response);
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

  /// Reload tokens from storage into memory (use after login / init).
  Future<void> loadTokens() async {
    accessToken = await _storage.read(key: 'accessToken');
    refreshToken = await _storage.read(key: 'refreshToken');
    userId = await _storage.read(key: 'user_id');
    roleId = await _storage.read(key: 'role_id');
    fullName = await _storage.read(key: 'full_name');
  }

  /// Save tokens to storage + update in‑memory state.
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

  /// Call /auth/refresh endpoint to get new tokens.
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
    } catch (e) {
      await clearTokens();
      return false;
    }
  }

  /// Log out the user (clear tokens).
  Future<void> logout() async {
    await clearTokens();
    // TODO: route to /login (e.g., context.go('/login'))
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

  /// Whether user is logged in (token + user_id present).
  bool get isLoggedIn => accessToken != null && userId != null;

  // Convenience wrappers around dio
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async => dio.get(path, queryParameters: queryParameters);

  Future<Response> post(String path, dynamic data) async =>
      dio.post(path, data: data);

  Future<Response> put(String path, dynamic data) async =>
      dio.put(path, data: data);

  Future<Response> delete(String path) async => dio.delete(path);
}
