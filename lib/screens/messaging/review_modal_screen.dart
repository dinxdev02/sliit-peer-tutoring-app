import 'package:flutter/material.dart';
import '../../services/app_data.dart';
import '../../services/booking_repository.dart';
import '../../widgets/peer_ui.dart';
import '../../widgets/data_widgets.dart';
import '../../widgets/booking_workflow.dart';
import '../../models/peer_records.dart';

class ReviewModalScreen extends StatefulWidget {
  final String bookingId;
  const ReviewModalScreen({super.key, this.bookingId = ''});
  @override
  State<ReviewModalScreen> createState() => _ReviewModalScreenState();
}

class _ReviewModalScreenState extends State<ReviewModalScreen> {
  int rating = 5;
  final selected = <String>{};
  final controller = TextEditingController();
  @override
  void initState() {
    super.initState();
    final previous = AppData.instance.reviews
        .where((r) => r.id == widget.bookingId)
        .firstOrNull;
    if (previous != null) {
      rating = previous.rating.toInt();
      selected.addAll(previous.tags);
      controller.text = previous.comment;
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => DataView(builder: (context, data) {
        final booking = data.booking(widget.bookingId);
        if (booking == null || booking.status != 'completed') {
          return const PeerPage(title: 'Submit a Review', children: [
            Text(
                'Reviews are available after the tutor marks a session completed.')
          ]);
        }
        return PeerPage(title: 'Submit a Review', children: [
          PeerCard(children: [
            PeerCard(color: peerTint, children: [
              PeerPerson(name: booking.tutorName, subtitle: 'Peer Mentor'),
              PeerBadge(moduleLabel(booking.module)),
              const SizedBox(height: 14),
              PeerInfo(Icons.event, bookingDate(booking),
                  '${bookingTime(booking)} • ${booking.venue}')
            ]),
            const Text('How was your peer study session?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            const Text(
                'Your honest review helps maintain a supportive learning community across SLIIT campuses.',
                textAlign: TextAlign.center,
                style: TextStyle(height: 1.6)),
            const SizedBox(height: 24),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              for (int i = 1; i <= 5; i++)
                Flexible(
                    child: IconButton(
                        tooltip: '$i stars',
                        onPressed: () => setState(() => rating = i),
                        icon: Icon(
                            i <= rating ? Icons.star : Icons.star_outline,
                            color: const Color(0xFFA84800),
                            size: 34)))
            ]),
            Center(
                child: PeerBadge(
                    '${[
                      '',
                      'Needs Improvement',
                      'Could Be Better',
                      'Good Peer Support',
                      'Great Guidance',
                      'Exceptional Peer Guidance!'
                    ][rating]} ($rating/5)',
                    color: const Color(0xFF743800),
                    background: const Color(0xFFFFDCC8))),
            const SizedBox(height: 24),
            const Text('What stood out the most? (Select all that apply)'),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 6, children: [
              for (final label in [
                'Clear Explanations',
                'Patient & Helpful',
                'Strong Module Knowledge',
                'Great Exam Tips',
                'On Time'
              ])
                FilterChip(
                    label: Text(label),
                    selected: selected.contains(label),
                    onSelected: (v) => setState(() {
                          v ? selected.add(label) : selected.remove(label);
                        }))
            ]),
            const SizedBox(height: 20),
            const PeerTitle('Share your experience'),
            const Text('Optional • Visible to signed-in SLIIT peers',
                style: TextStyle(fontSize: 12)),
            const SizedBox(height: 10),
            TextField(
                controller: controller,
                maxLength: 300,
                maxLines: 5,
                decoration: InputDecoration(
                    hintText: 'Share what helped you learn…',
                    filled: true,
                    fillColor: peerTint,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none))),
            const PeerFreeNote(),
            AsyncPeerButton(
                data.reviews.any((r) => r.id == booking.id)
                    ? 'Update Peer Review'
                    : 'Submit Peer Review',
                icon: Icons.send_outlined, action: () async {
              await BookingRepository(data).saveReview(
                  booking, rating.toDouble(), controller.text, selected);
              if (context.mounted) {
                Navigator.pop(context);
                peerNotice(context, 'Your peer review was saved.');
              }
            }),
            if (data.reviews.any((r) => r.id == booking.id))
              AsyncPeerButton('Delete My Review', secondary: true,
                  action: () async {
                await BookingRepository(data).deleteReview(booking.id);
                if (context.mounted) Navigator.pop(context);
              }),
          ])
        ]);
      });
}
