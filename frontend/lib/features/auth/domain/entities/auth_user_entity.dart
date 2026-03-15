import 'package:equatable/equatable.dart';

class AuthUserEntity extends Equatable {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoURL;

  const AuthUserEntity({
    required this.uid,
    this.email,
    this.displayName,
    this.photoURL,
  });

  @override
  List<Object?> get props => [uid, email, displayName, photoURL];
}
