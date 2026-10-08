import 'package:flutter/material.dart';
import '../../models/peer_records.dart';
import '../../services/booking_repository.dart';
import '../../widgets/peer_ui.dart';
import '../../widgets/peer_navigation.dart';
import '../../widgets/data_widgets.dart';
import '../../widgets/booking_workflow.dart';
import '../onboarding/tutor_profile_setup_screen.dart';
import 'booking_details_screen.dart';
import 'availability_calendar_screen.dart';

class TutorManagementDashboardScreen extends StatelessWidget {
  const TutorManagementDashboardScreen({super.key});
  @override
  Widget build(BuildContext context) => DataView(builder: (context, data) {
        final own = data.bookings.where((b) => b.tutorId == data.uid).toList();
        final pending = own.where((b) => b.status == 'pending').toList();
        final confirmed = own.where((b) => b.status == 'confirmed').toList();
        final complete = own.where((b) => b.status == 'completed').length;
        final repo = BookingRepository(data);
        return PeerPage(
            title: 'Tutor Management Dashboard',
            bottom: const PeerNavigation(index: 1, tutor: true),
            children: [
              const PeerBadge('● TUTOR PORTAL • Faculty of Computing'),
              const SizedBox(height: 12),
              Text('Ayubowan, ${data.name}! 👋',
                  style: const TextStyle(
                      fontSize: 25, fontWeight: FontWeight.w800)),
              Text(
                  'You have ${pending.length} peer study requests awaiting response.'),
              const SizedBox(height: 16),
              if (!data.isTutor)
                PeerButton('Set Up Your Tutor Profile',
                    onPressed: () => openPeerScreen(
                        context, const TutorProfileSetupScreen())),
              PeerCard(children: [
                Wrap(spacing: 12, runSpacing: 12, children: [
                  PeerBadge('$complete Students Helped'),
                  PeerBadge('${pending.length} Pending Requests'),
                  PeerBadge(
                      '★ ${data.rating(data.uid).toStringAsFixed(1)} Peer Reviews'),
                  const PeerBadge('0 LKR • Free Mentorship')
                ])
              ]),
              Row(children: [
                const Expanded(child: PeerTitle('Pending Requests')),
                TextButton(
                    onPressed: !pending.any((b) => b.mode == 'Campus')
                        ? null
                        : () => perform(context, () async {
                              final yes = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                          title: const Text(
                                              'Accept pending campus requests?'),
                                          content: Text(
                                              'Confirm ${pending.where((b) => b.mode == 'Campus').length} campus sessions. Accept online requests individually to add their Teams links.'),
                                          actions: [
                                            TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(ctx, false),
                                                child: const Text('Cancel')),
                                            TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(ctx, true),
                                                child: const Text('Accept All'))
                                          ]));
                              if (yes == true) {
                                for (final booking in pending.where((b) => b.mode == 'Campus')) {
                                  await repo.transition(booking, 'confirmed');
                                }
                              }
                            }),
                    child: const Text('Batch Actions'))
              ]),
              if (pending.isEmpty)
                const PeerCard(children: [Text('No pending requests.')]),
              for (final booking in pending)
                PeerCard(children: [
                  PeerPerson(name: booking.tuteeName, subtitle: 'Student'),
                  PeerBadge(booking.module),
                  const SizedBox(height: 12),
                  PeerCard(color: peerTint, children: [
                    const Text('ⓘ Focus Area'),
                    Text(booking.notes.isEmpty
                        ? 'No preparation notes provided.'
                        : booking.notes)
                  ]),
                  PeerInfo(
                      Icons.event,
                      '${bookingDate(booking)} • ${bookingTime(booking)}',
                      '${booking.venue} • ${booking.mode}'),
                  Row(children: [
                    Expanded(
                        child: AsyncPeerButton('Accept Request',
                            icon: Icons.check, action: () async {
                      String? teams;
                      if (booking.mode == 'Online') {
                        final controller = TextEditingController();
                        teams = await showDialog<String>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                                    title: const Text('Teams meeting link'),
                                    content: TextField(
                                        controller: controller,
                                        decoration: const InputDecoration(
                                            hintText:
                                                'https://teams.microsoft.com/…')),
                                    actions: [
                                      TextButton(
                                          onPressed: () => Navigator.pop(ctx),
                                          child: const Text('Cancel')),
                                      TextButton(
                                          onPressed: () => Navigator.pop(
                                              ctx, controller.text.trim()),
                                          child: const Text('Accept'))
                                    ]));
                        controller.dispose();
                        if (teams == null) return;
                        final url = Uri.tryParse(teams);
                        if (url == null ||
                            url.scheme != 'https' ||
                            ![
                              'teams.microsoft.com',
                              'teams.live.com',
                              'teams.cloud.microsoft'
                            ].contains(url.host)) {
                          throw StateError(
                              'Enter a valid Microsoft Teams link.');
                        }
                      }
                      await repo.transition(booking, 'confirmed',
                          teamsUrl: teams);
                    })),
                    const SizedBox(width: 8),
                    Expanded(
                        child: AsyncPeerButton('Decline',
                            secondary: true,
                            icon: Icons.close,
                            action: () => repo.transition(booking, 'declined')))
                  ]),
                ]),
              Row(children: [
                const Expanded(child: PeerTitle('Upcoming Confirmed Sessions')),
                TextButton(
                    onPressed: () => openPeerScreen(
                        context, const AvailabilityCalendarScreen()),
                    child: const Text('View Calendar'))
              ]),
              if (confirmed.isEmpty)
                const PeerCard(
                    children: [Text('Accepted requests will appear here.')]),
              for (final booking in confirmed)
                PeerCard(children: [
                  PeerPerson(
                      name: booking.tuteeName,
                      subtitle: moduleLabel(booking.module)),
                  const PeerBadge('● Confirmed', color: peerGreen),
                  const SizedBox(height: 12),
                  PeerInfo(
                      Icons.schedule,
                      '${bookingDate(booking)} • ${bookingTime(booking)}',
                      booking.venue),
                  PeerButton('Session Details & Message',
                      secondary: true,
                      onPressed: () => openPeerScreen(
                          context, BookingDetailsScreen(bookingId: booking.id)))
                ]),
              const PeerFreeNote(),
            ]);
      });
}
