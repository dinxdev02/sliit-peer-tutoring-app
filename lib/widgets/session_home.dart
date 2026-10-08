import 'package:flutter/material.dart';
import '../screens/onboarding/welcome_screen.dart';
import '../screens/onboarding/registration_step2_screen.dart';
import '../screens/onboarding/tutor_profile_setup_screen.dart';
import '../screens/discovery/home_dashboard_screen.dart';
import 'data_widgets.dart';

/// Resume incomplete onboarding before allowing access to the data workflows.
class SessionHome extends StatelessWidget {
  const SessionHome({super.key});

  @override
  Widget build(BuildContext context) => DataView(builder: (context, data) {
        if (!data.signedIn) return const WelcomeScreen();
        if (data.profile == null) {
          return RegistrationStep2Screen(
            fullName: data.auth?.currentUser?.displayName ?? '',
            email: data.auth?.currentUser?.email ?? '',
          );
        }
        if (data.isTutor && data.ownTutor == null) {
          return const TutorProfileSetupScreen();
        }
        return const HomeDashboardScreen();
      });
}
