import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sliit_peer_tutoring/screens/discovery/filter_bottom_sheet.dart';
import 'package:sliit_peer_tutoring/screens/booking/availability_calendar_screen.dart';
import 'package:sliit_peer_tutoring/screens/booking/booking_confirmation_screen.dart';
import 'package:sliit_peer_tutoring/screens/booking/booking_details_screen.dart';
import 'package:sliit_peer_tutoring/screens/booking/student_schedule_screen.dart';
import 'package:sliit_peer_tutoring/screens/booking/tutor_management_dashboard_screen.dart';
import 'package:sliit_peer_tutoring/screens/messaging/chat_screen.dart';
import 'package:sliit_peer_tutoring/screens/messaging/notifications_screen.dart';
import 'package:sliit_peer_tutoring/screens/messaging/report_misuse_screen.dart';
import 'package:sliit_peer_tutoring/screens/messaging/review_modal_screen.dart';
import 'package:sliit_peer_tutoring/services/app_data.dart';
import 'package:sliit_peer_tutoring/models/peer_records.dart';

void main() {
  tearDown(() {
    AppData.instance.bookings = [];
    AppData.instance.tutors = [];
    AppData.instance.reviews = [];
  });
  final screens = <String, Widget>{
    'Filters': const Scaffold(body: FilterBottomSheet()),
    'Availability': const AvailabilityCalendarScreen(),
    'Confirmation': const BookingConfirmationScreen(),
    'Booking details': const BookingDetailsScreen(),
    'Student schedule': const StudentScheduleScreen(),
    'Tutor dashboard': const TutorManagementDashboardScreen(),
    'Chat': const ChatScreen(),
    'Notifications': const NotificationsScreen(),
    'Report': const ReportMisuseScreen(),
    'Review': const ReviewModalScreen(),
  };
  for (final width in [320.0, 390.0]) {
    for (final screen in screens.entries) {
      testWidgets('${screen.key} fits a $width pixel phone', (tester) async {
        tester.view.physicalSize = Size(width, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(MaterialApp(home: screen.value));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final lists = find.byType(ListView);
        if (lists.evaluate().isNotEmpty) {
          for (int i = 0; i < 8; i++) {
            await tester.drag(lists.first, const Offset(0, -450));
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
          }
        }
      });
    }
  }

  testWidgets('Filter sheet returns the selected criteria', (tester) async {
    PeerFilters? result;
    await tester.pumpWidget(MaterialApp(
        home: Builder(
            builder: (context) => Scaffold(
                body: TextButton(
                    onPressed: () async {
                      result = await showModalBottomSheet<PeerFilters>(
                          context: context,
                          isScrollControlled: true,
                          builder: (_) => const FilterBottomSheet());
                    },
                    child: const Text('Open'))))));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reset All'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Apply Filters'));
    await tester.pumpAndSettle();
    expect(result!.modules, isEmpty);
    expect(result!.rating, 0);
    expect(result!.immediate, false);
  });

  testWidgets(
      'Confirmation displays the stored request, tutor and pending state',
      (tester) async {
    AppData.instance.bookings = [
      PeerBooking('stored-request', {
        'tutorId': 'real-tutor',
        'tuteeId': 'student',
        'tutorName': 'Stored Tutor Name',
        'tuteeName': 'Stored Student',
        'module': 'IT3060',
        'slotId': 'stored-slot',
        'status': 'pending',
        'mode': 'Campus',
        'venue': 'Stored Library Room',
        'notes': '',
        'start': DateTime.now().add(const Duration(days: 1)).toIso8601String(),
        'end': DateTime.now()
            .add(const Duration(days: 1, hours: 1))
            .toIso8601String(),
      })
    ];
    await tester.pumpWidget(const MaterialApp(
        home: BookingConfirmationScreen(bookingId: 'stored-request')));
    await tester.pumpAndSettle();
    expect(find.text('Stored Tutor Name'), findsOneWidget);
    expect(find.text('Stored Library Room'), findsOneWidget);
    expect(find.text('PENDING'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('A pending session cannot display a review form', (tester) async {
    AppData.instance.bookings = [
      PeerBooking('pending-review', {
        'tutorId': 'tutor',
        'tuteeId': '',
        'tutorName': 'Tutor',
        'tuteeName': 'Student',
        'module': 'IT3060',
        'slotId': 'slot',
        'status': 'pending',
        'mode': 'Campus',
        'venue': 'Library',
        'notes': '',
        'start': DateTime.now().toIso8601String(),
        'end': DateTime.now().toIso8601String(),
      })
    ];
    await tester.pumpWidget(const MaterialApp(
        home: ReviewModalScreen(bookingId: 'pending-review')));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsNothing);
    expect(find.textContaining('completed'), findsWidgets);
  });
}
