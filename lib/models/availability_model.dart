class AvailabilityModel {
  final String id;
  final String tutorId;
  final String dayOfWeek; // e.g. "Monday"
  final String timeSlot; // e.g. "14:00-15:00"
  final bool isAvailable;

  AvailabilityModel({
    required this.id,
    required this.tutorId,
    required this.dayOfWeek,
    required this.timeSlot,
    required this.isAvailable,
  });

  Map<String, dynamic> toMap() => {
        'tutorId': tutorId,
        'dayOfWeek': dayOfWeek,
        'timeSlot': timeSlot,
        'isAvailable': isAvailable,
      };

  factory AvailabilityModel.fromMap(String id, Map<String, dynamic> map) {
    return AvailabilityModel(
      id: id,
      tutorId: map['tutorId'] ?? '',
      dayOfWeek: map['dayOfWeek'] ?? '',
      timeSlot: map['timeSlot'] ?? '',
      isAvailable: map['isAvailable'] ?? false,
    );
  }
}
