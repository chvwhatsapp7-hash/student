class BackendNotification {
  final String id;
  final String type;
  final bool isRead;
  final DateTime createdAt;
  final String? entityId;
  final String? username;

  BackendNotification({
    required this.id,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.entityId,
    this.username,
  });

  factory BackendNotification.fromJson(Map<String, dynamic> json) {
    return BackendNotification(
      id: json['id'],
      type: json['type'],
      isRead: json['isRead'],
      createdAt: DateTime.parse(json['createdAt']),
      entityId: json['entityId'],
      username: json['username'],
    );
  }
}