class NotificationModel {
  final String id;
  final String userId;
  final String type; // 'booking', 'message', 'review', 'reminder'
  final String message;
  final bool read;
  final DateTime timestamp;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.message,
    this.read = false,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'type': type,
        'message': message,
        'read': read,
        'timestamp': timestamp.toIso8601String(),
      };

  factory NotificationModel.fromMap(String id, Map<String, dynamic> map) {
    return NotificationModel(
      id: id,
      userId: map['userId'] ?? '',
      type: map['type'] ?? '',
      message: map['message'] ?? '',
      read: map['read'] ?? false,
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}
