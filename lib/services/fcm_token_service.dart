import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class FcmTokenService {
  static const String baseUrl =
      "https://your-backend-url.com/api/notifications/token";

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

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $authToken",
        },
        body: jsonEncode({"token": token}),
      );

      if (response.statusCode == 200) {
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