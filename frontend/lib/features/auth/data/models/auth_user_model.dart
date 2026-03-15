import 'package:firebase_auth/firebase_auth.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/auth_user_entity.dart';

class AuthUserModel extends AuthUserEntity {
  const AuthUserModel({
    required String uid,
    String? email,
    String? displayName,
  }) : super(uid: uid, email: email, displayName: displayName);

  factory AuthUserModel.fromFirebaseUser(User user) {
    return AuthUserModel(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
    );
  }
}
