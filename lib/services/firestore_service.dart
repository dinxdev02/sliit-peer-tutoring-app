import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/tutor_profile_model.dart';
import '../models/favorite_model.dart';
import '../models/availability_model.dart';
import '../models/booking_model.dart';
import '../models/review_model.dart';
import '../models/report_model.dart';
import '../models/message_model.dart';
import '../models/notification_model.dart';

/// Legacy scaffold retained for the group's earlier model files.
/// The live screens use AppData and BookingRepository with firestore.rules.
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ---------- USERS (Rashmika — FR1, FR5) ----------
  Future<void> createUser(UserModel user) =>
      _db.collection('users').doc(user.id).set(user.toMap());

  Future<UserModel?> getUser(String id) async {
    final doc = await _db.collection('users').doc(id).get();
    return doc.exists ? UserModel.fromMap(doc.id, doc.data()!) : null;
  }

  Future<void> updateUser(String id, Map<String, dynamic> data) =>
      _db.collection('users').doc(id).update(data);

  // ---------- TUTOR PROFILES (Rashmika — FR1, FR5) ----------
  Future<void> createTutorProfile(TutorProfileModel profile) =>
      _db.collection('tutorProfiles').doc(profile.id).set(profile.toMap());

  Stream<List<TutorProfileModel>> getAllTutorProfiles() {
    return _db.collection('tutorProfiles').snapshots().map((snap) => snap.docs
        .map((d) => TutorProfileModel.fromMap(d.id, d.data()))
        .toList());
  }

  Future<void> updateTutorProfile(String id, Map<String, dynamic> data) =>
      _db.collection('tutorProfiles').doc(id).update(data);

  Future<void> deleteSubjectFromProfile(String id, String subject) =>
      _db.collection('tutorProfiles').doc(id).update({
        'subjects': FieldValue.arrayRemove([subject])
      });

  // ---------- FAVORITES (Kalhara — Discovery & Search) ----------
  Future<void> addFavorite(FavoriteModel fav) =>
      _db.collection('favorites').doc(fav.id).set(fav.toMap());

  Stream<List<FavoriteModel>> getFavorites(String tuteeId) {
    return _db
        .collection('favorites')
        .where('tuteeId', isEqualTo: tuteeId)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => FavoriteModel.fromMap(d.id, d.data()))
            .toList());
  }

  Future<void> removeFavorite(String favoriteId) =>
      _db.collection('favorites').doc(favoriteId).delete();

  // ---------- AVAILABILITY (Malavipathirana — FR3) ----------
  Future<void> setAvailability(AvailabilityModel slot) =>
      _db.collection('availability').doc(slot.id).set(slot.toMap());

  Stream<List<AvailabilityModel>> getAvailability(String tutorId) {
    return _db
        .collection('availability')
        .where('tutorId', isEqualTo: tutorId)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => AvailabilityModel.fromMap(d.id, d.data()))
            .toList());
  }

  Future<void> deleteAvailabilitySlot(String id) =>
      _db.collection('availability').doc(id).delete();

  // ---------- BOOKINGS (Malavipathirana — FR3, FR8, FR10) ----------
  Future<void> createBooking(BookingModel booking) =>
      _db.collection('bookings').doc(booking.id).set(booking.toMap());

  Stream<List<BookingModel>> getBookingsForUser(String userId,
      {bool asTutor = false}) {
    final field = asTutor ? 'tutorId' : 'tuteeId';
    return _db
        .collection('bookings')
        .where(field, isEqualTo: userId)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => BookingModel.fromMap(d.id, d.data()))
            .toList());
  }

  Future<void> updateBookingStatus(String id, String status) =>
      _db.collection('bookings').doc(id).update({'status': status});

  // ---------- REVIEWS (Sandavinna — FR4) ----------
  Future<void> createReview(ReviewModel review) =>
      _db.collection('reviews').doc(review.id).set(review.toMap());

  Stream<List<ReviewModel>> getReviewsForTutor(String tutorId) {
    return _db
        .collection('reviews')
        .where('tutorId', isEqualTo: tutorId)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => ReviewModel.fromMap(d.id, d.data())).toList());
  }

  Future<void> updateReview(String id, Map<String, dynamic> data) =>
      _db.collection('reviews').doc(id).update(data);

  // ---------- REPORTS (Sandavinna — FR6) ----------
  Future<void> createReport(ReportModel report) =>
      _db.collection('reports').doc(report.id).set(report.toMap());

  // ---------- MESSAGES (Sandavinna — FR4) ----------
  Future<void> sendMessage(MessageModel message) =>
      _db.collection('messages').doc(message.id).set(message.toMap());

  Stream<List<MessageModel>> getMessages(String chatId) {
    return _db
        .collection('messages')
        .where('chatId', isEqualTo: chatId)
        .orderBy('timestamp')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => MessageModel.fromMap(d.id, d.data()))
            .toList());
  }

  Future<void> deleteMessage(String id) =>
      _db.collection('messages').doc(id).delete();

  // ---------- NOTIFICATIONS (shared — FR8) ----------
  Future<void> createNotification(NotificationModel notif) =>
      _db.collection('notifications').doc(notif.id).set(notif.toMap());

  Stream<List<NotificationModel>> getNotifications(String userId) {
    return _db
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => NotificationModel.fromMap(d.id, d.data()))
            .toList());
  }

  Future<void> markNotificationRead(String id) =>
      _db.collection('notifications').doc(id).update({'read': true});
}
