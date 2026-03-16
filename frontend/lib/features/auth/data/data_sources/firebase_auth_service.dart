import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:news_app_clean_architecture/features/auth/data/models/auth_user_model.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth;

  FirebaseAuthService(this._auth);

  Future<AuthUserModel> signIn(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return AuthUserModel.fromFirebaseUser(credential.user!);
  }

  Future<AuthUserModel> register(String email, String password) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return AuthUserModel.fromFirebaseUser(credential.user!);
  }

  Future<void> signOut() => _auth.signOut();

  Stream<AuthUserModel?> watchAuthState() {
    return _auth.authStateChanges().map(
          (user) => user != null ? AuthUserModel.fromFirebaseUser(user) : null,
        );
  }

  Future<AuthUserModel> updateProfile({String? displayName, String? photoURL}) async {
    final user = _auth.currentUser!;
    if (displayName != null) await user.updateDisplayName(displayName);
    if (photoURL != null) await user.updatePhotoURL(photoURL);
    await user.reload();
    return AuthUserModel.fromFirebaseUser(_auth.currentUser!);
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser!;
    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(newPassword);
  }

  Future<AuthUserModel> signInWithGoogle() async {
    if (kIsWeb) {
      // On web, use Firebase's built-in popup — avoids the People API 403 error
      // that the google_sign_in package triggers on web.
      final userCredential = await _auth.signInWithPopup(GoogleAuthProvider());
      return AuthUserModel.fromFirebaseUser(userCredential.user!);
    }
    // Mobile flow via google_sign_in package
    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) throw Exception('Google sign-in cancelled.');
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final userCredential = await _auth.signInWithCredential(credential);
    return AuthUserModel.fromFirebaseUser(userCredential.user!);
  }
}
