import 'package:firebase_auth/firebase_auth.dart';
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
}
