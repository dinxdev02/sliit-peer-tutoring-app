import 'package:flutter/material.dart';
import '../../services/booking_repository.dart';
import '../../services/upload_service.dart';
import '../../models/peer_records.dart';
import '../../widgets/peer_ui.dart';
import '../../widgets/data_widgets.dart';
import '../../widgets/booking_workflow.dart';
import '../messaging/chat_screen.dart';
import '../messaging/report_misuse_screen.dart';
import '../messaging/review_modal_screen.dart';

class BookingDetailsScreen extends StatelessWidget {
  final String bookingId;
  const BookingDetailsScreen({super.key, this.bookingId = ''});
  @override
  Widget build(BuildContext context) => DataView(builder: (context, data) {
        final booking = data.booking(bookingId);
        if (booking == null) {
          return const PeerPage(
              title: 'Booking Details',
              children: [Text('This booking is unavailable.')]);
        }
        final tutor = booking.tutorId == data.uid;
        final peerId = tutor ? booking.tuteeId : booking.tutorId;
        final peerName = tutor ? booking.tuteeName : booking.tutorName;
        final repo = BookingRepository(data);
        return PeerPage(title: 'Booking Details', children: [
          PeerCard(children: [
            Wrap(spacing: 12, runSpacing: 8, children: [
              PeerBadge(booking.status.toUpperCase(),
                  color: peerGreen, background: peerMint),
              PeerBadge(
                  '#${booking.id.substring(0, booking.id.length < 8 ? booking.id.length : 8)}')
            ]),
            const SizedBox(height: 16),
            const Text('100% Free Peer Study Session • Faculty of Computing')
          ]),
          PeerCard(children: [
            PeerPerson(
                name: peerName, subtitle: tutor ? 'Student' : 'Peer Mentor'),
            PeerCard(color: peerTint, children: [
              PeerBadge('MODULE • ${booking.module}'),
              const SizedBox(height: 12),
              PeerTitle(moduleLabel(booking.module))
            ])
          ]),
          PeerCard(children: [
            const PeerTitle('Session Details', icon: Icons.event_available),
            PeerInfo(
                Icons.calendar_today_outlined, 'Date', bookingDate(booking)),
            PeerInfo(Icons.schedule, 'Time & Duration',
                '${bookingTime(booking)} (${booking.end.difference(booking.start).inMinutes} mins)'),
            PeerInfo(Icons.location_on_outlined, 'Venue', booking.venue),
            PeerInfo(Icons.groups_outlined, 'Format',
                '${booking.mode} • 1-on-1 Peer Study')
          ]),
          PeerCard(children: [
            const PeerTitle('Preparation Notes',
                icon: Icons.sticky_note_2_outlined),
            PeerCard(color: peerTint, children: [
              Text(
                  booking.notes.isEmpty
                      ? 'No preparation notes provided.'
                      : booking.notes,
                  style: const TextStyle(height: 1.6))
            ])
          ]),
          const PeerFreeNote(),
          AsyncPeerButton(tutor ? 'Message Student' : 'Message Tutor',
              icon: Icons.chat_bubble_outline, action: () async {
            final id =
                await data.createChat(peerId, peerName, bookingId: booking.id);
            if (context.mounted) {
              openPeerScreen(
                  context,
                  ChatScreen(
                      chatId: id, peerName: peerName, bookingId: booking.id));
            }
          }),
          if (booking.mode == 'Online' && booking.status == 'confirmed')
            AsyncPeerButton('Join Teams Meeting',
                orange: true,
                action: () => UploadService.openTeams(booking.teamsUrl)),
          if (!tutor && booking.active)
            AsyncPeerButton('Reschedule Session',
                secondary: true,
                icon: Icons.edit_calendar_outlined, action: () async {
              final slots = data.openSlots(booking.tutorId);
              final next = await showModalBottomSheet<PeerSlot>(
                  context: context,
                  builder: (ctx) => SafeArea(
                          child: ListView(
                              padding: const EdgeInsets.all(16),
                              children: [
                            const PeerTitle('Choose a replacement slot'),
                            if (slots.isEmpty)
                              const Text('No replacement slots are available.'),
                            for (final slot in slots)
                              ListTile(
                                  title: Text(slotLabel(slot)),
                                  subtitle: Text(slot.venue),
                                  onTap: () => Navigator.pop(ctx, slot))
                          ])));
              if (next != null) await repo.reschedule(booking, next);
            }),
          if (booking.active)
            AsyncPeerButton('Cancel Booking',
                secondary: true, icon: Icons.cancel_outlined, action: () async {
              final cancel = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                          title: const Text('Cancel this booking?'),
                          content: const Text(
                              'Both participants will receive a cancellation notification.'),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('Keep Booking')),
                            TextButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text('Cancel Booking'))
                          ]));
              if (cancel == true) await repo.transition(booking, 'cancelled');
            }),
          if (tutor &&
              booking.status == 'confirmed' &&
              !booking.end.isAfter(DateTime.now()))
            AsyncPeerButton('Mark Session Completed',
                action: () => repo.transition(booking, 'completed')),
          if (!tutor && booking.status == 'completed')
            PeerButton('Review This Session',
                onPressed: () => openPeerScreen(
                    context, ReviewModalScreen(bookingId: booking.id))),
          PeerButton('Report Session Issue',
              secondary: true,
              onPressed: () => openPeerScreen(
                  context, ReportMisuseScreen(bookingId: booking.id))),
        ]);
      });
}
