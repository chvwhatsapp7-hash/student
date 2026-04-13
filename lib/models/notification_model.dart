class AppNotification {
  final String? id;       // backend document ID
  final String  title;
  final String  body;
  final DateTime time;
  final bool    isRead;

  const AppNotification({
    this.id,
    required this.title,
    required this.body,
    required this.time,
    this.isRead = false,
  });
}