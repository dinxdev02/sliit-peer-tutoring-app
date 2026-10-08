import 'package:flutter/material.dart';
import '../../widgets/brand_widgets.dart';
import 'login_screen.dart';
import 'registration_step1_screen.dart';

/// Role Selection Screen ("Join SLIIT Peer Tutoring")
/// Owned by: Rashmika — FR1
class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  // 'student' (tutee) or 'tutor'
  String _selectedRole = 'student';

  @override
  Widget build(BuildContext context) {
    final isStudent = _selectedRole == 'student';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 12),

              // Top Logo Box
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0A000000),
                      blurRadius: 16,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.primaryNavy,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Icon(
                            Icons.school_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                          Positioned(
                            right: 4,
                            top: 4,
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AppColors.accentOrange,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 5),
                    RichText(
                      textAlign: TextAlign.center,
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: 'SLIIT',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primaryNavy,
                            ),
                          ),
                          TextSpan(
                            text: 'Peer',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              color: AppColors.accentOrange,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Text(
                      'CAMPUS TUTORING',
                      style: TextStyle(
                        fontSize: 5.5,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Official Campus Network Badge
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
                      'OFFICIAL CAMPUS NETWORK',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryNavy,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Title
              const Text(
                'Join SLIIT Peer Tutoring',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                  letterSpacing: -0.4,
                ),
              ),

              const SizedBox(height: 8),

              // Subtitle
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Connect with fellow SLIIT undergraduates for 100% free peer academic support',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.5,
                    color: AppColors.textMuted,
                    height: 1.35,
                  ),
                ),
              ),

              const SizedBox(height: 22),

              // Option 1: "I need study help"
              _buildRoleCard(
                roleKey: 'student',
                isSelected: isStudent,
                iconData: Icons.school_rounded,
                iconBgColor: AppColors.lightBlueBg,
                iconColor: AppColors.primaryNavy,
                title: 'I need study help',
                description:
                    'Find senior students and peer mentors to clear coursework...',
                tags: [
                  _buildTag(
                    label: 'Looking for Tutors',
                    icon: Icons.search_rounded,
                    bgColor: const Color(0xFFEFF6FF),
                    textColor: AppColors.primaryNavy,
                  ),
                  _buildTag(
                    label: 'Modules & Labs',
                    bgColor: const Color(0xFFF1F5F9),
                    textColor: const Color(0xFF475569),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Option 2: "I can tutor peers"
              _buildRoleCard(
                roleKey: 'tutor',
                isSelected: !isStudent,
                iconData: Icons.workspace_premium_rounded,
                iconBgColor: AppColors.lightOrangeBg,
                iconColor: AppColors.darkOrange,
                title: 'I can tutor peers',
                description:
                    'Volunteer your academic strengths, earn university...',
                tags: [
                  _buildTag(
                    label: 'Become a Peer Mentor',
                    icon: Icons.stars_rounded,
                    bgColor: const Color(0xFFFFEDD5),
                    textColor: const Color(0xFFC2410C),
                  ),
                  _buildTag(
                    label: 'Volunteer Credits',
                    bgColor: const Color(0xFFF1F5F9),
                    textColor: const Color(0xFF475569),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Notice Banner: 100% Free Campus Initiative
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F7FF),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFDBEAFE)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDBEAFE),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.volunteer_activism_rounded,
                        color: AppColors.primaryNavy,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '100% Free Campus Initiative',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'By SLIIT students, for SLIIT student',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.groups_outlined,
                      color: Color(0xFF94A3B8),
                      size: 22,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Action Button: Continue as Student / Tutor
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryNavy,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangle64(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RegistrationStep1Screen(
                          role: _selectedRole,
                        ),
                      ),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isStudent ? 'Continue as Student' : 'Continue as Tutor',
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded, size: 18),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Switch Notice
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.swap_horiz_rounded,
                    color: AppColors.textMuted,
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'You can switch roles anytime from your\nSLIIT account profile',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Already have an account? Log in
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Already have an account? ',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textMuted,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LoginScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Log in',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkOrange,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required String roleKey,
    required bool isSelected,
    required IconData iconData,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required String description,
    required List<Widget> tags,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRole = roleKey;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primaryNavy : AppColors.borderLight,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.primaryNavy.withValues(alpha: 0.06)
                  : Colors.black.withValues(alpha: 0.02),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Highlight Left Bar when selected
                Container(
                  width: 5,
                  color:
                      isSelected ? AppColors.primaryNavy : Colors.transparent,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color: iconBgColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(iconData, color: iconColor, size: 24),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    description,
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      color: AppColors.textMuted,
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              isSelected
                                  ? Icons.check_circle_rounded
                                  : Icons.radio_button_unchecked,
                              color: isSelected
                                  ? AppColors.primaryNavy
                                  : const Color(0xFFCBD5E1),
                              size: 22,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: tags,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTag({
    required String label,
    IconData? icon,
    required Color bgColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

class RoundedRectangle64 extends RoundedRectangleBorder {
  const RoundedRectangle64({super.borderRadius});
}
