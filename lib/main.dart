import 'package:flutter/material.dart';
import 'widgets/session_home.dart';
import 'services/backend_config.dart';
import 'services/app_data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await BackendConfig.initialize();
    await AppData.instance.initialize();
    runApp(const SliitPeerApp());
  } catch (error) {
    runApp(MaterialApp(
        home: Scaffold(
            body: SafeArea(
                child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Unable to connect to Firebase',
                              style: TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          const Text(
                              'Check the backend configuration and restart the app.'),
                          const SizedBox(height: 12),
                          Text(error.toString())
                        ]))))));
  }
}

class SliitPeerApp extends StatelessWidget {
  const SliitPeerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SLIIT Peer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        primaryColor: const Color(0xFF1E3A8A), // deep blue
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E3A8A),
          primary: const Color(0xFF1E3A8A),
          secondary: const Color(0xFFF97316), // accent orange
        ),
        fontFamily: 'Inter',
        useMaterial3: true,
      ),
      home: const SessionHome(),
    );
  }
}
