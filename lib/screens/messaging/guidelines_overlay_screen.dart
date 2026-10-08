import 'package:flutter/material.dart';
import '../../widgets/peer_ui.dart';
import '../../widgets/data_widgets.dart';
import '../../services/app_data.dart';

/// Owned by: Sandavinna — FR4, FR6, FR7
class GuidelinesOverlayScreen extends StatelessWidget {
  const GuidelinesOverlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PeerPage(title: 'Peer Guidelines', children: [
      const PeerCard(children: [
        PeerTitle('Support each other’s learning'),
        PeerInfo(Icons.school_outlined, 'Learn concepts together',
            'Discuss methods and examples. Complete your own graded work.'),
        PeerInfo(Icons.schedule, 'Respect your peer’s time',
            'Arrive on time and give advance notice if your plans change.'),
        PeerInfo(Icons.shield_outlined, 'Keep the community safe',
            'Be respectful. Report misconduct through the session chat.')
      ]),
      const PeerFreeNote(),
      AsyncPeerButton('Acknowledge Peer Guidelines',
          action: AppData.instance.signedIn
              ? () async {
                  await AppData.instance.acknowledgeGuidelines();
                  if (context.mounted) {
                    peerNotice(context, 'Your acknowledgement has been saved.');
                  }
                }
              : null),
    ]);
  }
}
