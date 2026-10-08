import 'package:cloud_firestore/cloud_firestore.dart';

DateTime recordDate(dynamic value) => value is Timestamp
    ? value.toDate()
    : value is String
        ? DateTime.parse(value)
        : DateTime.fromMillisecondsSinceEpoch(0);

class PeerTutor {
  final String id, name, year, program, bio;
  final List<String> modules;
  final bool verified;
  PeerTutor(this.id, Map<String, dynamic> data)
      : name = data['name'] ?? '',
        year = data['year'] ?? '',
        program = data['program'] ?? '',
        bio = data['bio'] ?? '',
        modules = List<String>.from(data['subjects'] ?? []),
        verified = data['verified'] == true;
}

class PeerSlot {
  final String id, tutorId, mode, venue;
  final DateTime start, end;
  final bool available;
  final String? bookingId;
  PeerSlot(this.id, Map<String, dynamic> data)
      : tutorId = data['tutorId'],
        start = recordDate(data['start']),
        end = recordDate(data['end']),
        mode = data['mode'],
        venue = data['venue'],
        available = data['available'] == true,
        bookingId = data['bookingId'];
}

class PeerBooking {
  final String id,
      tutorId,
      tuteeId,
      tutorName,
      tuteeName,
      module,
      slotId,
      status,
      mode,
      venue,
      notes;
  final DateTime start, end;
  final String? teamsUrl;
  PeerBooking(this.id, Map<String, dynamic> data)
      : tutorId = data['tutorId'],
        tuteeId = data['tuteeId'],
        tutorName = data['tutorName'],
        tuteeName = data['tuteeName'],
        module = data['module'],
        slotId = data['slotId'],
        status = data['status'],
        mode = data['mode'],
        venue = data['venue'],
        notes = data['notes'] ?? '',
        teamsUrl = data['teamsUrl'],
        start = recordDate(data['start']),
        end = recordDate(data['end']);
  bool get active => status == 'pending' || status == 'confirmed';
}

class PeerReview {
  final String id, tutorId, tuteeId, author, comment;
  final double rating;
  final List<String> tags;
  PeerReview(this.id, Map<String, dynamic> data)
      : tutorId = data['tutorId'],
        tuteeId = data['tuteeId'],
        author = data['author'],
        comment = data['comment'] ?? '',
        rating = (data['rating'] as num).toDouble(),
        tags = List<String>.from(data['tags'] ?? []);
}

const peerModules = <String, String>{
  'IT1010': 'Programming Fundamentals',
  'IT2050': 'Data Structures & Algorithms',
  'IT3060': 'Human Computer Interaction',
  'IT2080': 'Database Management Systems',
  'IT3040': 'Computer Networks',
  'IT2030': 'Object Oriented Programming',
};
String moduleLabel(String code) => '$code ${peerModules[code] ?? ''}'.trim();
