import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/app_data.dart';
import '../../services/upload_service.dart';
import '../../services/backend_config.dart';
import '../../models/peer_records.dart';
import '../../widgets/peer_ui.dart';
import '../../widgets/data_widgets.dart';
import '../../widgets/booking_workflow.dart';
import 'report_misuse_screen.dart';
import '../booking/booking_details_screen.dart';

class ChatScreen extends StatefulWidget {
  final String chatId, peerName;
  final String? bookingId;
  const ChatScreen(
      {super.key, this.chatId = '', this.peerName = 'Peer', this.bookingId});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final composer = TextEditingController();
  bool sending = false;
  @override
  void dispose() {
    composer.dispose();
    super.dispose();
  }

  Future<void> send() async {
    if (sending || composer.text.trim().isEmpty) return;
    setState(() => sending = true);
    final text = composer.text;
    final ok = await perform(
        context, () => AppData.instance.sendMessage(widget.chatId, text));
    if (mounted) {
      setState(() => sending = false);
      if (ok) composer.clear();
    }
  }

  @override
  Widget build(BuildContext context) => DataView(builder: (context, data) {
        final booking =
            widget.bookingId == null ? null : data.booking(widget.bookingId!);
        return Scaffold(
            backgroundColor: const Color(0xFFF7F8FF),
            appBar: AppBar(
                title: Text(widget.peerName,
                    style: const TextStyle(
                        fontSize: 19, fontWeight: FontWeight.w700)),
                actions: [
                  if (booking != null)
                    IconButton(
                        tooltip: 'Report session issue',
                        onPressed: () => openPeerScreen(
                            context, ReportMisuseScreen(bookingId: booking.id)),
                        icon: const Icon(Icons.flag_outlined))
                ]),
            body: Column(children: [
              if (booking != null)
                Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: PeerCard(children: [
                      Row(children: [
                        Expanded(child: PeerBadge(moduleLabel(booking.module))),
                        IconButton(
                            tooltip: 'Booking Details',
                            onPressed: () => openPeerScreen(context,
                                BookingDetailsScreen(bookingId: booking.id)),
                            icon: const Icon(Icons.info_outline))
                      ]),
                      Text('${bookingDate(booking)} • ${bookingTime(booking)}'),
                      Text(booking.venue),
                      const PeerBadge('100% Free Peer Study • No Fees')
                    ])),
              const Padding(
                  padding: EdgeInsets.all(8),
                  child: Text(
                      'Support learning and concept mastery. Complete your own graded work.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12))),
              Expanded(
                  child: widget.chatId.isEmpty || data.db == null
                      ? const Center(
                          child:
                              Text('Choose a peer conversation from Messages.'))
                      : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                          stream: data.messages(widget.chatId),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Center(
                                  child: Text(dataError(snapshot.error!)));
                            }
                            if (!snapshot.hasData) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            final docs = snapshot.data!.docs.reversed.toList();
                            if (docs.isEmpty) {
                              return const Center(
                                  child: Text('Start your peer conversation.'));
                            }
                            return ListView.builder(
                                reverse: true,
                                padding: const EdgeInsets.all(16),
                                itemCount: docs.length,
                                itemBuilder: (context, index) {
                                  final message = docs[index].data();
                                  final own = message['senderId'] == data.uid;
                                  final attachment = message['attachment']
                                      as Map<String, dynamic>?;
                                  return Align(
                                      alignment: own
                                          ? Alignment.centerRight
                                          : Alignment.centerLeft,
                                      child: FractionallySizedBox(
                                          widthFactor: .88,
                                          child: Container(
                                              margin: const EdgeInsets.only(
                                                  bottom: 12),
                                              padding: const EdgeInsets.all(16),
                                              decoration: BoxDecoration(
                                                  color: own
                                                      ? peerBlue
                                                      : Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          18)),
                                              child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(message['text'] ?? '',
                                                        style: TextStyle(
                                                            color: own
                                                                ? Colors.white
                                                                : const Color(
                                                                    0xFF17263A),
                                                            height: 1.6)),
                                                    if (attachment != null)
                                                      TextButton(
                                                          onPressed: () => perform(
                                                              context,
                                                              () => UploadService
                                                                  .open(
                                                                      attachment)),
                                                          child: Text(
                                                              '📄 ${attachment['name']}',
                                                              style: TextStyle(
                                                                  color: own
                                                                      ? Colors
                                                                          .white
                                                                      : peerBlue))),
                                                    const SizedBox(height: 8),
                                                    Text(
                                                        message['createdAt'] ==
                                                                null
                                                            ? 'Sending…'
                                                            : TimeOfDay.fromDateTime(
                                                                    recordDate(
                                                                        message[
                                                                            'createdAt']))
                                                                .format(
                                                                    context),
                                                        style: TextStyle(
                                                            color: own
                                                                ? Colors.white60
                                                                : Colors.grey,
                                                            fontSize: 11)),
                                                    if (own)
                                                      IconButton(
                                                          tooltip:
                                                              'Delete message',
                                                          icon: Icon(
                                                              Icons
                                                                  .delete_outline,
                                                              size: 16,
                                                              color: own
                                                                  ? Colors
                                                                      .white60
                                                                  : Colors
                                                                      .grey),
                                                          onPressed: () => perform(
                                                              context,
                                                              () => data.db!
                                                                  .collection(
                                                                      'chats')
                                                                  .doc(widget
                                                                      .chatId)
                                                                  .collection(
                                                                      'messages')
                                                                  .doc(docs[
                                                                          index]
                                                                      .id)
                                                                  .delete())),
                                                  ]))));
                                });
                          })),
              SafeArea(
                  top: false,
                  child: Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(12),
                      child: Row(children: [
                        if (BackendConfig.uploadsEnabled)
                          IconButton(
                              tooltip: 'Attach file',
                              onPressed: widget.chatId.isEmpty
                                  ? null
                                  : () => perform(context, () async {
                                        final file = await UploadService.pick();
                                        if (file == null) return;
                                        final attachment =
                                            await UploadService.upload(
                                                file, 'chats/${widget.chatId}');
                                        await data.sendMessage(
                                            widget.chatId, '',
                                            attachment: attachment);
                                      }),
                              icon: const Icon(Icons.attach_file)),
                        Expanded(
                            child: TextField(
                                controller: composer,
                                minLines: 1,
                                maxLines: 4,
                                onSubmitted: (_) => send(),
                                decoration: InputDecoration(
                                    hintText: 'Type a study message',
                                    filled: true,
                                    fillColor: peerTint,
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(14),
                                        borderSide: BorderSide.none)))),
                        IconButton.filled(
                            style: IconButton.styleFrom(
                                backgroundColor: const Color(0xFFF97316)),
                            onPressed:
                                sending || widget.chatId.isEmpty ? null : send,
                            icon: const Icon(Icons.send_outlined)),
                      ]))),
            ]));
      });
}
