import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/peer_records.dart';
import 'app_data.dart';

class BookingRepository {
  final AppData data;
  BookingRepository(this.data);
  FirebaseFirestore get db => data.db!;
  Future<String> request(
      PeerTutor tutor, PeerSlot slot, String module, String notes) async {
    if (data.uid == tutor.id || !tutor.modules.contains(module)) {
      throw StateError('Choose a valid tutor and module.');
    }
    final booking = db.collection('bookings').doc();
    final slotRef = db.collection('availability').doc(slot.id);
    await db.runTransaction((tx) async {
      final tutorDoc =
          await tx.get(db.collection('tutorProfiles').doc(tutor.id));
      final current = await tx.get(slotRef);
      if (tutorDoc.data()?['verified'] != true || !current.exists) {
        throw StateError('This tutor or slot is no longer available.');
      }
      final live = PeerSlot(current.id, current.data()!);
      if (live.tutorId != tutor.id ||
          !live.available ||
          live.bookingId != null ||
          !live.start.isAfter(DateTime.now())) {
        throw StateError(
            'This slot has already been reserved. Choose another time.');
      }
      tx.set(booking, {
        'tutorId': tutor.id,
        'tuteeId': data.uid,
        'participants': [tutor.id, data.uid],
        'tutorName': tutor.name,
        'tuteeName': data.name,
        'module': module,
        'slotId': live.id,
        'start': Timestamp.fromDate(live.start),
        'end': Timestamp.fromDate(live.end),
        'mode': live.mode,
        'venue': live.venue,
        'notes': notes.trim(),
        'teamsUrl': null,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp()
      });
      tx.update(slotRef, {'bookingId': booking.id});
      _notify(tx, booking.id, [tutor.id, data.uid],
          'A study session for $module was requested.');
    });
    return booking.id;
  }

  Future<void> transition(PeerBooking booking, String status,
      {String? teamsUrl}) async {
    final ref = db.collection('bookings').doc(booking.id);
    final slotRef = db.collection('availability').doc(booking.slotId);
    await db.runTransaction((tx) async {
      final snapshot = await tx.get(ref);
      final slot = await tx.get(slotRef);
      final current = PeerBooking(snapshot.id, snapshot.data()!);
      final tutor = current.tutorId == data.uid;
      final valid = status == 'cancelled' && current.active ||
          tutor &&
              current.status == 'pending' &&
              ['confirmed', 'declined'].contains(status) ||
          tutor &&
              current.status == 'confirmed' &&
              status == 'completed' &&
              !current.end.isAfter(DateTime.now());
      if (!valid || ![current.tutorId, current.tuteeId].contains(data.uid)) {
        throw StateError('This booking can no longer be changed that way.');
      }
      tx.update(ref, {
        'status': status,
        if (teamsUrl != null) 'teamsUrl': teamsUrl,
        'updatedAt': FieldValue.serverTimestamp()
      });
      if (['cancelled', 'declined', 'completed'].contains(status) &&
          slot.data()?['bookingId'] == booking.id) {
        tx.update(slotRef, {'bookingId': null});
      }
      _notify(tx, booking.id, [current.tutorId, current.tuteeId],
          'Study session for ${current.module}: $status.');
    });
  }

  Future<void> reschedule(PeerBooking booking, PeerSlot next) async {
    final ref = db.collection('bookings').doc(booking.id);
    final old = db.collection('availability').doc(booking.slotId);
    final fresh = db.collection('availability').doc(next.id);
    if (old.id == fresh.id) {
      throw StateError('Select a different available slot.');
    }
    await db.runTransaction((tx) async {
      final doc = await tx.get(ref);
      final previous = await tx.get(old);
      final target = await tx.get(fresh);
      final current = PeerBooking(doc.id, doc.data()!);
      final slot = PeerSlot(target.id, target.data()!);
      if (current.tuteeId != data.uid ||
          !current.active ||
          slot.tutorId != current.tutorId ||
          slot.bookingId != null ||
          !slot.available ||
          !slot.start.isAfter(DateTime.now())) {
        throw StateError('The requested replacement slot is unavailable.');
      }
      if (previous.data()?['bookingId'] == booking.id) {
        tx.update(old, {'bookingId': null});
      }
      tx.update(fresh, {'bookingId': booking.id});
      tx.update(ref, {
        'slotId': slot.id,
        'start': Timestamp.fromDate(slot.start),
        'end': Timestamp.fromDate(slot.end),
        'mode': slot.mode,
        'venue': slot.venue,
        'status': 'pending',
        'teamsUrl': null,
        'updatedAt': FieldValue.serverTimestamp()
      });
      _notify(tx, booking.id, [current.tutorId, current.tuteeId],
          'Reschedule requested for ${current.module}; tutor acceptance is needed.');
    });
  }

