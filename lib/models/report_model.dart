class ReportModel {
  final String id;
  final String reporterId;
  final String? bookingId;
  final String reason;
  final String details;
  final DateTime createdAt;

  ReportModel({
    required this.id,
    required this.reporterId,
    this.bookingId,
    required this.reason,
    required this.details,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'reporterId': reporterId,
        'bookingId': bookingId,
        'reason': reason,
        'details': details,
        'createdAt': createdAt.toIso8601String(),
      };

  factory ReportModel.fromMap(String id, Map<String, dynamic> map) {
    return ReportModel(
      id: id,
      reporterId: map['reporterId'] ?? '',
      bookingId: map['bookingId'],
      reason: map['reason'] ?? '',
      details: map['details'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
