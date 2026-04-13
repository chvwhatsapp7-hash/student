import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/backend_notification.dart';

class BackendNotificationService {
  static const String baseUrl =
      "https://your-backend-url.com/api/notifications";

  Future<List<BackendNotification>> fetchNotifications(
      String authToken) async {
    final response = await http.get(
      Uri.parse('$baseUrl/token'),
      headers: {
        'Authorization': 'Bearer $authToken',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List items = data['items'];
      return items
          .map((e) => BackendNotification.fromJson(e))
          .toList();
    } else {
      throw Exception('Failed to fetch notifications');
    }
  }
}