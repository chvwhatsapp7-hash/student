// ─────────────────────────────────────────────
//  notification_model.dart
//  Drop this in your models/ folder.
//  Fully backward-compatible — all new fields
//  are optional so existing callsites still work.
// ─────────────────────────────────────────────

class AppNotification {
  final String?  id;
  final String   title;
  final String   body;
  final DateTime time;
  final bool     isRead;

  /// Backend 'type' field — e.g. 'course', 'job', 'internship',
  /// 'company', 'hackathon', 'achievement', 'application',
  /// 'enrollment', 'saved', 'general'
  final String? type;

  /// Backend 'category' field — 'public' | 'personal'
  final String? category;

  /// Backend 'redirect_to' field — e.g. 'jobs', 'courses', etc.
  final String? redirectTo;

  const AppNotification({
    this.id,
    required this.title,
    required this.body,
    required this.time,
    this.isRead    = false,
    this.type,
    this.category,
    this.redirectTo,
  });

  /// Convenience factory from backend JSON map.
  factory AppNotification.fromJson(Map<String, dynamic> f) {
    final id     = f['notification_id']?.toString();
    final isRead = f['is_read'] == 1 || f['is_read'] == true;
    return AppNotification(
      id:         id,
      title:      f['title']?.toString()       ?? 'Notification',
      body:       f['message']?.toString()     ?? '',
      time:       DateTime.tryParse(f['created_at']?.toString() ?? '') ?? DateTime.now(),
      isRead:     isRead,
      type:       f['type']?.toString(),
      category:   f['category']?.toString(),
      redirectTo: f['redirect_to']?.toString(),
    );
  }

  AppNotification copyWith({
    String?  id,
    String?  title,
    String?  body,
    DateTime? time,
    bool?    isRead,
    String?  type,
    String?  category,
    String?  redirectTo,
  }) {
    return AppNotification(
      id:         id         ?? this.id,
      title:      title      ?? this.title,
      body:       body       ?? this.body,
      time:       time       ?? this.time,
      isRead:     isRead     ?? this.isRead,
      type:       type       ?? this.type,
      category:   category   ?? this.category,
      redirectTo: redirectTo ?? this.redirectTo,
    );
  }
}
