import 'package:flutter/material.dart';
import '../../services/app_data.dart';
import '../../services/upload_service.dart';
import '../../models/peer_records.dart';
import '../../widgets/peer_ui.dart';
import '../../widgets/peer_navigation.dart';
import '../../widgets/data_widgets.dart';
import '../../widgets/booking_workflow.dart';
import '../discovery/search_discovery_screen.dart';
import '../messaging/review_modal_screen.dart';
import '../messaging/guidelines_overlay_screen.dart';
import 'booking_details_screen.dart';

class StudentScheduleScreen extends StatefulWidget {
  const StudentScheduleScreen({super.key});
  @override
  State<StudentScheduleScreen> createState() => _StudentScheduleScreenState();
}

class _StudentScheduleScreenState extends State<StudentScheduleScreen> {
  int tab = 0;
  int reviewFilter = 0;
  @override
  Widget build(BuildContext context) => DataView(builder: (context, data) {
        final own = data.bookings.where((b) => b.tuteeId == data.uid).toList();
        final groups = [
          own
              .where((b) =>
                  b.status == 'confirmed' && b.end.isAfter(DateTime.now()))
              .toList(),
          own
              .where((b) => !b.active || b.end.isBefore(DateTime.now()))
              .toList(),
          own
              .where(
                  (b) => b.status == 'pending' && b.end.isAfter(DateTime.now()))
              .toList()
        ];
        final reviewedIds = data.reviews
            .where((r) => r.tuteeId == data.uid)
            .map((r) => r.id)
            .toSet();
        groups[1].sort((a, b) => b.end.compareTo(a.end));
        final past = groups[1];
        final awaiting = past
            .where(
                (b) => b.status == 'completed' && !reviewedIds.contains(b.id))
            .toList();
        final reviewed = past.where((b) => reviewedIds.contains(b.id)).toList();
        final visible =
            tab == 1 ? [past, awaiting, reviewed][reviewFilter] : groups[tab];
        return PeerPage(
            title: 'Bookings',
            bottom: const PeerNavigation(index: 2),
            children: [
              const Text('My Study Schedule',
                  style: TextStyle(
                      fontSize: 28,
                      color: peerBlue,
                      fontWeight: FontWeight.w800)),
              Text('Collaborative study sessions for ${data.name}'),
              const SizedBox(height: 16),
              SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: [
                    for (int i = 0; i < 3; i++)
                      Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                              label: Text('${[
                                'Upcoming',
                                'Past Sessions',
                                'Pending Requests'
                              ][i]} (${groups[i].length})'),
                              selected: tab == i,
                              onSelected: (_) => setState(() => tab = i)))
                  ])),
              const SizedBox(height: 20),
              PeerTitle(
                  [
                    'Upcoming Confirmed Sessions',
                    'Past Study Sessions',
                    'Pending Requests'
                  ][tab],
                  icon: Icons.event_available),
              if (tab == 1) ...[
                Wrap(spacing: 8, runSpacing: 8, children: [
                  for (final entry in [
                    'All (${past.length})',
                    'Awaiting Review (${awaiting.length})',
                    'Reviewed (${reviewed.length})'
                  ].asMap().entries)
                    ChoiceChip(
                        label: Text(entry.value),
                        selected: reviewFilter == entry.key,
                        onSelected: (_) =>
                            setState(() => reviewFilter = entry.key))
                ]),
                const SizedBox(height: 16),
                const Text(
                    'Reviews become available when your tutor marks the session completed.'),
                const SizedBox(height: 12),
              ],
              for (final booking in visible) _card(context, booking, data),
              if (tab == 1 && visible.isEmpty)
                PeerCard(children: [
                  Text(reviewFilter == 1
                      ? 'No completed sessions awaiting a review.'
                      : reviewFilter == 2
                          ? 'Your reviewed sessions will appear here.'
                          : 'Your past sessions will appear here.')
                ]),
              if (tab != 1 && visible.isEmpty)
                PeerCard(color: const Color(0xFFE3EDFF), children: [
                  const Center(
                      child: Icon(Icons.calendar_month,
                          color: peerBlue, size: 56)),
                  const SizedBox(height: 16),
                  const PeerTitle('No sessions to show'),
                  const Text(
                      'Connect with a verified peer tutor for free study guidance.',
                      textAlign: TextAlign.center),
                  PeerButton('Find a SLIIT Peer Tutor',
                      onPressed: () => openPeerScreen(
                          context, const SearchDiscoveryScreen()))
                ]),
              TextButton(
                  onPressed: () =>
                      openPeerScreen(context, const GuidelinesOverlayScreen()),
                  child: const Text(
                      'Need to reschedule or cancel? • Peer Guidelines')),
            ]);
      });
  Widget _card(BuildContext context, PeerBooking booking, AppData data) =>
      PeerCard(children: [
        PeerBadge(moduleLabel(booking.module),
            color: Colors.white, background: peerBlue),
        const SizedBox(height: 8),
        PeerBadge('${booking.status.toUpperCase()} (100% Free)',
            color: peerGreen),
        const SizedBox(height: 16),
        PeerPerson(name: booking.tutorName, subtitle: 'Peer Mentor'),
        PeerCard(color: peerTint, children: [
          PeerInfo(Icons.event, 'Scheduled Time',
              '${bookingDate(booking)} • ${bookingTime(booking)}'),
          PeerInfo(
              booking.mode == 'Online'
                  ? Icons.videocam_outlined
                  : Icons.local_library_outlined,
              'Location & Mode',
              '${booking.venue} • ${booking.mode}')
        ]),
        PeerButton('View Booking Details',
            secondary: true,
            onPressed: () => openPeerScreen(
                context, BookingDetailsScreen(bookingId: booking.id))),
        if (booking.status == 'confirmed' &&
            !booking.end.isAfter(DateTime.now()))
          const Text('Awaiting tutor completion',
              style: TextStyle(fontWeight: FontWeight.w600)),
        if (booking.mode == 'Online' &&
            booking.status == 'confirmed' &&
            booking.end.isAfter(DateTime.now()))
          AsyncPeerButton('Join Teams Meeting',
              orange: true,
              action: () => UploadService.openTeams(booking.teamsUrl)),
        if (booking.status == 'completed')
          if (data.reviews
              .any((r) => r.id == booking.id && r.tuteeId == data.uid))
            PeerBadge(
                'Review submitted • ${data.reviews.firstWhere((r) => r.id == booking.id && r.tuteeId == data.uid).rating.toInt()}/5'),
        if (booking.status == 'completed')
          PeerButton(
              data.reviews.any((r) => r.id == booking.id)
                  ? 'Edit Your Review'
                  : 'Submit a Review',
              icon: Icons.star_outline,
              onPressed: () => openPeerScreen(
                  context, ReviewModalScreen(bookingId: booking.id))),
      ]);
}
