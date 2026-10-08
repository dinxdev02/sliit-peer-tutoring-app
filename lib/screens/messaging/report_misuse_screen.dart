import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../services/booking_repository.dart';
import '../../services/upload_service.dart';
import '../../services/backend_config.dart';
import '../../widgets/peer_ui.dart';
import '../../widgets/data_widgets.dart';
import '../../widgets/booking_workflow.dart';
import '../../models/peer_records.dart';

class ReportMisuseScreen extends StatefulWidget {
  final String bookingId;
  const ReportMisuseScreen({super.key, this.bookingId = ''});
  @override
  State<ReportMisuseScreen> createState() => _ReportMisuseScreenState();
}

class _ReportMisuseScreenState extends State<ReportMisuseScreen> {
  final controller = TextEditingController();
  final form = GlobalKey<FormState>();
  String reason = 'Academic dishonesty';
  bool confirmed = false;
  PlatformFile? file;
  Map<String, dynamic>? uploaded;
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => DataView(builder: (context, data) {
        final booking = data.booking(widget.bookingId);
        if (booking == null) {
          return PeerPage(title: 'Report Session Issue', children: [
            const PeerTitle('Choose a session to report'),
            for (final b in data.bookings)
              PeerButton('${moduleLabel(b.module)} • ${bookingDate(b)}',
                  secondary: true,
                  onPressed: () => openPeerScreen(
                      context, ReportMisuseScreen(bookingId: b.id))),
            if (data.bookings.isEmpty)
              const Text('You have no sessions to report.'),
          ]);
        }
        return PeerPage(title: 'Report Session Issue', children: [
          PeerCard(children: [
            Form(
                key: form,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const PeerTitle('Report Session Issue',
                          icon: Icons.report_outlined),
                      const Text('Community & Academic Integrity'),
                      const SizedBox(height: 18),
                      PeerCard(color: peerTint, children: [
                        PeerTitle('${booking.tutorName} • ${booking.module}'),
                        Text(
                            '${bookingDate(booking)} • ${bookingTime(booking)}'),
                        const SizedBox(height: 12),
                        const Text(
                            'Reports are confidential and visible only to you and authorized administrators.',
                            style: TextStyle(height: 1.5))
                      ]),
                      const PeerTitle('Reason for report *'),
                      DropdownButtonFormField<String>(
                          initialValue: reason,
                          isExpanded: true,
                          decoration: const InputDecoration(
                              filled: true,
                              fillColor: peerTint,
                              border: OutlineInputBorder(
                                  borderSide: BorderSide.none)),
                          items: [
                            'Academic dishonesty',
                            'Harassment or misconduct',
                            'Payment solicitation',
                            'Tutor did not attend',
                            'Other'
                          ]
                              .map((r) =>
                                  DropdownMenuItem(value: r, child: Text(r)))
                              .toList(),
                          onChanged: (v) => setState(() => reason = v!)),
                      const SizedBox(height: 8),
                      const PeerCard(color: peerTint, children: [
                        Text(
                            'Peer tutoring supports mutual concept mastery. Do not complete graded work for others.',
                            style: TextStyle(height: 1.5))
                      ]),
                      const PeerTitle('Please describe what happened *'),
                      TextFormField(
                          controller: controller,
                          maxLength: 500,
                          maxLines: 5,
                          validator: (v) => (v ?? '').trim().length < 10
                              ? 'Please provide at least 10 characters of detail.'
                              : null,
                          decoration: InputDecoration(
                              hintText:
                                  'Provide specific details and relevant timestamps…',
                              filled: true,
                              fillColor: peerTint,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide.none))),
                      if (BackendConfig.uploadsEnabled) ...[
                        const PeerTitle(
                            'Upload screenshot or excerpt (Optional)'),
                        PeerCard(color: peerTint, children: [
                          const Center(
                              child: Icon(Icons.add_photo_alternate_outlined,
                                  color: peerBlue, size: 40)),
                          AsyncPeerButton(
                              file?.name ?? 'Browse session log or screenshot',
                              secondary: true, action: () async {
                            final picked = await UploadService.pick();
                            if (picked != null && mounted) {
                              setState(() {
                                file = picked;
                                uploaded = null;
                              });
                            }
                          }),
                          const Center(
                              child: Text('PNG, JPG, PDF • Max 5 MB',
                                  style: TextStyle(color: Colors.grey)))
                        ]),
                      ],
                      CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity.leading,
                          value: confirmed,
                          onChanged: (v) => setState(() => confirmed = v!),
                          title: const Text(
                              'I confirm this report is accurate, honest, and submitted in accordance with the SLIIT Student Code of Conduct.',
                              style: TextStyle(fontSize: 14, height: 1.5))),
                      Row(children: [
                        Expanded(
                            child: PeerButton('Cancel',
                                secondary: true,
                                onPressed: () => Navigator.pop(context))),
                        const SizedBox(width: 8),
                        Expanded(
                            child: AsyncPeerButton('Submit Report',
                                icon: Icons.send_outlined,
                                action: confirmed
                                    ? () async {
                                        if (!form.currentState!.validate()) {
                                          return;
                                        }
                                        if (file != null && uploaded == null) {
                                          uploaded = await UploadService.upload(
                                              file!, 'reports/${data.uid}');
                                        }
                                        await BookingRepository(data).report(
                                            booking,
                                            reason,
                                            controller.text,
                                            uploaded);
                                        if (context.mounted) {
                                          Navigator.pop(context);
                                          peerNotice(
                                              context, 'Report submitted.');
                                        }
                                      }
                                    : null))
                      ]),
                    ]))
          ])
        ]);
      });
}
