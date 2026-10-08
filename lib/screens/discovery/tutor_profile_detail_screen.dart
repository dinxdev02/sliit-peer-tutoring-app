import 'package:flutter/material.dart';
import '../../models/peer_records.dart';
import '../../widgets/peer_ui.dart';
import '../../widgets/data_widgets.dart';
import '../../widgets/booking_workflow.dart';
import '../messaging/chat_screen.dart';

class TutorProfileDetailScreen extends StatefulWidget {
  final String tutorId, tutorName;
  const TutorProfileDetailScreen(
      {super.key, this.tutorId = '', this.tutorName = ''});
  @override
  State<TutorProfileDetailScreen> createState() =>
      _TutorProfileDetailScreenState();
}

class _TutorProfileDetailScreenState extends State<TutorProfileDetailScreen> {
  int tab = 0;
  @override
  Widget build(BuildContext context) => DataView(builder: (context, data) {
        final tutor = data.tutor(widget.tutorId);
        if (tutor == null) {
          return const PeerPage(title: 'Tutor Details', children: [
            PeerCard(children: [
              Text('This tutor is unavailable or awaiting verification.')
            ])
          ]);
        }
        final reviews =
            data.reviews.where((r) => r.tutorId == tutor.id).toList();
        final slots = data.openSlots(tutor.id);
        return PeerPage(
            title: 'Tutor Details',
            bottom: SafeArea(
                child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(children: [
                      Expanded(
                          child: AsyncPeerButton('Message Peer',
                              secondary: true, icon: Icons.chat_bubble_outline,
                              action: () async {
                        final id = await data.createChat(tutor.id, tutor.name);
                        if (context.mounted) {
                          openPeerScreen(context,
                              ChatScreen(chatId: id, peerName: tutor.name));
                        }
                      })),
                      const SizedBox(width: 8),
                      Expanded(
                          child: AsyncPeerButton('Book Free Study Session',
                              orange: true,
                              icon: Icons.event,
                              action: tutor.id == data.uid
                                  ? null
                                  : () => requestStudySession(context, tutor)))
                    ]))),
            children: [
              PeerCard(children: [
                PeerPerson(
                    name: tutor.name,
                    subtitle: '${tutor.year} • ${tutor.program}'),
                Text(reviews.isEmpty
                    ? 'New Peer Mentor • No reviews yet'
                    : '★ ${data.rating(tutor.id).toStringAsFixed(1)} (${reviews.length} peer reviews)'),
                AsyncPeerButton(
                    data.favorites.contains(tutor.id)
                        ? 'Remove from Saved Tutors'
                        : 'Save Tutor',
                    secondary: true,
                    icon: data.favorites.contains(tutor.id)
                        ? Icons.bookmark
                        : Icons.bookmark_outline,
                    action: () => data.toggleFavorite(tutor.id))
              ]),
              Wrap(spacing: 8, children: [
                for (int i = 0; i < 3; i++)
                  ChoiceChip(
                      label: Text([
                        'Overview',
                        'Availability',
                        'Reviews (${reviews.length})'
                      ][i]),
                      selected: tab == i,
                      onSelected: (_) => setState(() => tab = i))
              ]),
              const SizedBox(height: 16),
              if (tab == 0) ...[
                PeerCard(children: [
                  const PeerTitle('About Me', icon: Icons.person_outline),
                  Text(tutor.bio, style: const TextStyle(height: 1.5))
                ]),
                const PeerTitle('SLIIT Modules Tutored',
                    icon: Icons.menu_book_outlined),
                for (final module in tutor.modules)
                  PeerCard(children: [
                    Text(moduleLabel(module),
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    const PeerBadge('Free Peer Guidance')
                  ]),
                PeerCard(children: [
                  const PeerTitle('Preferred Meeting Spots',
                      icon: Icons.location_on_outlined),
                  Text(slots.isEmpty
                      ? 'No future availability published.'
                      : slots.map((s) => s.venue).toSet().join('\n'))
                ]),
              ],
              if (tab == 1) ...[
                const PeerTitle('Available Study Slots'),
                if (slots.isEmpty)
                  const PeerCard(
                      children: [Text('No future slots are available.')]),
                for (final slot in slots)
                  PeerCard(children: [
                    Text(slotLabel(slot),
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    Text('${slot.mode} • ${slot.venue}'),
                    AsyncPeerButton('Request Session',
                        action: () => requestStudySession(context, tutor))
                  ])
              ],
              if (tab == 2) ...[
                if (reviews.isEmpty)
                  const PeerCard(children: [
                    Text(
                        'No reviews yet. Reviews appear after completed sessions.')
                  ]),
                for (final review in reviews)
                  PeerCard(children: [
                    PeerTitle(
                        '★ ${review.rating.toInt()}/5 • ${review.author}'),
                    Text(review.comment),
                    Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: review.tags.map((t) => PeerBadge(t)).toList())
                  ])
              ],
            ]);
      });
}
