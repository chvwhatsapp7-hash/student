import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'authservice.dart';

class ApplicationsService {
  // 🔐 Secure Storage
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  // 🌐 Base URL
  static const String baseUrl =
      "https://studenthub-backend-woad.vercel.app/api";

  // ─────────────────────────────────────────────
  // ✅ GET USER ID FROM STORAGE
  // ─────────────────────────────────────────────
  static Future<int?> getUserId() async {
    final userIdStr = await _storage.read(key: "user_id");
    if (userIdStr == null) return null;
    return int.tryParse(userIdStr);
  }

  // ─────────────────────────────────────────────
  // ✅ APPLY (POST)
  // ─────────────────────────────────────────────
  static Future<String> apply({int? jobId, int? internshipId}) async {
    final userId = await getUserId();
    await AuthService().loadTokens();
    final token = AuthService().accessToken;

    if (token == null) {
      throw Exception("Token is null. Please login again.");
    }

    if (userId == null) {
      return "User not logged in";
    }

    final url = Uri.parse("$baseUrl/applications");

    final body = {
      "user_id": userId,
      if (jobId != null) "job_id": jobId,
      if (internshipId != null) "internship_id": internshipId,
    };

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
        return "Applied successfully";
      } else {
        return data["message"] ?? "Something went wrong";
      }
    } catch (e) {
      return "Error: $e";
    }
  }

  // ─────────────────────────────────────────────
  // ✅ WITHDRAW (DELETE)
  // ─────────────────────────────────────────────
  static Future<String> withdraw({int? jobId, int? internshipId}) async {
    final userId = await getUserId();
    await AuthService().loadTokens();
    final token = AuthService().accessToken;

    if (token == null) {
      throw Exception("Token is null. Please login again.");
    }

    if (userId == null) {
      return "User not logged in";
    }

    final url = Uri.parse("$baseUrl/applications");

    final body = {
      "user_id": userId,
      if (jobId != null) "job_id": jobId,
      if (internshipId != null) "internship_id": internshipId,
    };

    try {
      final response = await http.delete(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return "Application withdrawn";
      } else {
        return data["message"] ?? "Something went wrong";
      }
    } catch (e) {
      return "Error: $e";
    }
  }

  // ─────────────────────────────────────────────
  // ✅ GET APPLICATIONS (JOB + INTERNSHIP TITLES)
  // ─────────────────────────────────────────────
  static Future<Map<String, dynamic>?> getApplications() async {
    final userId = await getUserId();
    await AuthService().loadTokens();
    final token = AuthService().accessToken;

    if (token == null) {
      throw Exception("Token is null. Please login again.");
    }

    if (userId == null) return null;

    final url = Uri.parse("$baseUrl/applications?user_id=$userId");

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
        return data;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  // ─────────────────────────────────────────────
  // ✅ EXTRACT JOB IDS
  // ─────────────────────────────────────────────
  static List<int> extractJobIds(List data) {
    return data
        .where((e) => e["job_id"] != null)
        .map<int>((e) => e["job_id"] as int)
        .toList();
  }

  // ─────────────────────────────────────────────
  // ✅ EXTRACT INTERNSHIP IDS
  // ─────────────────────────────────────────────
  static List<int> extractInternshipIds(List data) {
    return data
        .where((e) => e["internship_id"] != null)
        .map<int>((e) => e["internship_id"] as int)
        .toList();
  }

  // ─────────────────────────────────────────────
  // ✅ CHECK IF JOB APPLIED
  // ─────────────────────────────────────────────
  static bool isJobApplied(List jobs, int jobId) {
    return jobs.any((j) => j["job_id"] == jobId);
  }

  // ─────────────────────────────────────────────
  // ✅ CHECK IF INTERNSHIP APPLIED
  // ─────────────────────────────────────────────
  static bool isInternshipApplied(List internships, int internshipId) {
    return internships.any((i) => i["internship_id"] == internshipId);
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
