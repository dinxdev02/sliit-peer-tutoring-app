import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/onboarding/role_selection_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // TODO: run `flutterfire configure` or add your own Firebase config
  // before uncommenting the line below. See README.md for setup steps.
  // await Firebase.initializeApp();

  runApp(const SliitPeerApp());
}

class SliitPeerApp extends StatelessWidget {
  const SliitPeerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SLIIT Peer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF1E3A8A), // deep blue
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E3A8A),
          secondary: const Color(0xFFF97316), // accent orange
        ),
        fontFamily: 'Inter',
        useMaterial3: true,
      ),
      home: const RoleSelectionScreen(),
    );
  }
}
