import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/peer_records.dart';

/// Live session state. Every record comes from Firestore; no sample users or bookings.
class AppData extends ChangeNotifier {
  static final instance = AppData();
  FirebaseAuth? auth;
  FirebaseFirestore? db;
  StreamSubscription<void>? _authSubscription;
  final List<StreamSubscription<dynamic>> _streams = [];
  String? error;
  bool loading = false, initialized = false;
  Map<String, dynamic>? profile;
  List<PeerTutor> tutors = [];
  PeerTutor? ownTutor;
  List<PeerSlot> slots = [];
  List<PeerBooking> bookings = [];
  List<PeerReview> reviews = [];
  List<Map<String, dynamic>> notifications = [], chats = [], reports = [];
  Set<String> favorites = {};
  Map<String, String> favoriteNotes = {};
  String get uid => auth?.currentUser?.uid ?? '';
  String get name =>
      profile?['name'] ?? auth?.currentUser?.displayName ?? 'Student';
  bool get isTutor => profile?['role'] == 'tutor';
  bool get verified => profile?['verificationStatus'] == 'approved';
  bool get signedIn => auth?.currentUser != null;

  Future<void> initialize() async {
    auth = FirebaseAuth.instance;
    db = FirebaseFirestore.instance;
    initialized = true;
    await _authSubscription?.cancel();
    _authSubscription = auth!
        .authStateChanges()
        .asyncMap(_bind)
        .listen((_) {}, onError: _onError);
  }

  void _onError(Object failure) {
    error = failure is FirebaseException
        ? failure.message ?? failure.code
        : failure.toString();
    loading = false;
    notifyListeners();
  }

  Future<void> _bind(User? user) async {
    for (final stream in _streams) {
      await stream.cancel();
    }
    _streams.clear();
    profile = null;
    tutors = [];
    ownTutor = null;
    slots = [];
    bookings = [];
    reviews = [];
    notifications = [];
    chats = [];
    reports = [];
    favorites = {};
    favoriteNotes = {};
    error = null;
    loading = user != null;
    notifyListeners();
    if (user == null) return;
    final database = db!;
    final pending = <String>{
      'profile',
      'ownTutor',
      'tutors',
      'slots',
      'bookings',
      'reviews',
      'favorites',
      'notifications',
      'chats',
      'reports'
    };
    void ready(String key) {
      pending.remove(key);
      loading = pending.isNotEmpty && error == null;
      notifyListeners();
    }

    _streams.add(
        database.collection('users').doc(user.uid).snapshots().listen((doc) {
      profile = doc.data();
      ready('profile');
    }, onError: _onError));
    _streams.add(database
        .collection('tutorProfiles')
        .doc(user.uid)
        .snapshots()
        .listen((doc) {
      ownTutor = doc.exists ? PeerTutor(doc.id, doc.data()!) : null;
      ready('ownTutor');
    }, onError: _onError));
    void watch(String collection, Query<Map<String, dynamic>> query,
        void Function(QuerySnapshot<Map<String, dynamic>>) assign) {
      _streams.add(query.snapshots().listen((snapshot) {
        assign(snapshot);
        ready(collection);
      }, onError: _onError));
    }

    watch(
        'tutors',
        database.collection('tutorProfiles').where('verified', isEqualTo: true),
        (s) => tutors = s.docs.map((d) => PeerTutor(d.id, d.data())).toList());
    watch(
        'slots',
        database.collection('availability').where('available', isEqualTo: true),
        (s) => slots = s.docs.map((d) => PeerSlot(d.id, d.data())).toList());
    watch(
        'bookings',
        database
            .collection('bookings')
            .where('participants', arrayContains: user.uid), (s) {
      bookings = s.docs.map((d) => PeerBooking(d.id, d.data())).toList()
        ..sort((a, b) => a.start.compareTo(b.start));
    });
    watch(
        'reviews',
        database.collection('reviews'),
        (s) =>
            reviews = s.docs.map((d) => PeerReview(d.id, d.data())).toList());
    watch('favorites',
        database.collection('users').doc(user.uid).collection('favorites'),
        (s) {
      favorites = s.docs.map((d) => d.id).toSet();
      favoriteNotes = {
        for (final doc in s.docs) doc.id: doc.data()['note'] as String? ?? ''
      };
    });
    watch(
        'notifications',
        database
            .collection('notifications')
            .where('userId', isEqualTo: user.uid), (s) {
      notifications = s.docs.map((d) => {'id': d.id, ...d.data()}).toList()
        ..sort((a, b) =>
            recordDate(b['createdAt']).compareTo(recordDate(a['createdAt'])));
    });
    watch(
        'chats',
        database.collection('chats').where('members', arrayContains: user.uid),
        (s) => chats = s.docs.map((d) => {'id': d.id, ...d.data()}).toList());
    watch(
        'reports',
        database.collection('reports').where('reporterId', isEqualTo: user.uid),
        (s) => reports = s.docs.map((d) => {'id': d.id, ...d.data()}).toList());
  }

  PeerTutor? tutor(String id) {
    if (ownTutor?.id == id) return ownTutor;
    for (final tutor in tutors) {
      if (tutor.id == id) return tutor;
    }
    return null;
  }

