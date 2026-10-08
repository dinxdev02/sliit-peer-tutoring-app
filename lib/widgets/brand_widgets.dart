import 'package:flutter/material.dart';

/// App theme constants matching the SLIIT Peer UI designs
class AppColors {
  static const Color primaryNavy = Color(0xFF1E3A8A);
  static const Color accentOrange = Color(0xFFF97316);
  static const Color darkOrange = Color(0xFFEA580C);
  static const Color background = Color(0xFFF8FAFC);
  static const Color cardBg = Colors.white;
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderSubtle = Color(0xFFEDF2F7);

  // Soft tint backgrounds
  static const Color lightBlueBg = Color(0xFFEFF6FF);
  static const Color lightBlueBorder = Color(0xFFDBEAFE);
  static const Color lightOrangeBg = Color(0xFFFFF7ED);
  static const Color lightOrangeBorder = Color(0xFFFFEDD5);

  // Text colors
  static const Color textDark = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textLight = Color(0xFF94A3B8);
}

/// Official SLIIT Peer logo header
class SliitPeerLogo extends StatelessWidget {
  final double fontSize;
  final bool showBadge;

  const SliitPeerLogo({
    super.key,
    this.fontSize = 24,
    this.showBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (showBadge) ...[
          Container(
            padding: const EdgeInsets.all(5),
            margin: const EdgeInsets.only(right: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryNavy,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.school, color: Colors.white, size: 14),
          ),
        ],
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'SLIIT ',
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryNavy,
                  letterSpacing: -0.5,
                ),
              ),
              TextSpan(
                text: 'Peer',
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w900,
                  color: AppColors.accentOrange,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Reusable user avatar with status badge
class UserAvatar extends StatelessWidget {
  final String initials;
  final double radius;
  final Color? statusColor;
  final String? imageUrl;

  const UserAvatar({
    super.key,
    this.initials = 'KP',
    this.radius = 18,
    this.statusColor,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        CircleAvatar(
          radius: radius,
          backgroundColor: const Color(0xFFE2E8F0),
          child: CircleAvatar(
            radius: radius - 1.5,
            backgroundColor: const Color(0xFF64748B),
            child: Text(
              initials,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: radius * 0.75,
              ),
            ),
          ),
        ),
        if (statusColor != null)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: radius * 0.55,
              height: radius * 0.55,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
      ],
    );
  }
}
