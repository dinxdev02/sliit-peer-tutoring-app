import 'package:flutter/material.dart';
import '../../models/peer_records.dart';
import '../../widgets/peer_ui.dart';
import '../../widgets/data_widgets.dart';
import '../../widgets/booking_workflow.dart';
import 'student_schedule_screen.dart';

class BookingConfirmationScreen extends StatelessWidget {
  final String bookingId;
  const BookingConfirmationScreen({super.key, this.bookingId = ''});
  @override
  Widget build(BuildContext context) => DataView(builder: (context, data) {
        final booking = data.booking(bookingId);
        if (booking == null) {
          return const PeerPage(
              title: 'Study Session Request',
              children: [Text('Loading your booking…')]);
        }
        return Scaffold(
            backgroundColor: const Color(0xFF222B3D),
            body: SafeArea(
                child: ListView(padding: const EdgeInsets.all(20), children: [
              PeerCard(children: [
                Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close))),
                const Center(
                    child: CircleAvatar(
                        radius: 35,
                        backgroundColor: Color(0xFF009B72),
                        child:
                            Icon(Icons.check, color: Colors.white, size: 42))),
                const SizedBox(height: 24),
                const Center(
                    child: Text('Study Session Requested!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 27, fontWeight: FontWeight.w800))),
                const SizedBox(height: 12),
                Text(
                    "Request sent — you'll be notified once ${booking.tutorName} accepts.",
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, height: 1.5)),
                const SizedBox(height: 20),
                PeerCard(color: peerTint, children: [
                  PeerPerson(
                      name: booking.tutorName,
                      subtitle: 'Verified Peer Mentor'),
                  PeerInfo(
                      Icons.menu_book_outlined,
                      moduleLabel(booking.module),
                      '1-on-1 Exam & Assignment Guidance'),
                  PeerInfo(Icons.event, bookingDate(booking),
                      '${bookingTime(booking)} • ${booking.end.difference(booking.start).inMinutes} mins'),
                  PeerInfo(
                      Icons.location_on_outlined, booking.venue, booking.mode),
                  PeerBadge(booking.status.toUpperCase())
                ]),
                const PeerCard(color: peerTint, children: [
                  PeerInfo(
                      Icons.info_outline,
                      'Prepare your questions, wireframe or lecture slides before joining.',
                      '')
                ]),
                PeerButton('View My Bookings',
                    icon: Icons.arrow_forward,
                    onPressed: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute<void>(
                            builder: (_) => const StudentScheduleScreen()))),
                Center(
                    child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Back to Tutor Profile'))),
              ]),
              const Text('SLIIT Peer Learning Network • Malabe Campus',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white60))
            ])));
      });
}
