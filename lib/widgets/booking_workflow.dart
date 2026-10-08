import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/peer_records.dart';
import '../services/app_data.dart';
import '../services/booking_repository.dart';
import '../screens/booking/booking_confirmation_screen.dart';
import 'peer_ui.dart';
import 'data_widgets.dart';

String slotLabel(PeerSlot slot) =>
    '${DateFormat('EEE, MMM d').format(slot.start)} • ${DateFormat.jm().format(slot.start)} – ${DateFormat.jm().format(slot.end)}';
String bookingDate(PeerBooking booking) =>
    DateFormat('EEEE, MMM d, y').format(booking.start);
String bookingTime(PeerBooking booking) =>
    '${DateFormat.jm().format(booking.start)} – ${DateFormat.jm().format(booking.end)}';

Future<void> requestStudySession(BuildContext context, PeerTutor tutor) async {
  final data = AppData.instance;
  if (data.profile?['guidelinesAccepted'] != true) {
    final accepted = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
                title: const Text('Academic integrity guidelines'),
                content: const Text(
                    'Peer tutoring supports learning and concept mastery. Complete your own graded work. Sessions are free; respect your peer and their time.'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel')),
                  FilledButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('I agree'))
                ]));
    if (accepted != true || !context.mounted) return;
    if (!await perform(context, data.acknowledgeGuidelines) ||
        !context.mounted) {
      return;
    }
  }
  final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _RequestSheet(tutor: tutor));
  if (result != null && context.mounted) {
    openPeerScreen(context, BookingConfirmationScreen(bookingId: result));
  }
}

class _RequestSheet extends StatefulWidget {
  final PeerTutor tutor;
  const _RequestSheet({required this.tutor});
  @override
  State<_RequestSheet> createState() => _RequestSheetState();
}

class _RequestSheetState extends State<_RequestSheet> {
  late String module = widget.tutor.modules.first;
  String? slotId;
  final notes = TextEditingController();
  @override
  void dispose() {
    notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Material(
      color: Colors.white,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: SafeArea(
          child: Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.viewInsetsOf(context).bottom),
              child: SizedBox(
                  height: MediaQuery.sizeOf(context).height * .75,
                  child: ListenableBuilder(
                      listenable: AppData.instance,
                      builder: (context, _) {
                        final slots =
                            AppData.instance.openSlots(widget.tutor.id);
                        return ListView(
                            padding: const EdgeInsets.all(20),
                            children: [
                              Row(children: [
                                const Expanded(
                                    child: PeerTitle(
                                        'Request Free Study Session')),
                                IconButton(
                                    onPressed: () => Navigator.pop(context),
                                    icon: const Icon(Icons.close))
                              ]),
                              PeerPerson(
                                  name: widget.tutor.name,
                                  subtitle:
                                      '${widget.tutor.year} • ${widget.tutor.program}'),
                              DropdownButtonFormField<String>(
                                  initialValue: module,
                                  isExpanded: true,
                                  items: widget.tutor.modules
                                      .map((m) => DropdownMenuItem(
                                          value: m,
                                          child: Text(moduleLabel(m))))
                                      .toList(),
                                  onChanged: (v) => setState(() => module = v!),
                                  decoration: const InputDecoration(
                                      labelText: 'Module')),
                              const SizedBox(height: 16),
                              const PeerTitle('Choose an available slot'),
                              if (slots.isEmpty)
                                const Text(
                                    'No future slots are available. Please check back later.'),
                              for (final slot in slots)
                                ListTile(
                                    selected: slotId == slot.id,
                                    selectedTileColor: peerTint,
                                    leading: Icon(
                                        slotId == slot.id
                                            ? Icons.radio_button_checked
                                            : Icons.radio_button_off,
                                        color: peerBlue),
                                    title: Text(slotLabel(slot)),
                                    subtitle:
                                        Text('${slot.mode} • ${slot.venue}'),
                                    onTap: () =>
                                        setState(() => slotId = slot.id)),
                              TextField(
                                  controller: notes,
                                  maxLength: 500,
                                  maxLines: 3,
                                  decoration: const InputDecoration(
                                      labelText:
                                          'What would you like help with? (Optional)')),
                              AsyncPeerButton('Send Free Session Request',
                                  action: slotId == null
                                      ? null
                                      : () async {
                                          final selected = slots
                                              .where((s) => s.id == slotId)
                                              .firstOrNull;
                                          if (selected == null) {
                                            throw StateError(
                                                'This slot is no longer available. Select another time.');
                                          }
                                          final id = await BookingRepository(
                                                  AppData.instance)
                                              .request(widget.tutor, selected,
                                                  module, notes.text);
                                          if (context.mounted) {
                                            Navigator.pop(context, id);
                                          }
                                        }),
                            ]);
                      })))));
}
