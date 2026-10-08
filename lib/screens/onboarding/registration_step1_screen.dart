import 'package:flutter/material.dart';
import '../../widgets/brand_widgets.dart';
import 'login_screen.dart';
import 'registration_step2_screen.dart';
import '../../services/auth_service.dart';
import '../../widgets/peer_ui.dart';

/// Student Registration (Step 1 of 3: Student Details)
/// Owned by: Rashmika — FR1
class RegistrationStep1Screen extends StatefulWidget {
  final String role;

  const RegistrationStep1Screen({
    super.key,
    this.role = 'student',
  });

  @override
  State<RegistrationStep1Screen> createState() =>
      _RegistrationStep1ScreenState();
}

class _RegistrationStep1ScreenState extends State<RegistrationStep1Screen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreedToPledge = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _proceedToStep2() {
    if (_nameController.text.trim().length < 2 ||
        !AuthService.validEmail(_emailController.text) ||
        _passwordController.text.length < 6 ||
        _passwordController.text != _confirmPasswordController.text) {
      peerNotice(context,
          'Enter your name, SLIIT email and matching passwords of at least 6 characters.');
      return;
    }
    if (!_agreedToPledge) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please pledge to uphold academic integrity.'),
          backgroundColor: AppColors.primaryNavy,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RegistrationStep2Screen(
          role: widget.role,
          fullName: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primaryNavy,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'SLIIT',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Student Registration',
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: 16.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.textMuted),
            onPressed: () => Navigator.pop(context),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 14),
            child: UserAvatar(initials: 'DA', radius: 15),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Step Indicator Card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Column(
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'STEP 1 OF 3',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryNavy,
                              letterSpacing: 0.4,
                            ),
                          ),
                          Text(
                            'Next: Academic Major',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Progress Bars
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 4,
                              decoration: BoxDecoration(
                                color: AppColors.primaryNavy,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Container(
                              height: 4,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE2E8F0),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Container(
                              height: 4,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE2E8F0),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.badge_outlined,
                                size: 13,
                                color: AppColors.primaryNavy,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Student Details',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryNavy,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'Faculty & Year',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                            ),
                          ),
                          Text(
                            'Peer Preferences',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Info banner: Create your student account
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.lightBlueBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.lightBlueBorder),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDBEAFE),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.school_rounded,
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
                              'Create your student account',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark,
                              ),
                            ),
                            SizedBox(height: 3),
                            Text(
                              'Use your official SLIIT credentials to access 100% free campus peer tutoring.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF475569),
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Full Name',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      'As in student ID',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                _buildInputField(
                  controller: _nameController,
                  hintText: 'Dilki Amanda Perera',
                  prefixIcon: Icons.person_outline_rounded,
                ),

                const SizedBox(height: 14),

                // SLIIT University Email
                const Text(
                  'SLIIT University Email',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 6),
                _buildInputField(
                  controller: _emailController,
                  hintText: 'it21094832@my.sliit.lk',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 4),
                const Row(
                  children: [
                    Icon(Icons.info_outline,
                        size: 12, color: AppColors.textMuted),
                    SizedBox(width: 4),
                    Text(
                      'Must end with @my.sliit.lk or @sliit.lk',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Password
                const Text(
                  'Password',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 6),
                _buildInputField(
                  controller: _passwordController,
                  hintText: '••••••••••••',
                  prefixIcon: Icons.lock_outline_rounded,
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.textMuted,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 4),
                const Row(
                  children: [
                    Icon(Icons.lock_clock_outlined,
                        size: 12, color: AppColors.textMuted),
                    SizedBox(width: 4),
                    Text(
                      'Minimum 8 characters with numbers',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Confirm Password
                const Text(
                  'Confirm Password',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 6),
                _buildInputField(
                  controller: _confirmPasswordController,
                  hintText: '••••••••••••',
                  prefixIcon: Icons.history_rounded,
                  obscureText: _obscureConfirmPassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.textMuted,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 14),

                // Pledge Checkbox
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: _agreedToPledge,
                        activeColor: AppColors.primaryNavy,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        onChanged: (val) {
                          setState(() {
                            _agreedToPledge = val ?? false;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'I pledge to uphold academic integrity and adhere to the free SLIIT Student Mentorship Code.',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFF334155),
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Next Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryNavy,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _proceedToStep2,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Next',
                          style: TextStyle(
                            fontSize: 15,
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

                // Faculty footer card
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEDD5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.groups_rounded,
                          color: AppColors.darkOrange,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'SLIIT Faculty of Computing & Engineering',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              '100% Free Peer-to-Peer Academic Learning Community',
                              style: TextStyle(
                                fontSize: 10.5,
                                color: AppColors.textMuted,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.textDark,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          prefixIcon: Icon(
            prefixIcon,
            color: AppColors.textMuted,
            size: 20,
          ),
          suffixIcon: suffixIcon,
          hintText: hintText,
          hintStyle: const TextStyle(
            fontSize: 13.5,
            color: AppColors.textLight,
          ),
        ),
      ),
    );
  }
}
