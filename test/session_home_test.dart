import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sliit_peer_tutoring/services/app_data.dart';
import 'package:sliit_peer_tutoring/services/backend_config.dart';
import 'package:sliit_peer_tutoring/widgets/session_home.dart';
import 'package:sliit_peer_tutoring/models/peer_records.dart';
import 'package:sliit_peer_tutoring/screens/booking/availability_calendar_screen.dart';

class _User extends Fake implements User {
  @override
  String get uid => 'test-user';
  @override
  String get email => 'test@my.sliit.lk';
  @override
  String get displayName => 'Test Student';
}

class _Auth extends Fake implements FirebaseAuth {
  @override
  User get currentUser => _User();
}

void main() {
  setUp(() {
    final data = AppData.instance;
    data.auth = _Auth();
    data.profile = null;
    data.ownTutor = null;
    data.loading = false;
    data.error = null;
    data.slots = [];
  });
  tearDown(() {
    AppData.instance.auth = null;
    AppData.instance.profile = null;
    AppData.instance.ownTutor = null;
    AppData.instance.slots = [];
  });

  testWidgets('Signed-in account without a profile resumes registration',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SessionHome()));
    expect(find.text('Complete Student Profile'), findsOneWidget);
    expect(
        find.text(
            'Confirm your academic details to continue. A student ID upload is not required.'),
        findsOneWidget);
    expect(find.text('Test Student'), findsOneWidget);
    expect(find.text('Join as'), findsOneWidget);
    if (!BackendConfig.uploadsEnabled) {
      expect(find.byIcon(Icons.file_upload_outlined), findsNothing);
      expect(find.text('Optional Document Checklist'), findsNothing);
    }
    expect(tester.takeException(), isNull);
    await tester.scrollUntilVisible(find.byType(CheckboxListTile), 250,
        scrollable: find.byType(Scrollable).first);
    expect(tester.widget<CheckboxListTile>(find.byType(CheckboxListTile)).value, isFalse);
    await tester.tap(find.byType(CheckboxListTile));
    await tester.pump();
    expect(tester.widget<CheckboxListTile>(find.byType(CheckboxListTile)).value, isTrue);
  });

  testWidgets('Tutor without an academic profile resumes tutor setup',
      (tester) async {
    AppData.instance.profile = {
      'role': 'tutor',
      'name': 'Test Tutor',
      'year': 'Year 2',
      'program': 'Information Technology',
      'verificationStatus': 'pending',
    };
    await tester.pumpWidget(const MaterialApp(home: SessionHome()));
    await tester.pump();
    expect(find.text('Set Up Your Peer Tutor Profile'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Save Tutor Profile'), 300,
        scrollable: find
            .descendant(
                of: find.byType(ListView).first,
                matching: find.byType(Scrollable))
            .first);
    expect(find.text('Save Tutor Profile'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Availability restores the saved mode and venue', (tester) async {
    final data = AppData.instance;
    data.profile = {'role':'tutor','name':'Test Tutor','year':'Year 2','program':'Information Technology'};
    final now = DateTime.now();
    final start = DateTime(now.year,now.month,now.day,15);
    data.slots = [PeerSlot('saved-slot', {
      'tutorId':'test-user','start':Timestamp.fromDate(start),
      'end':Timestamp.fromDate(start.add(const Duration(minutes:90))),
      'mode':'Online','venue':'Saved study location','available':true,'bookingId':null,
    })];
    await tester.pumpWidget(const MaterialApp(home: AvailabilityCalendarScreen()));
    final target = find.text('Saved study location');
    await tester.scrollUntilVisible(target,300,
        scrollable: find.descendant(of:find.byType(ListView).first,matching:find.byType(Scrollable)).first);
    expect(target, findsOneWidget);
    expect(find.text('Online'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
