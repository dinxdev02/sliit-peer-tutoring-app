import 'package:flutter/material.dart';
import '../../widgets/peer_ui.dart';
import '../../widgets/peer_navigation.dart';
import '../../widgets/data_widgets.dart';
import '../booking/student_schedule_screen.dart';
import '../booking/booking_details_screen.dart';
import '../messaging/review_modal_screen.dart';
import '../messaging/report_misuse_screen.dart';
import '../messaging/notifications_screen.dart';
import '../messaging/guidelines_overlay_screen.dart';
import '../discovery/search_discovery_screen.dart';
import 'tutor_profile_setup_screen.dart';
import 'login_screen.dart';

class TuteeProfileScreen extends StatefulWidget {
  const TuteeProfileScreen({super.key});
  @override
  State<TuteeProfileScreen> createState() => _TuteeProfileScreenState();
}

class _TuteeProfileScreenState extends State<TuteeProfileScreen> {
  int tab = 0;
  @override
  Widget build(BuildContext context) => DataView(
      builder: (context, data) => PeerPage(
              title: 'My Profile',
              bottom: const PeerNavigation(index: 4),
              children: [
                PeerCard(children: [
                  PeerPerson(
                      name: data.name,
                      subtitle:
                          '${data.profile?['year'] ?? ''} • ${data.profile?['program'] ?? ''}'),
                  Text(data.profile?['email'] ?? ''),
                  const SizedBox(height: 10),
                  PeerBadge(data.verified
                      ? 'Enrollment verified'
                      : 'Enrollment verification pending'),
                  PeerButton('Edit Profile', secondary: true,
                      onPressed: () async {
                    final name = TextEditingController(text: data.name);
                    final year = TextEditingController(
                        text: data.profile?['year'] ?? '');
                    final program = TextEditingController(
                        text: data.profile?['program'] ?? '');
                    await showDialog<void>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                                title: const Text('Edit Profile'),
                                content: SingleChildScrollView(
                                    child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                      TextField(
                                          controller: name,
                                          decoration: const InputDecoration(
                                              labelText: 'Full name')),
                                      TextField(
                                          controller: year,
                                          decoration: const InputDecoration(
                                              labelText: 'Year')),
                                      TextField(
                                          controller: program,
                                          decoration: const InputDecoration(
                                              labelText: 'Program'))
                                    ])),
                                actions: [
                                  TextButton(
                                      onPressed: () => Navigator.pop(ctx),
                                      child: const Text('Cancel')),
                                  TextButton(
                                      onPressed: () async {
                                        if (name.text.trim().length < 2) {
                                          peerNotice(
                                              ctx, 'Enter your full name.');
                                          return;
                                        }
                                        final ok = await perform(
                                            ctx,
                                            () => data.saveProfile({
                                                  'name': name.text.trim(),
                                                  'year': year.text.trim(),
                                                  'program': program.text.trim()
                                                }));
                                        if (ok && ctx.mounted) {
                                          Navigator.pop(ctx);
                                        }
                                      },
                                      child: const Text('Save'))
                                ]));
                    name.dispose();
                    year.dispose();
                    program.dispose();
                  })
                ]),
                Wrap(spacing: 8, children: [
                  ChoiceChip(
                      label: const Text('My Bookings'),
                      selected: tab == 0,
                      onSelected: (_) => setState(() => tab = 0)),
                  ChoiceChip(
                      label: const Text('Reviews Given'),
                      selected: tab == 1,
                      onSelected: (_) => setState(() => tab = 1))
                ]),
                const SizedBox(height: 16),
                if (tab == 0) ...[
                  for (final b
                      in data.bookings.where((b) => b.tuteeId == data.uid))
                    PeerCard(children: [
                      PeerPerson(name: b.tutorName, subtitle: b.module),
                      PeerBadge(b.status.toUpperCase()),
                      PeerButton('View Booking',
                          secondary: true,
                          onPressed: () => openPeerScreen(
                              context, BookingDetailsScreen(bookingId: b.id)))
                    ]),
                  PeerButton('View My Study Schedule',
                      onPressed: () => openPeerScreen(
                          context, const StudentScheduleScreen()))
                ],
                if (tab == 1) ...[
                  for (final r
                      in data.reviews.where((r) => r.tuteeId == data.uid))
                    PeerCard(children: [
                      PeerTitle('★ ${r.rating.toInt()}/5'),
                      Text(r.comment),
                      PeerButton('Edit / Delete Review',
                          secondary: true,
                          onPressed: () => openPeerScreen(
                              context, ReviewModalScreen(bookingId: r.id)))
                    ]),
                  if (!data.reviews.any((r) => r.tuteeId == data.uid))
                    const PeerCard(children: [
                      Text('Your submitted session reviews will appear here.')
                    ])
                ],
                const PeerTitle('Account & Community'),
                PeerButton('Saved Tutors',
                    secondary: true,
                    onPressed: () =>
                        openPeerScreen(context, const SearchDiscoveryScreen(savedOnly: true))),
                PeerButton('Notifications',
                    secondary: true,
                    onPressed: () =>
                        openPeerScreen(context, const NotificationsScreen())),
                PeerButton('Academic Guidelines',
                    secondary: true,
                    onPressed: () => openPeerScreen(
                        context, const GuidelinesOverlayScreen())),
                PeerButton('Switch to Tutor Mode',
                    secondary: true,
                    onPressed: () => openPeerScreen(
                        context, const TutorProfileSetupScreen())),
                PeerButton('My Confidential Reports',
                    secondary: true,
                    onPressed: () => showModalBottomSheet(
                        context: context,
                        builder: (ctx) => SafeArea(
                                child: ListView(
                                    padding: const EdgeInsets.all(16),
                                    children: [
                                  const PeerTitle('My Reports'),
                                  for (final report in data.reports)
                                    PeerCard(children: [
                                      Text(report['reason']),
                                      Text(report['details']),
                                      PeerBadge(report['status'])
                                    ]),
                                  if (data.reports.isEmpty)
                                    const Text('No reports submitted.'),
                                  PeerButton('Report a Session',
                                      onPressed: () => openPeerScreen(
                                          ctx, const ReportMisuseScreen()))
                                ])))),
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
