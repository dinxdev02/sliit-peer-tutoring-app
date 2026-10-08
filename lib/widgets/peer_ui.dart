import 'package:flutter/material.dart';
import 'brand_widgets.dart';

const peerBlue = Color(0xFF233E8B);
const peerTint = Color(0xFFEEF3FF);
const peerGreen = Color(0xFF004D46);
const peerMint = Color(0xFF8CF1E4);

void openPeerScreen(BuildContext context, Widget screen) {
  Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
}

void peerNotice(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

class PeerPage extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final Widget? bottom;
  final List<Widget>? actions;
  const PeerPage(
      {super.key,
      required this.title,
      required this.children,
      this.bottom,
      this.actions});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xFFF7F8FF),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF7F8FF),
          surfaceTintColor: Colors.transparent,
          titleSpacing: 16,
          title: Row(children: [
            Expanded(
                child: Text(title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w700))),
          ]),
          actions: actions,
        ),
        body: SafeArea(
            child: ListView(
                padding: const EdgeInsets.all(16), children: children)),
        bottomNavigationBar: bottom,
      );
}

class PeerCard extends StatelessWidget {
  final List<Widget> children;
  final Color color;
  const PeerCard(
      {super.key, required this.children, this.color = Colors.white});
  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x070F172A), blurRadius: 3, offset: Offset(0, 2))
            ]),
        child: Material(
            type: MaterialType.transparency,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children)),
      );
}

class PeerTitle extends StatelessWidget {
  final String text;
  final IconData? icon;
  const PeerTitle(this.text, {super.key, this.icon});
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(children: [
        if (icon != null) ...[
          Icon(icon, color: peerBlue, size: 23),
          const SizedBox(width: 8)
        ],
        Expanded(
            child: Text(text,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark))),
      ]));
}

class PeerBadge extends StatelessWidget {
  final String text;
  final Color color, background;
  const PeerBadge(this.text,
      {super.key, this.color = peerBlue, this.background = peerTint});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
            color: background, borderRadius: BorderRadius.circular(20)),
        child: Text(text,
            style: TextStyle(
                color: color, fontWeight: FontWeight.w600, fontSize: 12)),
      );
}

class PeerButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool secondary, orange;
  const PeerButton(this.label,
      {super.key,
      this.icon,
      required this.onPressed,
      this.secondary = false,
      this.orange = false});
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(top: 8),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton(
            onPressed: onPressed,
            style: FilledButton.styleFrom(
                minimumSize: const Size(0, 48),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                backgroundColor: secondary
                    ? const Color(0xFFE3EDFF)
                    : orange
                        ? AppColors.accentOrange
                        : peerBlue,
                foregroundColor: secondary ? peerBlue : Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12))),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              if (icon != null) ...[
                Icon(icon, size: 20),
                const SizedBox(width: 8)
              ],
              Flexible(
                  child: Text(label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15))),
            ])),
      ));
}

class PeerInfo extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  const PeerInfo(this.icon, this.title, this.subtitle, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: const Color(0xFFE3EDFF),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: peerBlue, size: 22)),
        const SizedBox(width: 12),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(subtitle,
                style: const TextStyle(color: AppColors.textMuted, height: 1.4))
          ],
        ])),
      ]));
}

class PeerPerson extends StatelessWidget {
  final String name, subtitle;
  const PeerPerson(
      {super.key,
      this.name = 'Kavindu Jayasuriya',
      this.subtitle = 'Year 3 • Faculty of Computing'});
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(children: [
        UserAvatar(
            initials: name.split(' ').map((s) => s[0]).take(2).join(),
            radius: 27,
            statusColor: peerMint),
        const SizedBox(width: 12),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name,
              style:
                  const TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
          const SizedBox(height: 5),
          const PeerBadge('SLIIT Verified Peer Mentor'),
          const SizedBox(height: 5),
          Text(subtitle,
              style: const TextStyle(color: AppColors.textMuted, height: 1.4)),
        ])),
      ]));
}

class PeerFreeNote extends StatelessWidget {
  const PeerFreeNote({super.key});
  @override
  Widget build(BuildContext context) =>
      const PeerCard(color: peerTint, children: [
        PeerInfo(
            Icons.volunteer_activism_outlined,
            '100% Free Campus Collaboration',
            'SLIIT Peer Tutoring is powered by student volunteers. No fees or payments are ever exchanged.'),
      ]);
}
