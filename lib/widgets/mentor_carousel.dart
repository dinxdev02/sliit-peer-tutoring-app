import 'package:flutter/material.dart';
import '../models/peer_records.dart';
import '../services/app_data.dart';
import '../screens/discovery/tutor_profile_detail_screen.dart';
import 'brand_widgets.dart';
import 'peer_ui.dart';

class MentorCarousel extends StatefulWidget {
  final List<PeerTutor> tutors;
  final AppData data;
  const MentorCarousel({super.key, required this.tutors, required this.data});
  @override
  State<MentorCarousel> createState() => _MentorCarouselState();
}

class _MentorCarouselState extends State<MentorCarousel> {
  final scroll = ScrollController();
  @override
  void dispose() { scroll.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 3.0);
    final height = 340.0 * scale;
    return SizedBox(height: height + 28, child: LayoutBuilder(builder: (context, constraints) {
      return SingleChildScrollView(
        controller: scroll, scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          for (int i = 0; i < widget.tutors.length; i++)
            AnimatedBuilder(animation: scroll, builder: (context, child) {
              final offset = scroll.hasClients ? scroll.offset : 0.0;
              final distance = (i * 252 + 120 - offset - constraints.maxWidth / 2).abs();
              final focus = MediaQuery.disableAnimationsOf(context)
                  ? 1.0 : (1 - distance / 252).clamp(0.0, 1.0);
              return Transform.translate(offset: Offset(0, (1 - focus) * 8),
                child: Transform.scale(scale: .96 + focus * .04, child: child));
            }, child: Padding(padding: const EdgeInsets.only(right: 12),
              child: SizedBox(width: 240, height: height,
                child: _card(widget.tutors[i], scale)))),
        ]),
      );
    }));
  }

  Widget _card(PeerTutor tutor, double scale) {
    final rating = widget.data.rating(tutor.id);
    return Container(
      key: ValueKey('mentor-card-${tutor.id}'),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [BoxShadow(color: Color(0x100F172A), blurRadius: 8, offset: Offset(0, 3))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          UserAvatar(initials: tutor.name.trim().split(RegExp(r'\s+')).take(2).map((s) => s[0]).join(), radius: 22),
          const SizedBox(width: 10),
          Expanded(child: SizedBox(height: 48 * scale,
            child: Align(alignment: Alignment.centerLeft, child: Text(tutor.name,
              maxLines: 2, overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700))))),
        ]),
        const SizedBox(height: 8),
        const PeerBadge('Verified Peer Mentor'),
        const SizedBox(height: 8),
        SizedBox(height: 40 * scale, child: Text('${tutor.year} • ${tutor.program}',
          maxLines: 2, overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: AppColors.textMuted))),
        Text(rating == 0 ? 'New Peer Mentor' : '★ ${rating.toStringAsFixed(1)}'),
        const SizedBox(height: 10),
        Wrap(spacing: 4, runSpacing: 4, children: tutor.modules.take(2).map((m) => PeerBadge(m)).toList()),
        const Spacer(),
        Text('${widget.data.openSlots(tutor.id).length} open slots', style: const TextStyle(color: AppColors.textMuted)),
        PeerButton('Connect Free', onPressed: () => openPeerScreen(context, TutorProfileDetailScreen(tutorId: tutor.id))),
      ]),
    );
  }
}
