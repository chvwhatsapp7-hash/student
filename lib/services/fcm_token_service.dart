import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'api_config.dart';

class FcmTokenService {
  static String get baseUrl => "${ApiConfig.baseUrl}/notifications/token";

  /// Sends the FCM token to the backend
  static Future<void> sendTokenToBackend(String authToken) async {
    try {
      final String? token =
      await FirebaseMessaging.instance.getToken();

      if (token == null) {
        debugPrint("⚠️ Failed to retrieve FCM token");
        return;
      }

      debugPrint("📱 FCM TOKEN: $token");

      // Use AuthService (which handles Base URL automatically if configured)
      // or we can use the `baseUrl` explicitly with the underlying HTTP package logic
      // But since we just pass the auth token directly from the parameter here,
      // we'll keep the http call with the parameter token. Actually, we can use http here 
      // since the Token is literally being explicitly passed in.
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $authToken",
        },
        body: jsonEncode({"token": token}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint("✅ FCM token sent successfully");
      } else {
        debugPrint(
            "❌ Failed to send FCM token: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("❌ Error sending FCM token: $e");
    }
  }

  /// Listens for token refresh
  static void listenToTokenRefresh(String authToken) {
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      debugPrint("🔄 Refreshed FCM Token: $newToken");

      await http.post(
        Uri.parse(baseUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $authToken",
        },
        body: jsonEncode({"token": newToken}),
      );
    });
  }
}