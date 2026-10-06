class FavoriteModel {
  final String id;
  final String tuteeId;
  final String tutorId;
  final DateTime savedAt;

  FavoriteModel({
    required this.id,
    required this.tuteeId,
    required this.tutorId,
    required this.savedAt,
  });

  Map<String, dynamic> toMap() => {
        'tuteeId': tuteeId,
        'tutorId': tutorId,
        'savedAt': savedAt.toIso8601String(),
      };

  factory FavoriteModel.fromMap(String id, Map<String, dynamic> map) {
    return FavoriteModel(
      id: id,
      tuteeId: map['tuteeId'] ?? '',
      tutorId: map['tutorId'] ?? '',
      savedAt: DateTime.parse(map['savedAt']),
    );
  }
}
