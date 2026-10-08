import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sliit_peer_tutoring/main.dart';
import 'package:sliit_peer_tutoring/services/app_data.dart';
import 'package:sliit_peer_tutoring/models/peer_records.dart';
import 'package:sliit_peer_tutoring/screens/discovery/home_dashboard_screen.dart';
import 'package:sliit_peer_tutoring/screens/booking/availability_calendar_screen.dart';
import 'package:sliit_peer_tutoring/screens/booking/student_schedule_screen.dart';
import 'package:sliit_peer_tutoring/screens/messaging/notifications_screen.dart';

void main() {
  setUp(() {
    final data = AppData.instance;
    data.loading = false;
    data.error = null;
    data.tutors = List.generate(3, (i) => PeerTutor('tutor-$i', {
      'name': 'Tutor $i', 'year': 'Year 3', 'program': 'IT',
      'bio': 'Peer tutor', 'subjects': ['IT3060'], 'verified': true,
    }));
  });
  tearDown(() { AppData.instance.tutors = []; });
  final screens = <String, Widget>{
    'mentor cards': const HomeDashboardScreen(),
    'availability calendar': const AvailabilityCalendarScreen(),
    'booking tabs': const StudentScheduleScreen(),
    'notification tabs': const NotificationsScreen(),
  };
  for (final entry in screens.entries) {
    for (final kind in [PointerDeviceKind.mouse, PointerDeviceKind.touch]) {
      testWidgets('${entry.key} scroll horizontally with ${kind.name}', (tester) async {
        tester.view.physicalSize = const Size(320, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(MaterialApp(
          scrollBehavior: const PeerScrollBehavior(), home: entry.value));
        await tester.pumpAndSettle();
        await tester.scrollUntilVisible(
          find.byWidgetPredicate((widget) => widget is SingleChildScrollView && widget.scrollDirection == Axis.horizontal),
          200, scrollable: find.byWidgetPredicate((widget) => widget is Scrollable && widget.axisDirection == AxisDirection.down).first);
        final horizontal = find.descendant(
          of: find.byWidgetPredicate((widget) => widget is SingleChildScrollView && widget.scrollDirection == Axis.horizontal),
          matching: find.byType(Scrollable)).first;
        expect(horizontal, findsOneWidget);
        await tester.ensureVisible(horizontal);
        await tester.pumpAndSettle();
        final state = tester.state<ScrollableState>(horizontal);
        expect(state.position.maxScrollExtent, greaterThan(0));
        final before = state.position.pixels;
        await tester.drag(horizontal, const Offset(-160, 0), kind: kind);
        await tester.pumpAndSettle();
        expect(state.position.pixels, greaterThan(before));
        if (entry.key == 'availability calendar') {
          final dragged = state.position.pixels;
          await tester.ensureVisible(find.byTooltip('Scroll to later days'));
          await tester.pumpAndSettle();
          await tester.tap(find.byTooltip('Scroll to later days'));
          await tester.pumpAndSettle();
          expect(state.position.pixels, greaterThan(dragged));
          for (int i = 0; i < 4; i++) {
            await tester.tap(find.byTooltip('Scroll to earlier days'));
            await tester.pumpAndSettle();
          }
          expect(state.position.pixels, 0);
        }
        expect(tester.takeException(), isNull);
      });
    }
  }
}
