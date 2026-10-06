class TutorProfileModel {
  final String id;
  final String userId;
  final List<String> subjects; // e.g. ["IT3060", "IT2080"]
  final String bio;
  final bool verified;
  final String? idDocUrl;

  TutorProfileModel({
    required this.id,
    required this.userId,
    required this.subjects,
    required this.bio,
    this.verified = false,
    this.idDocUrl,
  });

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'subjects': subjects,
        'bio': bio,
        'verified': verified,
        'idDocUrl': idDocUrl,
      };

  factory TutorProfileModel.fromMap(String id, Map<String, dynamic> map) {
    return TutorProfileModel(
      id: id,
      userId: map['userId'] ?? '',
      subjects: List<String>.from(map['subjects'] ?? []),
      bio: map['bio'] ?? '',
      verified: map['verified'] ?? false,
      idDocUrl: map['idDocUrl'],
    );
  }

  // FR1, FR5 — matches Milestone 01 traceability
  TutorProfileModel removeSubject(String subject) {
    final updated = List<String>.from(subjects)..remove(subject);
    return TutorProfileModel(
      id: id,
      userId: userId,
      subjects: updated,
      bio: bio,
      verified: verified,
      idDocUrl: idDocUrl,
    );
  }
}
