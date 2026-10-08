import 'package:flutter/material.dart';
import '../../widgets/peer_ui.dart';
import '../../widgets/peer_navigation.dart';
import '../../widgets/data_widgets.dart';
import 'chat_screen.dart';

class MessagingInboxScreen extends StatelessWidget {
  const MessagingInboxScreen({super.key});
  @override
  Widget build(BuildContext context) => DataView(
      builder: (context, data) => PeerPage(
              title: 'Messages',
              bottom: const PeerNavigation(index: 3),
              children: [
                const PeerTitle('Peer Conversations'),
                if (data.chats.isEmpty)
                  const PeerCard(children: [
                    Text(
                        'No conversations yet. Message a tutor from their profile or booking.')
                  ]),
                for (final chat in data.chats)
                  PeerCard(children: [
                    PeerPerson(
                        name: (chat['names'] as Map)
                                .entries
                                .where((e) => e.key != data.uid)
                                .map((e) => e.value.toString())
                                .firstOrNull ??
                            'Peer',
                        subtitle: 'Free peer study'),
                    PeerButton('Open Conversation',
                        icon: Icons.chat_bubble_outline,
                        onPressed: () => openPeerScreen(
                            context,
                            ChatScreen(
                                chatId: chat['id'],
                                peerName: (chat['names'] as Map)
                                        .entries
                                        .where((e) => e.key != data.uid)
                                        .map((e) => e.value.toString())
                                        .firstOrNull ??
                                    'Peer',
                                bookingId: chat['bookingId'] ??
                                    data.bookings
                                        .where((b) =>
                                            (chat['members'] as List)
                                                .contains(b.tutorId) &&
                                            (chat['members'] as List)
                                                .contains(b.tuteeId))
                                        .firstOrNull
                                        ?.id))),
                  ]),
                const PeerFreeNote(),
              ]));
}