  void _notify(Transaction tx, String bookingId, List<String> recipients,
      String message) {
    for (final id in recipients) {
      tx.set(db.collection('notifications').doc(), {
        'userId': id,
        'actorId': data.uid,
        'type': 'booking',
        'bookingId': bookingId,
        'chatId': null,
        'message': message,
        'read': false,
        'createdAt': FieldValue.serverTimestamp()
      });
    }
  }

  Future<void> saveAvailability(
      DateTime week, Set<int> selected, String mode, String venue) async {
    if (!data.isTutor || venue.trim().isEmpty) {
      throw StateError('Complete your tutor profile and study location first.');
    }
    final startOfWeek = DateTime(week.year, week.month, week.day);
    final refs = <DocumentReference<Map<String, dynamic>>>[];
    final records = <Map<String, dynamic>>[];
    const hours = [8, 10, 13, 15, 17];
    for (int r = 0; r < 5; r++) {
      for (int d = 0; d < 7; d++) {
        final day = startOfWeek.add(Duration(days: d));
        final start =
            DateTime(day.year, day.month, day.day, hours[r], r < 2 ? 30 : 0);
        refs.add(db
            .collection('availability')
            .doc('${data.uid}_${start.millisecondsSinceEpoch}'));
        records.add({
          'tutorId': data.uid,
          'start': Timestamp.fromDate(start),
          'end': Timestamp.fromDate(start.add(const Duration(minutes: 90))),
          'mode': mode,
          'venue': venue.trim(),
          'available': true,
          'bookingId': null
        });
      }
    }
    await db.runTransaction((tx) async {
      final snapshots = <DocumentSnapshot<Map<String, dynamic>>>[];
      for (final ref in refs) {
        snapshots.add(await tx.get(ref));
      }
      for (int i = 0; i < refs.length; i++) {
        final row = i ~/ 7, day = i % 7;
        final index = row * 7 + day;
        final start = recordDate(records[i]['start']);
        if (snapshots[i].data()?['bookingId'] != null) {
          if (!selected.contains(index)) {
            throw StateError(
                'A reserved slot cannot be removed. Cancel its booking first.');
          }
          continue;
        }
        if (!start.isAfter(DateTime.now())) continue;
        if (selected.contains(index)) {
          tx.set(refs[i], records[i]);
        } else if (snapshots[i].exists) {
          tx.delete(refs[i]);
        }
      }
    });
  }

  Future<void> saveReview(PeerBooking booking, double rating, String comment,
      Set<String> tags) async {
    if (booking.tuteeId != data.uid ||
        booking.status != 'completed' ||
        rating < 1 ||
        rating > 5 ||
        comment.length > 300) {
      throw StateError('Only the student can review a completed session.');
    }
    final ref = db.collection('reviews').doc(booking.id);
    await db.runTransaction((transaction) async {
      final existing = await transaction.get(ref);
      transaction.set(ref, {
        'bookingId': booking.id,
        'tutorId': booking.tutorId,
        'tuteeId': data.uid,
        'author': data.name,
        'rating': rating,
        'comment': comment.trim(),
        'tags': tags.toList(),
        'createdAt':
            existing.data()?['createdAt'] ?? FieldValue.serverTimestamp()
      });
    });
  }

  Future<void> deleteReview(String bookingId) =>
      db.collection('reviews').doc(bookingId).delete();
  Future<void> report(PeerBooking booking, String reason, String details,
      Map<String, dynamic>? evidence) async {
    if (![booking.tutorId, booking.tuteeId].contains(data.uid) ||
        details.trim().length < 10 ||
        details.length > 500) {
      throw StateError('Add valid details for a session you participated in.');
    }
    await db.collection('reports').add({
      'bookingId': booking.id,
      'reporterId': data.uid,
      'reason': reason,
      'details': details.trim(),
      'evidence': evidence,
      'status': 'submitted',
      'createdAt': FieldValue.serverTimestamp()
    });
  }
}
