class PostComment {
  final int id;
  final String userId;
  final String authorName;
  final String authorEmail;
  final String content;
  final DateTime createdAt;

  PostComment({
    required this.id,
    required this.userId,
    required this.authorName,
    required this.authorEmail,
    required this.content,
    required this.createdAt,
  });

  factory PostComment.fromJson(Map<String, dynamic> json) {
    DateTime parsedDate;
    try {
      parsedDate = json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now();
    } catch (_) {
      parsedDate = DateTime.now();
    }

    return PostComment(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      userId: json['user_id']?.toString() ?? '',
      authorName: json['author_name'] ?? json['full_name'] ?? 'StudentHub Member',
      authorEmail: json['author_email'] ?? json['email'] ?? '',
      content: json['content'] ?? '',
      createdAt: parsedDate,
    );
  }

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()}mo ago';
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }
}
