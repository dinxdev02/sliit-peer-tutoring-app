import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/booking_repository.dart';
import '../../models/peer_records.dart';
import '../../widgets/peer_ui.dart';
import '../../widgets/data_widgets.dart';

class AvailabilityCalendarScreen extends StatefulWidget {
  const AvailabilityCalendarScreen({super.key});
  @override
  State<AvailabilityCalendarScreen> createState() =>
      _AvailabilityCalendarScreenState();
}

class _AvailabilityCalendarScreenState
    extends State<AvailabilityCalendarScreen> {
  DateTime week =
      DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));
  Set<int> selected = {};
  bool dirty = false;
  String mode = 'Campus';
  final venue = TextEditingController(text: 'SLIIT Malabe Library');
  static const hours = [8, 10, 13, 15, 17];
  DateTime start(int row, int day) {
    final d =
        DateTime(week.year, week.month, week.day).add(Duration(days: day));
    return DateTime(d.year, d.month, d.day, hours[row], row < 2 ? 30 : 0);
  }

  void changeWeek(int direction) => setState(() {
        week = week.add(Duration(days: direction * 7));
        dirty = false;
        selected = {};
      });
  @override
  void dispose() {
    venue.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => DataView(builder: (context, data) {
        final existing = <int, PeerSlot>{};
        for (int r = 0; r < 5; r++) {
          for (int d = 0; d < 7; d++) {
            for (final slot in data.slots.where((s) =>
                s.tutorId == data.uid &&
                s.start.isAtSameMomentAs(start(r, d)))) {
              existing[r * 7 + d] = slot;
            }
          }
        }
        if (!dirty) selected = existing.keys.toSet();
        return PeerPage(title: 'Tutor Availability Calendar', children: [
          PeerCard(children: [
            PeerPerson(
                name: data.name,
                subtitle:
                    '${data.profile?['year'] ?? ''} • ${data.profile?['program'] ?? ''}'),
            const PeerBadge('Peer Program')
          ]),
          const PeerCard(children: [
            PeerTitle('Set Your Weekly Availability', icon: Icons.schedule),
            Text(
                'Choose free hours for peer study sessions at SLIIT Library or online via MS Teams. Reserved slots cannot be removed until their booking is cancelled.',
                style: TextStyle(height: 1.6)),
            SizedBox(height: 14),
            Wrap(spacing: 8, runSpacing: 8, children: [
              PeerBadge('● Available for Tutoring',
                  color: peerGreen, background: Color(0xFFDCFDF6)),
              PeerBadge('● Busy / Unavailable')
            ])
          ]),
          PeerCard(children: [
            Row(children: [
              IconButton(
                  onPressed: () => changeWeek(-1),
                  icon: const Icon(Icons.chevron_left)),
              Expanded(
                  child: Text(
                      'Week of ${DateFormat('MMM d').format(week)} – ${DateFormat('MMM d').format(week.add(const Duration(days: 6)))}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.w700))),
              IconButton(
                  onPressed: () => changeWeek(1),
                  icon: const Icon(Icons.chevron_right))
            ]),
            PeerButton('Select Weekday Afternoons',
                secondary: true,
                onPressed: () => setState(() {
                      dirty = true;
                      for (int r = 2; r < 5; r++) {
                        for (int d = 0; d < 5; d++) {
                          if (start(r, d).isAfter(DateTime.now())) {
                            selected.add(r * 7 + d);
                          }
                        }
                      }
                    })),
            TextButton(
                onPressed: () => setState(() {
                      dirty = true;
                      selected = existing.entries
                          .where((e) => e.value.bookingId != null)
                          .map((e) => e.key)
                          .toSet();
                    }),
                child: const Text('Clear All'))
          ]),
          PeerCard(children: [
            SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Column(children: [
                  Row(children: [
                    const SizedBox(width: 60, child: Text('Time')),
                    for (int d = 0; d < 7; d++)
                      cell(
                          Text(
                              DateFormat('d\nEEE')
                                  .format(week.add(Duration(days: d))),
                              textAlign: TextAlign.center),
                          peerTint)
                  ]),
                  for (int r = 0; r < 5; r++)
                    Row(children: [
                      SizedBox(
                          width: 60,
                          child: Text(DateFormat('HH:mm').format(start(r, 0)),
                              style: const TextStyle(fontSize: 12))),
                      for (int d = 0; d < 7; d++)
                        Semantics(
                            button: true,
                            label:
                                '${DateFormat('EEEE').format(start(r, d))} ${DateFormat.jm().format(start(r, d))}',
                            child: InkWell(
                                onTap: !data.isTutor ||
                                        !start(r, d).isAfter(DateTime.now()) ||
                                        existing[r * 7 + d]?.bookingId != null
                                    ? null
                                    : () => setState(() {
                                          dirty = true;
                                          selected.contains(r * 7 + d)
                                              ? selected.remove(r * 7 + d)
                                              : selected.add(r * 7 + d);
                                        }),
                                child: cell(
                                    Text(
                                        existing[r * 7 + d]?.bookingId != null
                                            ? 'Booked'
                                            : selected.contains(r * 7 + d)
                                                ? '✓\nOpen'
                                                : 'Busy',
                                        textAlign: TextAlign.center),
                                    selected.contains(r * 7 + d)
                                        ? peerMint
                                        : const Color(0xFFE4EDFF))))
                    ]),
                ]))
          ]),
          PeerCard(children: [
            const PeerTitle('Designated Study Spots',
                icon: Icons.location_on_outlined),
            DropdownButtonFormField<String>(
                initialValue: mode,
                decoration: const InputDecoration(labelText: 'Study mode'),
                items: ['Campus', 'Online']
                    .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                    .toList(),
                onChanged: (v) => setState(() {
                      mode = v!;
                    })),
            TextField(
                controller: venue,
                decoration:
                    const InputDecoration(labelText: 'Study venue / room'))
          ]),
          PeerCard(children: [
            PeerTitle('${selected.length} Slots Open'),
            Text(
                '${(selected.length * 1.5).toStringAsFixed(1)} hrs/week volunteer tutoring'),
            AsyncPeerButton('Save Weekly Availability',
                icon: Icons.save_outlined,
                action: !data.isTutor
                    ? null
                    : () async {
                        await BookingRepository(data)
                            .saveAvailability(week, selected, mode, venue.text);
                        if (context.mounted) {
                          setState(() => dirty = false);
                          peerNotice(context, 'Weekly availability saved.');
                        }
                      })
          ]),
        ]);
      });
  Widget cell(Widget child, Color color) => Container(
      width: 68,
      height: 62,
      margin: const EdgeInsets.all(3),
      alignment: Alignment.center,
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
      child: child);
}
