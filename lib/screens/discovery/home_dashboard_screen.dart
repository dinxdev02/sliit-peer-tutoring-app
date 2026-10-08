import 'package:flutter/material.dart';
import '../../models/peer_records.dart';
import '../../widgets/brand_widgets.dart';
import '../../widgets/peer_ui.dart';
import '../../widgets/peer_navigation.dart';
import '../../widgets/data_widgets.dart';
import '../onboarding/login_screen.dart';
import '../onboarding/tutee_profile_screen.dart';
import '../booking/tutor_management_dashboard_screen.dart';
import '../booking/student_schedule_screen.dart';
import '../messaging/notifications_screen.dart';
import 'search_discovery_screen.dart';
import 'tutor_profile_detail_screen.dart';

class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({super.key});
  @override
  Widget build(BuildContext context) => DataView(
      builder: (context, data) => PeerPage(
              title: 'SLIIT Peer • Home',
              bottom: const PeerNavigation(index: 0),
              actions: [
                IconButton(
                    tooltip: 'Notifications',
                    onPressed: () =>
                        openPeerScreen(context, const NotificationsScreen()),
                    icon: Badge(
                        isLabelVisible:
                            data.notifications.any((n) => n['read'] != true),
                        child: const Icon(Icons.notifications_none))),
                IconButton(
                    tooltip: 'Profile',
                    onPressed: () =>
                        openPeerScreen(context, const TuteeProfileScreen()),
                    icon: const Icon(Icons.account_circle_outlined))
              ],
              children: [
                Text('Ayubowan, ${data.name}! 🙏',
                    style: const TextStyle(
                        fontSize: 27, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                const Text('Find a peer tutor for your SLIIT coursework today'),
                const SizedBox(height: 20),
                TextField(
                    onSubmitted: (q) => openPeerScreen(
                        context, SearchDiscoveryScreen(initialQuery: q)),
                    decoration: InputDecoration(
                        hintText: 'Search module code, topic or tutor…',
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: IconButton(
                            tooltip: 'Search tutors',
                            onPressed: () => openPeerScreen(
                                context, const SearchDiscoveryScreen()),
                            icon: const Icon(Icons.tune)),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                                color: AppColors.borderLight)))),
                const SizedBox(height: 16),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  const PeerBadge('100% Free Volunteer Support'),
                  PeerBadge('${peerModules.length} Modules'),
                  PeerBadge('${data.tutors.length} Verified Tutors')
                ]),
                const SizedBox(height: 24),
                Row(children: [
                  const Expanded(child: PeerTitle('Available Peer Mentors')),
                  TextButton(
                      onPressed: () => openPeerScreen(
                          context, const SearchDiscoveryScreen()),
                      child: const Text('See all ›'))
                ]),
                if (data.tutors.isEmpty)
                  const PeerCard(children: [
                    Text(
                        'No verified tutors are available yet. Approved tutor profiles will appear here.')
                  ]),
                if (data.tutors.isNotEmpty)
                  SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(children: [
                        for (final tutor
                            in data.tutors.where((t) => t.id != data.uid))
                          SizedBox(
                              width: 265,
                              child: Padding(
                                  padding: const EdgeInsets.only(right: 12),
                                  child: PeerCard(children: [
                                    PeerPerson(
                                        name: tutor.name,
                                        subtitle:
                                            '${tutor.year} • ${tutor.program}'),
                                    Text(data.rating(tutor.id) == 0
                                        ? 'New Peer Mentor'
                                        : '★ ${data.rating(tutor.id).toStringAsFixed(1)}'),
                                    const SizedBox(height: 10),
                                    Wrap(
                                        spacing: 4,
                                        runSpacing: 4,
                                        children: tutor.modules
                                            .take(2)
                                            .map((m) => PeerBadge(m))
                                            .toList()),
                                    Text(
                                        '${data.openSlots(tutor.id).length} open slots',
                                        style: const TextStyle(
                                            color: AppColors.textMuted)),
                                    PeerButton('Connect Free',
                                        onPressed: () => openPeerScreen(
                                            context,
                                            TutorProfileDetailScreen(
                                                tutorId: tutor.id)))
                                  ]))),
                      ])),
                PeerCard(color: peerTint, children: [
                  const PeerTitle('Your Peer Study Schedule',
                      icon: Icons.event),
                  Text(
                      '${data.bookings.where((b) => b.active).length} active study sessions'),
                  PeerButton('View My Bookings',
                      secondary: true,
                      onPressed: () => openPeerScreen(
                          context, const StudentScheduleScreen()))
                ]),
                const PeerTitle('SLIIT Coursework Modules'),
                Wrap(spacing: 10, runSpacing: 10, children: [
                  for (final entry in peerModules.entries)
                    SizedBox(
                        width: (MediaQuery.sizeOf(context).width - 42) / 2,
                        child: InkWell(
                            onTap: () => openPeerScreen(context,
                                SearchDiscoveryScreen(initialQuery: entry.key)),
                            child: PeerCard(children: [
                              const Icon(Icons.menu_book_outlined,
                                  color: peerBlue),
                              const SizedBox(height: 12),
                              Text(entry.key,
                                  style: const TextStyle(
                                      color: AppColors.accentOrange,
                                      fontWeight: FontWeight.w800)),
                              Text(entry.value,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600)),
                              const SizedBox(height: 10),
                              Text(
                                  '${data.tutors.where((t) => t.modules.contains(entry.key)).length} tutors ready',
                                  style: const TextStyle(fontSize: 12))
                            ])))
                ]),
                if (data.isTutor)
                  PeerButton('Tutor Management Dashboard',
                      icon: Icons.dashboard_outlined,
                      onPressed: () => openPeerScreen(
                          context, const TutorManagementDashboardScreen())),
                const PeerFreeNote(),
                AsyncPeerButton('Log Out', secondary: true, action: () async {
                  await data.signOut();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute<void>(
                            builder: (_) => const LoginScreen()),
                        (_) => false);
                  }
                }),
              ]));
}
