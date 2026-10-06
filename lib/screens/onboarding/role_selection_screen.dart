import 'package:flutter/material.dart';
// import 'registration_step1_screen.dart';

/// Owned by: Rashmika — FR1
class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text('Role Selection Screen'),
              Text('TODO: "I need help" / "I can tutor" cards'),
            ],
          ),
        ),
      ),
    );
  }
}
