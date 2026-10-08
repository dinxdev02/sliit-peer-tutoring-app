import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/peer_records.dart';
import '../../widgets/peer_ui.dart';
import '../../widgets/peer_navigation.dart';
import '../../widgets/data_widgets.dart';
import '../booking/booking_details_screen.dart';
import 'chat_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  int tab = 0;
  @override
  Widget build(BuildContext context) => DataView(builder: (context, data) {
        final filtered = data.notifications
            .where((n) =>
                tab == 0 ||
                n['type'] == ['', 'booking', 'message', 'system'][tab])
            .toList();
        return PeerPage(
            title: 'Notifications',
            bottom: const PeerNavigation(index: 0),
            children: [
              Row(children: [
                const Expanded(
                    child: Text('Notifications',
                        style: TextStyle(
                            fontSize: 28, fontWeight: FontWeight.w800))),
                PeerBadge(
                    '${data.notifications.where((n) => n['read'] != true).length} new',
                    color: const Color(0xFFA84800),
                    background: const Color(0xFFFFDCC8))
              ]),
              AsyncPeerButton('Mark all as read',
                  secondary: true, action: () => data.markRead()),
              const SizedBox(height: 12),
              SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: [
                    for (int i = 0; i < 4; i++)
                      Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                              label: Text(
                                  ['All', 'Bookings', 'Messages', 'System'][i]),
                              selected: tab == i,
                              onSelected: (_) => setState(() => tab = i)))
                  ])),
              const SizedBox(height: 20),
              for (final n in filtered)
                PeerCard(children: [
                  Row(children: [
                    Icon(
                        n['type'] == 'message'
                            ? Icons.chat_bubble_outline
                            : Icons.event,
                        color: peerBlue),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Text(n['message'],
                            style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                height: 1.5))),
                    if (n['read'] != true)
                      const Icon(Icons.circle, color: Colors.orange, size: 12)
                  ]),
                  const SizedBox(height: 12),
                  Text(
                      DateFormat('MMM d • h:mm a')
                          .format(recordDate(n['createdAt'])),
                      style: const TextStyle(color: Colors.grey)),
                  AsyncPeerButton(
                      n['type'] == 'message' ? 'Reply' : 'View Booking',
                      action: () async {
                    await data.markRead(id: n['id']);
                    if (!context.mounted) return;
                    if (n['type'] == 'message') {
                      final chat = data.chats
                          .where((c) => c['id'] == n['chatId'])
                          .firstOrNull;
                      if (chat == null) {
                        throw StateError('This conversation is unavailable.');
                      }
                      openPeerScreen(
                          context,
                          ChatScreen(
                              chatId: chat['id'],
                              peerName: (chat['names'] as Map)
                                      .entries
                                      .where((e) => e.key != data.uid)
                                      .map((e) => e.value.toString())
                                      .firstOrNull ??
                                  'Peer',
                              bookingId: chat['bookingId']));
                    } else {
                      openPeerScreen(context,
                          BookingDetailsScreen(bookingId: n['bookingId']));
                    }
                  }),
                  Row(children: [
                    TextButton(
                        onPressed: () =>
                            perform(context, () => data.markRead(id: n['id'])),
                        child: const Text('Mark read')),
                    const Spacer(),
                    TextButton(
                        onPressed: () => perform(
                            context, () => data.deleteNotification(n['id'])),
                        child: const Text('Delete'))
                  ]),
                ]),
              if (filtered.isEmpty)
                const PeerCard(color: peerTint, children: [
                  Center(
                      child: Icon(Icons.task_alt, color: peerBlue, size: 48)),
                  SizedBox(height: 18),
                  PeerTitle("You're all caught up!"),
                  Text('New peer session updates will appear here.')
                ]),
            ]);
      });
}
