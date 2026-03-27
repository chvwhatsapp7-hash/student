import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'authservice.dart';

class CourseService {
  // 🔐 Secure Storage
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  // 🌐 Base URL
  static const String baseUrl =
      "https://studenthub-backend-woad.vercel.app/api/course-enrollments";

  // ─────────────────────────────────────────────
  // ✅ GET USER ID
  // ─────────────────────────────────────────────
  static Future<int?> getUserId() async {
    final userIdStr = await _storage.read(key: "user_id");
    if (userIdStr == null) return null;
    return int.tryParse(userIdStr);
  }

  // ─────────────────────────────────────────────
  // ✅ ENROLL (POST)
  // ─────────────────────────────────────────────
  static Future<String> enroll(int courseId) async {
    final userId = await getUserId();
    await AuthService().loadTokens();
    final token = AuthService().accessToken;

    if (token == null) {
      throw Exception("Token is null. Please login again.");
    }

    if (userId == null) {
      return "User not logged in";
    }

    final url = Uri.parse(baseUrl);

    final body = {"user_id": userId, "course_id": courseId};

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return "Enrolled successfully";
      } else {
        return data["message"] ?? "Something went wrong";
      }
    } catch (e) {
      return "Error: $e";
    }
  }

  // ─────────────────────────────────────────────
  // ✅ UNENROLL (DELETE)
  // ─────────────────────────────────────────────
  static Future<String> unenroll(int courseId) async {
    final userId = await getUserId();

    if (userId == null) {
      return "User not logged in";
    }

    final url = Uri.parse(baseUrl);

    final body = {"user_id": userId, "course_id": courseId};

    try {
      final response = await http.delete(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return "Unenrolled successfully";
      } else {
        return data["message"] ?? "Something went wrong";
      }
    } catch (e) {
      return "Error: $e";
    }
  }

  // ─────────────────────────────────────────────
  // ✅ GET ENROLLED COURSES (NEW)
  // ─────────────────────────────────────────────
  static Future<List<Map<String, dynamic>>> getEnrolledCourses() async {
    final userId = await getUserId();
    await AuthService().loadTokens();
    final token = AuthService().accessToken;

    if (token == null) {
      throw Exception("Token is null. Please login again.");
    }

    if (userId == null) {
      return [];
    }

    final url = Uri.parse("$baseUrl?user_id=$userId");

    try {
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(data["data"]);
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  // ─────────────────────────────────────────────
  // ✅ CHECK IF ENROLLED (HELPFUL FOR UI)
  // ─────────────────────────────────────────────
  static Future<bool> isEnrolled(int courseId) async {
    final courses = await getEnrolledCourses();

    return courses.any((c) => c["course_id"] == courseId);
  }

  // ─────────────────────────────────────────────
  // ✅ SAVE USER ID (AFTER LOGIN)
  // ─────────────────────────────────────────────
  static Future<void> saveUserId(int userId) async {
    await _storage.write(key: "user_id", value: userId.toString());
  }

  // ─────────────────────────────────────────────
  // ✅ LOGOUT
  // ─────────────────────────────────────────────
  static Future<void> logout() async {
    await _storage.deleteAll();
  }
}
