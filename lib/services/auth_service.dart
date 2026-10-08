import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'upload_service.dart';

/// Owned by: Rashmika (Onboarding, Auth & Profile) — FR5
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<User?> registerWithEmail(String email, String password) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user;
  }

  Future<User?> loginWithEmail(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  User? get currentUser => _auth.currentUser;

  static bool validEmail(String email) =>
      RegExp(r'^[^\s@]+@my\.sliit\.lk$', caseSensitive: false)
          .hasMatch(email.trim());

  Future<void> registerProfile(
      {required String name,
      required String email,
      required String password,
      required String role,
      required String year,
      required String program,
      PlatformFile? evidence}) async {
    if (!validEmail(email) || name.trim().length < 2) {
      throw StateError(
          'Enter a name, SLIIT email and password of at least 6 characters.');
    }
    User? user = _auth.currentUser;
    if (user == null ||
        user.email?.toLowerCase() != email.trim().toLowerCase()) {
      if (password.length < 6) {
        throw StateError('Enter a password of at least 6 characters.');
      }
      user = (await _auth.createUserWithEmailAndPassword(
              email: email.trim().toLowerCase(), password: password))
          .user;
    }
    final doc = FirebaseFirestore.instance.collection('users').doc(user!.uid);
    if ((await doc.get()).exists) {
      throw StateError('This account already has a profile. Please sign in.');
    }
    await user.updateDisplayName(name.trim());
    final upload = evidence == null
        ? null
        : await UploadService.upload(evidence, 'verification/${user.uid}');
    await doc.set({
      'name': name.trim(),
      'email': email.trim().toLowerCase(),
      'role': role == 'tutor' ? 'tutor' : 'tutee',
      'year': year,
      'program': program,
      'verificationStatus': 'pending',
      'verificationEvidence': upload,
      'guidelinesAccepted': false,
      'createdAt': FieldValue.serverTimestamp()
    });
  }

  Future<void> resetPassword(String email) async {
    if (!validEmail(email)) {
      throw StateError('Enter your @my.sliit.lk email first.');
    }
    await _auth.sendPasswordResetEmail(email: email.trim().toLowerCase());
  }
}
