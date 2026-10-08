import 'package:flutter/material.dart';
import '../../widgets/brand_widgets.dart';
import 'role_selection_screen.dart';

/// Welcome / Onboarding Landing Screen
/// "Free peer tutoring, by SLIIT students, for SLIIT students."
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              const SizedBox(height: 10),

              // Top Logo Box
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x08000000),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppColors.primaryNavy,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Icon(
                            Icons.school_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                          Positioned(
                            right: 2,
                            top: 2,
                            child: Container(
                              width: 4,
                              height: 4,
                              decoration: const BoxDecoration(
                                color: AppColors.accentOrange,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    RichText(
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: 'SLIIT',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primaryNavy,
                            ),
                          ),
                          TextSpan(
                            text: 'Peer',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: AppColors.accentOrange,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 1),

              // Hero Illustration: Two Students Studying with Open Book
              _buildStudyIllustration(),

              const Spacer(flex: 1),

              // 100% Student-Led & Free Pill
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.lightBlueBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.lightBlueBorder),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.verified_user_rounded,
                      color: AppColors.primaryNavy,
                      size: 15,
                    ),
                    SizedBox(width: 6),
                    Text(
                      '100% Student-Led & Free',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryNavy,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Main Headline
              const Text(
                'Free peer tutoring, by SLIIT students, for SLIIT students.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryNavy,
                  letterSpacing: -0.6,
                  height: 1.25,
                ),
              ),

              const SizedBox(height: 12),

              // Subtitle
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Connect with verified peer tutors for your modules — no cost, ever.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.5,
                    color: AppColors.textMuted,
                    height: 1.35,
                  ),
                ),
              ),

              const Spacer(flex: 2),

              // Get Started Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryNavy,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RoleSelectionScreen(),
                      ),
                    );
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Get Started',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded, size: 18),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Footer Note
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.school_outlined,
                    color: AppColors.textMuted,
                    size: 16,
                  ),
                  SizedBox(width: 6),
                  Flexible(
                      child: Text(
                    'Sign in with your standard @my.sliit.lk credentials',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  )),
                ],
              ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStudyIllustration() {
    return Center(
      child: Container(
        width: 250,
        height: 250,
        decoration: const BoxDecoration(
          color: Color(0xFFF1F5F9),
          shape: BoxShape.circle,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Inner soft tint circle
            Container(
              width: 220,
              height: 220,
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                shape: BoxShape.circle,
              ),
            ),

            // Floating stars / sparkles
            const Positioned(
              top: 55,
              left: 48,
              child: Icon(Icons.star, color: Color(0xFFF59E0B), size: 13),
            ),
            const Positioned(
              top: 55,
              right: 48,
              child: Icon(Icons.star, color: Color(0xFFF59E0B), size: 13),
            ),

            // Speech bubble with graduation cap
            Positioned(
              top: 42,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryNavy,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.school_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),

            // Two Student Avatars Reading Together
            Positioned(
              bottom: 40,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Student 1 (Left, Dark Blue Body)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          color: Color(0xFF3B82F6),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 62,
                        height: 44,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryNavy,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(22),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Open Book in the Middle
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x10000000),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.menu_book_rounded,
                          color: AppColors.accentOrange,
                          size: 26,
                        ),
                      ],
                    ),
                  ),

                  // Student 2 (Right, Bright Blue Body)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          color: Color(0xFF60A5FA),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 62,
                        height: 44,
                        decoration: const BoxDecoration(
                          color: Color(0xFF2563EB),
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(22),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
