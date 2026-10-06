enum BookingStatus { pending, confirmed, declined, cancelled, completed }

class BookingModel {
  final String id;
  final String tutorId;
  final String tuteeId;
  final String module;
  final DateTime date;
  final String time;
  final BookingStatus status;

  BookingModel({
    required this.id,
    required this.tutorId,
    required this.tuteeId,
    required this.module,
    required this.date,
    required this.time,
    this.status = BookingStatus.pending,
  });

  Map<String, dynamic> toMap() => {
        'tutorId': tutorId,
        'tuteeId': tuteeId,
        'module': module,
        'date': date.toIso8601String(),
        'time': time,
        'status': status.name,
      };

  factory BookingModel.fromMap(String id, Map<String, dynamic> map) {
    return BookingModel(
      id: id,
      tutorId: map['tutorId'] ?? '',
      tuteeId: map['tuteeId'] ?? '',
      module: map['module'] ?? '',
      date: DateTime.parse(map['date']),
      time: map['time'] ?? '',
      status: BookingStatus.values.firstWhere(
        (s) => s.name == map['status'],
        orElse: () => BookingStatus.pending,
      ),
    );
  }
}
