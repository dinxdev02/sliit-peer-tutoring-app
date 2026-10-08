import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class BackendConfig {
  static const emulator =
      bool.fromEnvironment('USE_FIREBASE_EMULATORS', defaultValue: kDebugMode);
  static const projectId = String.fromEnvironment('FIREBASE_PROJECT_ID',
      defaultValue: 'demo-sliit-peer');
  static const uploadsEnabled =
      bool.fromEnvironment('ENABLE_FILE_UPLOADS', defaultValue: emulator);
  static const host = String.fromEnvironment('FIREBASE_EMULATOR_HOST',
      defaultValue: '10.0.2.2');
  static Future<void> initialize() async {
    const key = String.fromEnvironment('FIREBASE_API_KEY');
    if (emulator) {
      await Firebase.initializeApp(
          options: const FirebaseOptions(
              apiKey: 'demo-api-key',
              appId: '1:1234567890:android:demo',
              messagingSenderId: '1234567890',
              projectId: projectId,
              storageBucket: '$projectId.appspot.com'));
      await FirebaseAuth.instance.useAuthEmulator(host, 9099);
      FirebaseFirestore.instance.settings =
          const Settings(persistenceEnabled: false);
      FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
      if (uploadsEnabled) {
        await FirebaseStorage.instance.useStorageEmulator(host, 9199);
      }
    } else if (key.isNotEmpty) {
      await Firebase.initializeApp(
          options: const FirebaseOptions(
              apiKey: key,
              appId: String.fromEnvironment('FIREBASE_APP_ID'),
              messagingSenderId: String.fromEnvironment('FIREBASE_SENDER_ID'),
              projectId: projectId,
              storageBucket:
                  String.fromEnvironment('FIREBASE_STORAGE_BUCKET')));
    } else {
      await Firebase.initializeApp();
    }
  }
}
