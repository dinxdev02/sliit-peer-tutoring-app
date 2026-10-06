class UserModel {
  final String id;
  final String name;
  final String email;
  final String role; // 'tutee' or 'tutor'
  final String year;
  final String program;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.year,
    required this.program,
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'email': email,
        'role': role,
        'year': year,
        'program': program,
      };

  factory UserModel.fromMap(String id, Map<String, dynamic> map) {
    return UserModel(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'tutee',
      year: map['year'] ?? '',
      program: map['program'] ?? '',
    );
  }
}
