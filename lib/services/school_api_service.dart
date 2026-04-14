import 'package:flutter/material.dart';

import '../api_services/authservice.dart';
import '../screens/school/school_data.dart';
import './fcm_token_service.dart';

class SchoolApiService {
  static final SchoolApiService instance = SchoolApiService._();
  SchoolApiService._();

  final AuthService _auth = AuthService();

  // Color & Emoji helpers for courses mapping
  static const _emojis = ['🚀', '💻', '🤖', '🎮', '📱', '🎨', '🧠'];
  static const _bgColors = [
    Color(0xFFFFF3E0),
    Color(0xFFE3F2FD),
    Color(0xFFF3E5F5),
    Color(0xFFE8F5E9),
    Color(0xFFFCE4EC),
    Color(0xFFE0F7FA),
  ];

  Future<bool> login(String email, String password) async {
    try {
      final res = await _auth.post('/auth/login', {
        'email': email,
        'password': password,
      });
      if (res.statusCode == 200) {
        final data = res.data;
        await _auth.saveTokens(
          access: data['accessToken'],
          refresh: data['refreshToken'],
          user_id: data['user_id']?.toString(),
        );

        // Sync FCM token
        await FcmTokenService.sendTokenToBackend(data['accessToken']);
        FcmTokenService.listenToTokenRefresh(data['accessToken']);

        return true;
      }
    } catch (e) {
      debugPrint('Login Error: $e');
    }
    return false;
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
    required String phone,
    required String schoolName, // mapped to university
    required String grade, // mapped to degree
  }) async {
    try {
      final res = await _auth.post('/auth/register', {
        'full_name': fullName,
        'email': email,
        'password': password,
        'phone': phone,
        'university': schoolName,
        'degree': grade,
      });
      if (res.statusCode == 201 || res.statusCode == 200) {
        return true;
      }
    } catch (e) {
      debugPrint('Register Error: $e');
    }
    return false;
  }

  Future<List<Course>> getCourses() async {
    try {
      final res = await _auth.get(
        '/getCourses',
        queryParameters: {'target_group': 'school'},
      );
      if (res.statusCode == 200) {
        final List data = res.data is List
            ? res.data
            : (res.data['data'] ?? res.data['courses'] ?? []);
        return data.asMap().entries.map((e) {
          final index = e.key;
          final item = e.value as Map<String, dynamic>;

          final randomEmoji = _emojis[index % _emojis.length];
          final randomBg = _bgColors[index % _bgColors.length];

          return Course(
            id: int.tryParse(item['course_id'].toString()) ?? index,
            emoji: randomEmoji,
            title: item['title'] ?? 'Unknown Course',
            desc: item['description'] ?? '',
            fullDescription:
                item['description'] ?? 'No long description provided.',
            duration: item['duration'] ?? '4 weeks',
            rating: item['rating']?.toString() ?? '4.5',
            students: '100+',
            age: '8-17',
            level: item['level'] ?? 'Beginner',
            price: item['price'] != null ? '₹${item['price']}' : 'Free',
            bgColor: randomBg,
            tag: 'New',
            tagBg: randomBg,
            tagColor:
                kPrimaryBlue, // Using from school_data.dart or define fallback
            instructor: Instructor(
              name: item['provider'] ?? 'Expert Instructor',
              role: 'Educator',
              avatar: '🧑‍🏫',
              experience: '5+ years',
            ),
            technologies:
                (item['skills'] as List?)?.map((s) => s.toString()).toList() ??
                ['Coding'],
            outcomes: [
              'Gain hands-on experience',
              'Build interactive projects',
            ],
            schedule: 'Flexible',
            totalLessons: '10 lessons',
            certificate: 'Yes!',
          );
        }).toList();
      }
    } catch (e) {
      debugPrint('Get Courses Error: $e');
    }
    // Fallback to dummy data if API fails to keep UI nice while disconnected
    return kCourses;
  }

  Future<Map<String, dynamic>?> getProfile() async {
    try {
      final uid = _auth.userId;
      if (uid == null) return null;

      final res = await _auth.get('/profile/$uid');
      if (res.statusCode == 200) {
        return res.data;
      }
    } catch (e) {
      debugPrint('Get Profile Error: $e');
    }
    return null;
  }

  Future<List<dynamic>> getNotifications() async {
    try {
      final res = await _auth.get('/notifications');
      if (res.statusCode == 200) {
        return res.data is List ? res.data as List : (res.data['data'] ?? []);
      }
    } catch (e) {
      debugPrint('Get Notifications Error: $e');
    }
    return [];
  }

  Future<bool> markNotificationRead(String id) async {
    try {
      final res = await _auth.put('/notifications', {'notification_id': id});
      return res.statusCode == 200;
    } catch (e) {
      debugPrint('Mark Notif Read Error: $e');
    }
    return false;
  }

  Future<bool> markAllNotificationsRead() async {
    try {
      final res = await _auth.put('/notifications/read-all', {});
      return res.statusCode == 200;
    } catch (e) {
      debugPrint('Mark All Read Error: $e');
    }
    return false;
  }

  Future<void> updateProfile(String name, String grade, String school) async {
    try {
      final uid = _auth.userId;
      if (uid == null) return;
      await _auth.put('/profile/$uid', {
        'full_name': name,
        'degree': grade,
        'university': school,
      });
    } catch (e) {
      debugPrint('Update Profile Error: $e');
    }
  }
}
