import 'package:flutter/material.dart';
import '../../widgets/brand_widgets.dart';
import '../discovery/home_dashboard_screen.dart';
import 'package:file_picker/file_picker.dart';
import '../../services/upload_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/data_widgets.dart';
import 'tutor_profile_setup_screen.dart';
import '../../services/backend_config.dart';

/// Student Registration (Step 2 of 3: University Verification)
/// Owned by: Rashmika — FR1
class RegistrationStep2Screen extends StatefulWidget {
  final String role;
  final String fullName;
  final String email;
  final String password;

  const RegistrationStep2Screen({
    super.key,
    this.role = 'student',
    this.fullName = '',
    this.email = '',
    this.password = '',
  });

  @override
  State<RegistrationStep2Screen> createState() =>
      _RegistrationStep2ScreenState();
}

class _RegistrationStep2ScreenState extends State<RegistrationStep2Screen> {
  bool _hasUploadedFile = false;
  String _uploadedFileName = '';
  PlatformFile? _evidence;
  bool _saving = false;
  String _year = 'Year 1';
  String _program = 'Information Technology';
  late final _name = TextEditingController(text: widget.fullName);
  late String _role = widget.role == 'tutor' ? 'tutor' : 'tutee';

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _onUploadTapped() async {
    await perform(context, () async {
      final selected = await UploadService.pick();
      if (selected == null || !mounted) return;
      setState(() {
        _hasUploadedFile = true;
        _evidence = selected;
        _uploadedFileName = selected.name;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('SLIIT ID card selected successfully!'),
          backgroundColor: AppColors.primaryNavy,
          duration: Duration(seconds: 2),
        ),
      );
    });
  }

