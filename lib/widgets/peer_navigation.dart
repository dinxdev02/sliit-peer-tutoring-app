import 'package:flutter/material.dart';
import '../screens/discovery/home_dashboard_screen.dart';
import '../screens/discovery/search_discovery_screen.dart';
import '../screens/booking/student_schedule_screen.dart';
import '../screens/booking/tutor_management_dashboard_screen.dart';
import '../screens/booking/availability_calendar_screen.dart';
import '../screens/messaging/messaging_inbox_screen.dart';
import '../screens/onboarding/tutee_profile_screen.dart';
import 'peer_ui.dart';

class PeerNavigation extends StatelessWidget {
  final int index;
  final bool tutor;
  const PeerNavigation({super.key, required this.index, this.tutor = false});
  @override
  Widget build(BuildContext context) => BottomNavigationBar(
          currentIndex: index,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: peerBlue,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          onTap: (i) {
            if (i == index) return;
            final screens = <Widget>[
              const HomeDashboardScreen(),
              tutor
                  ? const TutorManagementDashboardScreen()
                  : const SearchDiscoveryScreen(),
              tutor
                  ? const AvailabilityCalendarScreen()
                  : const StudentScheduleScreen(),
              const MessagingInboxScreen(),
              const TuteeProfileScreen()
            ];
            Navigator.pushReplacement(
                context, MaterialPageRoute<void>(builder: (_) => screens[i]));
          },
          items: [
            const BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined), label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(tutor ? Icons.dashboard_outlined : Icons.search),
                label: tutor ? 'Dashboard' : 'Search'),
            BottomNavigationBarItem(
                icon: const Icon(Icons.calendar_month_outlined),
                label: tutor ? 'Schedule' : 'Bookings'),
            const BottomNavigationBarItem(
                icon: Icon(Icons.chat_bubble_outline), label: 'Messages'),
            const BottomNavigationBarItem(
                icon: Icon(Icons.person_outline), label: 'Profile'),
          ]);
}
