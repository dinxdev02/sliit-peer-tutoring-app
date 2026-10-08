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
                  Row(children: [
                    CircleAvatar(
                        radius: 30,
                        backgroundColor: peerTint,
                        child: Text(
                            data.name
                                .trim()
                                .split(RegExp(r'\s+'))
                                .where((p) => p.isNotEmpty)
                                .take(2)
                                .map((p) => p[0])
                                .join()
                                .toUpperCase(),
                            style: const TextStyle(
                                color: peerBlue,
                                fontSize: 22,
                                fontWeight: FontWeight.w700))),
                    const SizedBox(width: 14),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text(data.name,
                              style: const TextStyle(
                                  fontSize: 21, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 6),
                          const PeerBadge('SLIIT Student'),
                        ])),
                  ]),
                  const SizedBox(height: 18),
                  _ProfileDetail(
                      Icons.school_outlined,
                      [data.profile?['year'], data.profile?['program']]
                          .where((v) =>
                              v != null && v.toString().trim().isNotEmpty)
                          .join(' • ')),
                  const SizedBox(height: 10),
                  _ProfileDetail(
                      Icons.mail_outline, data.profile?['email'] ?? ''),
                  const SizedBox(height: 16),
                  Row(children: [
                    Icon(
                        data.verified
                            ? Icons.verified_outlined
                            : Icons.schedule,
                        size: 18,
                        color: data.verified
                            ? peerGreen
                            : const Color(0xFF936215)),
                    const SizedBox(width: 7),
                    Expanded(
                        child: Text(
                            data.verified
                                ? 'Enrollment verified'
                                : 'Enrollment verification pending',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: data.verified
                                    ? peerGreen
                                    : const Color(0xFF936215)))),
                  ]),
                  const SizedBox(height: 8),
                  PeerButton('Edit Profile',
                      icon: Icons.edit_outlined,
                      secondary: true, onPressed: () async {
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
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                      color: const Color(0xFFE9EDFA),
                      borderRadius: BorderRadius.circular(14)),
                  child: Row(children: [
                    for (final entry in [
                      (Icons.calendar_today_outlined, 'My Bookings'),
                      (Icons.star_outline, 'Reviews Given')
                    ].asMap().entries)
                      Expanded(
                          child: Semantics(
                              selected: tab == entry.key,
                              child: TextButton.icon(
                                onPressed: () =>
                                    setState(() => tab = entry.key),
                                icon: Icon(entry.value.$1, size: 18),
                                label: Text(entry.value.$2,
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600)),
                                style: TextButton.styleFrom(
                                    minimumSize: const Size(0, 44),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6),
                                    backgroundColor: tab == entry.key
                                        ? Colors.white
                                        : Colors.transparent,
                                    foregroundColor: tab == entry.key
                                        ? peerBlue
                                        : const Color(0xFF69738A),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10))),
                              ))),
                  ]),
                ),
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
                const SizedBox(height: 16),
                const Padding(
                    padding: EdgeInsets.only(left: 4, bottom: 12),
                    child: Text('Account & Community',
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w700))),
                PeerCard(children: [
                  _ProfileMenuRow('Saved Tutors',
                      icon: Icons.bookmark_border,
                      onPressed: () => openPeerScreen(context,
                          const SearchDiscoveryScreen(savedOnly: true))),
                  _ProfileMenuRow('Notifications',
                      icon: Icons.notifications_none,
                      onPressed: () =>
                          openPeerScreen(context, const NotificationsScreen())),
                  _ProfileMenuRow('Academic Guidelines',
                      icon: Icons.menu_book_outlined,
                      onPressed: () => openPeerScreen(
                          context, const GuidelinesOverlayScreen())),
                  _ProfileMenuRow('Switch to Tutor Mode',
                      icon: Icons.school_outlined,
                      onPressed: () => openPeerScreen(
                          context, const TutorProfileSetupScreen())),
                  _ProfileMenuRow('My Confidential Reports',
                      icon: Icons.shield_outlined,
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
                ]),
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

class _ProfileDetail extends StatelessWidget {
  final IconData icon;
  final String text;
  const _ProfileDetail(this.icon, this.text);
  @override
  Widget build(BuildContext context) =>
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, size: 18, color: const Color(0xFF78839A)),
        const SizedBox(width: 10),
        Expanded(
            child: Text(text,
                style: const TextStyle(
                    fontSize: 13, color: Color(0xFF69738A), height: 1.4))),
      ]);
}

class _ProfileMenuRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  const _ProfileMenuRow(this.label,
      {required this.icon, required this.onPressed});
  @override
  Widget build(BuildContext context) => ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        leading: Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
                color: peerTint, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: peerBlue, size: 20)),
        title: Text(label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        trailing:
            const Icon(Icons.chevron_right, size: 20, color: Color(0xFF939EB2)),
        onTap: onPressed,
      );
}
