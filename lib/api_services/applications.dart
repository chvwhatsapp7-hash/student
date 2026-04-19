import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'authservice.dart';

class ApplicationsService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  // ─────────────────────────────────────────────
  // GET USER ID FROM STORAGE
  // ─────────────────────────────────────────────
  static Future<int?> getUserId() async {
    final userIdStr = await _storage.read(key: "user_id");
    debugPrint("🔑 getUserId raw value: $userIdStr");
    if (userIdStr == null) return null;
    return int.tryParse(userIdStr);
  }

  // ─────────────────────────────────────────────
  // APPLY (POST)
  // ─────────────────────────────────────────────
  static Future<String> apply({int? jobId, int? internshipId}) async {
    await AuthService().loadTokens(); // ensure token is in memory
    final userId = await getUserId();

    debugPrint("🔑 userId from storage: $userId");
    debugPrint("🔑 accessToken in memory: ${AuthService().accessToken}");

    if (userId == null) return "User not logged in";

    final body = {
      "user_id": userId,
      if (jobId != null) "job_id": jobId,
      if (internshipId != null) "internship_id": internshipId,
    };

    debugPrint("📤 Apply body: $body");

    try {
      final res = await AuthService().post('/applications', body);
      debugPrint("✅ apply response [${res.statusCode}]: ${res.data}");
      if (res.statusCode == 201) return "Applied successfully";
      final data = res.data;
      return (data is Map && data["message"] != null)
          ? data["message"].toString()
          : "Something went wrong";
    } on DioException catch (e) {
      debugPrint("❌ Apply DioException [${e.response?.statusCode}]");
      debugPrint("❌ Apply response body: ${e.response?.data}");
      debugPrint("❌ Apply headers sent: ${e.requestOptions.headers}");
      debugPrint("❌ Apply body sent: ${e.requestOptions.data}");
      final data = e.response?.data;
      if (data is Map && data["message"] != null) {
        return data["message"].toString();
      }
      return "Error ${e.response?.statusCode ?? 'unknown'}: ${data ?? e.message}";
    } catch (e) {
      debugPrint("❌ apply unexpected error: $e");
      return "Error: $e";
    }
  }

  // ─────────────────────────────────────────────
  // WITHDRAW (DELETE)
  // ─────────────────────────────────────────────
  static Future<String> withdraw({int? jobId, int? internshipId}) async {
    await AuthService().loadTokens();
    final userId = await getUserId();

    debugPrint("🔑 withdraw userId: $userId");

    if (userId == null) return "User not logged in";

    final body = {
      "user_id": userId,
      if (jobId != null) "job_id": jobId,
      if (internshipId != null) "internship_id": internshipId,
    };

    debugPrint("📤 Withdraw body: $body");

    try {
      final res = await AuthService().delete('/applications', body);
      debugPrint("✅ withdraw response [${res.statusCode}]: ${res.data}");
      if (res.statusCode == 200) return "Application withdrawn";
      final data = res.data;
      return (data is Map && data["message"] != null)
          ? data["message"].toString()
          : "Something went wrong";
    } on DioException catch (e) {
      debugPrint("❌ Withdraw DioException [${e.response?.statusCode}]");
      debugPrint("❌ Withdraw response body: ${e.response?.data}");
      debugPrint("❌ Withdraw headers sent: ${e.requestOptions.headers}");
      debugPrint("❌ Withdraw body sent: ${e.requestOptions.data}");
      final data = e.response?.data;
      if (data is Map && data["message"] != null) {
        return data["message"].toString();
      }
      return "Error ${e.response?.statusCode ?? 'unknown'}: ${data ?? e.message}";
    } catch (e) {
      debugPrint("❌ withdraw unexpected error: $e");
      return "Error: $e";
    }
  }

  // ─────────────────────────────────────────────
  // GET APPLICATIONS
  // ─────────────────────────────────────────────
  static Future<Map<String, dynamic>?> getApplications() async {
    await AuthService().loadTokens();
    final userId = await getUserId();

    debugPrint("🔑 getApplications userId: $userId");

    if (userId == null) {
      debugPrint("❌ getApplications: userId is null — not logged in");
      return null;
    }

    try {
      final res = await AuthService().get(
        '/applications',
        queryParameters: {'user_id': userId.toString()},
      );
      debugPrint("✅ getApplications [${res.statusCode}]: ${res.data}");
      if (res.statusCode == 200) {
        return res.data is Map<String, dynamic>
            ? res.data as Map<String, dynamic>
            : null;
      }
      debugPrint("❌ getApplications non-200: ${res.statusCode} — ${res.data}");
      return null;
    } on DioException catch (e) {
      debugPrint("❌ getApplications DioException [${e.response?.statusCode}]");
      debugPrint("❌ getApplications response body: ${e.response?.data}");
      return null;
    } catch (e) {
      debugPrint("❌ getApplications unexpected error: $e");
      return null;
    }
  }

  // ─────────────────────────────────────────────
  // EXTRACT JOB IDS
  // ─────────────────────────────────────────────
  static List<int> extractJobIds(List data) {
    return data
        .where((e) => e["job_id"] != null)
        .map<int>((e) => e["job_id"] as int)
        .toList();
  }

  // ─────────────────────────────────────────────
  // EXTRACT INTERNSHIP IDS
  // ─────────────────────────────────────────────
  static List<int> extractInternshipIds(List data) {
    return data
        .where((e) => e["internship_id"] != null)
        .map<int>((e) => e["internship_id"] as int)
        .toList();
  }

  // ─────────────────────────────────────────────
  // CHECK IF JOB APPLIED
  // ─────────────────────────────────────────────
  static bool isJobApplied(List jobs, int jobId) =>
      jobs.any((j) => j["job_id"] == jobId);

  // ─────────────────────────────────────────────
  // CHECK IF INTERNSHIP APPLIED
  // ─────────────────────────────────────────────
  static bool isInternshipApplied(List internships, int internshipId) =>
      internships.any((i) => i["internship_id"] == internshipId);
}