  PeerBooking? booking(String id) {
    for (final booking in bookings) {
      if (booking.id == id) return booking;
    }
    return null;
  }

  List<PeerSlot> openSlots(String tutorId) => slots
      .where((s) =>
          s.tutorId == tutorId &&
          s.bookingId == null &&
          s.start.isAfter(DateTime.now()))
      .toList()
    ..sort((a, b) => a.start.compareTo(b.start));
  double rating(String tutorId) {
    final values = reviews.where((r) => r.tutorId == tutorId).toList();
    return values.isEmpty
        ? 0
        : values.fold<double>(0, (total, r) => total + r.rating) /
            values.length;
  }

  Future<void> toggleFavorite(String id) async {
    final ref =
        db!.collection('users').doc(uid).collection('favorites').doc(id);
    if (favorites.contains(id)) {
      await ref.delete();
    } else {
      await ref.set({'tutorId': id, 'createdAt': FieldValue.serverTimestamp()});
    }
  }

  Future<void> acknowledgeGuidelines() =>
      db!.collection('users').doc(uid).update({'guidelinesAccepted': true});
  Future<void> updateFavoriteNote(String tutorId, String note) async {
    if (note.trim().length > 300) {
      throw StateError('Keep your saved tutor note within 300 characters.');
    }
    await db!
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .doc(tutorId)
        .update({'note': note.trim()});
  }

  Future<void> deleteTutorProfile() async {
    final batch = db!.batch();
    batch.delete(db!.collection('tutorProfiles').doc(uid));
    batch.update(db!.collection('users').doc(uid), {'role': 'tutee'});
    await batch.commit();
  }

  Future<void> saveProfile(Map<String, dynamic> fields) async {
    final batch = db!.batch();
    batch.update(db!.collection('users').doc(uid), fields);
    final tutor = await db!.collection('tutorProfiles').doc(uid).get();
    if (tutor.exists) {
      batch.update(tutor.reference, fields);
    }
    await batch.commit();
  }

  Future<void> saveTutor(
      {required List<String> modules,
      required String bio,
      required String year,
      required String program}) async {
    if (modules.isEmpty || bio.trim().isEmpty) {
      throw StateError('Choose a module and add your tutor introduction.');
    }
    final batch = db!.batch();
    batch.update(db!.collection('users').doc(uid),
        {'role': 'tutor', 'year': year, 'program': program});
    batch.set(
        db!.collection('tutorProfiles').doc(uid),
        {
          'userId': uid,
          'name': name,
          'year': year,
          'program': program,
          'subjects': modules,
          'bio': bio.trim(),
          'verified': verified
        },
        SetOptions(merge: true));
    await batch.commit();
  }

  Future<String> createChat(String peerId, String peerName,
      {String? bookingId}) async {
    final members = [uid, peerId]..sort();
    if (uid.isEmpty || peerId.isEmpty || uid == peerId) {
      throw StateError('Choose another peer to message.');
    }
    final id = members.join('_');
    final ref = db!.collection('chats').doc(id);
    await db!.runTransaction((tx) async {
      final doc = await tx.get(ref);
      if (!doc.exists) {
        tx.set(ref, {
          'members': members,
          'names': {uid: name, peerId: peerName},
          'bookingId': bookingId,
          'createdAt': FieldValue.serverTimestamp()
        });
      } else if (bookingId != null && doc.data()?['bookingId'] != bookingId) {
        tx.update(ref, {'bookingId': bookingId});
      }
    });
    return id;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> messages(String chatId) => db!
      .collection('chats')
      .doc(chatId)
      .collection('messages')
      .orderBy('createdAt')
      .snapshots();
  Future<void> sendMessage(String chatId, String text,
      {Map<String, dynamic>? attachment}) async {
    if (text.trim().isEmpty && attachment == null) return;
    if (text.length > 2000) {
      throw StateError('Messages must be at most 2,000 characters.');
    }
    final chatRef = db!.collection('chats').doc(chatId);
    final chat = await chatRef.get();
    final members = List<String>.from(chat.data()!['members']);
    final batch = db!.batch();
    batch.set(chatRef.collection('messages').doc(), {
      'senderId': uid,
      'text': text.trim(),
      'attachment': attachment,
      'createdAt': FieldValue.serverTimestamp()
    });
    for (final recipient in members.where((id) => id != uid)) {
      batch.set(db!.collection('notifications').doc(), {
        'userId': recipient,
        'actorId': uid,
        'type': 'message',
        'chatId': chatId,
        'bookingId': null,
        'message': '$name sent you a message.',
        'read': false,
        'createdAt': FieldValue.serverTimestamp()
      });
    }
    await batch.commit();
  }

  Future<void> markRead({String? id}) async {
    final batch = db!.batch();
    for (final notification
        in notifications.where((n) => id == null || n['id'] == id)) {
      batch.update(db!.collection('notifications').doc(notification['id']),
          {'read': true});
    }
    await batch.commit();
  }

  Future<void> deleteNotification(String id) =>
      db!.collection('notifications').doc(id).delete();
  Future<void> signOut() async {
    await auth!.signOut();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    for (final s in _streams) {
      s.cancel();
    }
    super.dispose();
  }
}