  void _submitAndContinue() async {
    if (_saving) return;
    setState(() => _saving = true);
    final ok = await perform(context, () async {
      await AuthService().registerProfile(
          name: _name.text,
          email: widget.email,
          password: widget.password,
          role: _role,
          year: _year,
          program: _program,
          evidence: BackendConfig.uploadsEnabled ? _evidence : null);
    });
    if (!mounted) return;
    setState(() => _saving = false);
    if (!ok) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content:
            Text('Registration saved. Enrollment verification is pending.'),
        backgroundColor: AppColors.primaryNavy,
        duration: Duration(seconds: 2),
      ),
    );

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => _role == 'tutor'
            ? const TutorProfileSetupScreen()
            : const HomeDashboardScreen(),
      ),
      (route) => false,
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
                          'STEP 2 OF 3',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryNavy,
                            letterSpacing: 0.4,
                          ),
                        ),
                        Text(
                          'University Verification',
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
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 13,
                              color: AppColors.primaryNavy,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Profile Info',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryNavy,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              '❷ ',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.primaryNavy,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Student ID',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryNavy,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              '❸ ',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textMuted,
                              ),
                            ),
                            Text(
                              'Preferences',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Title: Verify Student Status
              const Text(
                'Complete Student Profile',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                  letterSpacing: -0.3,
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                'Confirm your academic details to continue. A student ID upload is not required.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textMuted,
                  height: 1.35,
                ),
              ),

              const SizedBox(height: 16),

              // Upload Drop Box
              TextField(
                  controller: _name,
                  decoration: const InputDecoration(labelText: 'Full name')),
              DropdownButtonFormField<String>(
                  initialValue: _role,
                  decoration: const InputDecoration(labelText: 'Join as'),
                  items: const [
                    DropdownMenuItem(
                        value: 'tutee',
                        child: Text('Student seeking tutoring')),
                    DropdownMenuItem(value: 'tutor', child: Text('Peer tutor')),
                  ],
                  onChanged: (value) => setState(() => _role = value!)),
              DropdownButtonFormField<String>(
                  initialValue: _year,
                  decoration: const InputDecoration(labelText: 'Year of study'),
                  items: ['Year 1', 'Year 2', 'Year 3', 'Year 4']
                      .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                      .toList(),
                  onChanged: (v) => setState(() => _year = v!)),
              DropdownButtonFormField<String>(
                  initialValue: _program,
                  decoration: const InputDecoration(labelText: 'Program'),
                  items: [
                    'Information Technology',
                    'Software Engineering',
                    'Computer Science',
                    'Cyber Security'
                  ]
                      .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                      .toList(),
                  onChanged: (v) => setState(() => _program = v!)),
              const SizedBox(height: 16),
              if (BackendConfig.uploadsEnabled) ...[
                GestureDetector(
                  onTap: _onUploadTapped,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.borderLight,
                        width: 1.2,
                      ),
                    ),
                    child: Column(
                      children: [
                        // Badge Icon with plus
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 58,
                              height: 58,
                              decoration: const BoxDecoration(
                                color: Color(0xFFDBEAFE),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.badge_outlined,
                                color: AppColors.primaryNavy,
                                size: 28,
                              ),
                            ),
                            Positioned(
                              right: -2,
                              bottom: -2,
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: AppColors.darkOrange,
                                  shape: BoxShape.circle,
                                  border:
                                      Border.all(color: Colors.white, width: 2),
                                ),
                                child: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 12,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        const Text(
                          'Tap or drop your SLIIT ID here',
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),

                        const SizedBox(height: 4),

                        const Text(
                          'Supports clear JPG, PNG or PDF format\n(Max 5MB)',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                            height: 1.3,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Sample Upload File Card
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFDBEAFE)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDBEAFE),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.description_outlined,
                                  color: AppColors.primaryNavy,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            _hasUploadedFile
                                                ? _uploadedFileName
                                                : 'e.g. SLIIT_ID_IT21049280',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.textDark,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 5, vertical: 1.5),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFDBEAFE),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: const Text(
                                            'SAMPLE',
                                            style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF1D4ED8),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    const Text(
                                      'Front side showing IT Number & photo',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDBEAFE),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(
                                  Icons.file_upload_outlined,
                                  color: AppColors.primaryNavy,
                                  size: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // Campus Council Authentication Notice
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
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Color(0xFFDBEAFE),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.verified_user_rounded,
                          color: AppColors.primaryNavy,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Campus Council Authentication',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryNavy,
                              ),
                            ),
                            SizedBox(height: 3),
                            Text(
                              'Optional documents can support enrollment review. Tutor profiles remain pending until an administrator approves them.',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: Color(0xFF334155),
                                height: 1.35,
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
                      'Optional Document Checklist',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      '3 tips',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Requirement 1
                _buildChecklistItem(
                  icon: Icons.tag_rounded,
                  iconBgColor: const Color(0xFF0F766E),
                  title: 'Clear student IT Number',
                  subtitle: 'e.g., IT21XXXXXX must be legible and uncropped',
                ),

                const SizedBox(height: 8),

                // Requirement 2
                _buildChecklistItem(
                  icon: Icons.calendar_month_rounded,
                  iconBgColor: const Color(0xFFEA580C),
                  title: 'Valid academic year sticker visible',
                  subtitle: 'Shows active undergraduate enrollment status',
                ),

                const SizedBox(height: 8),

                // Requirement 3
                _buildChecklistItem(
                  icon: Icons.badge_rounded,
                  iconBgColor: AppColors.primaryNavy,
                  title: 'Matches registration name',
                  subtitle: 'Full name must match the Step 1 student details',
                ),
              ],
              const SizedBox(height: 22),

              // Bottom Navigation Buttons
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEFF6FF),
                          foregroundColor: AppColors.primaryNavy,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.arrow_back_rounded, size: 16),
                            SizedBox(width: 6),
                            Text(
                              'Back',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: SizedBox(
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
                        onPressed: _saving ? null : _submitAndContinue,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Submit & Continue',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(width: 6),
                            Icon(Icons.arrow_forward_rounded, size: 16),
                          ],
                        ),
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

  Widget _buildChecklistItem({
    required IconData icon,
    required Color iconBgColor,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 1.5),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
