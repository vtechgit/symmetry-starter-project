import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/auth/data/data_sources/firebase_auth_service.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/auth_user_entity.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthService _service;

  AuthRepositoryImpl(this._service);

  @override
  Future<DataState<AuthUserEntity>> signIn(String email, String password) async {
    try {
      final user = await _service.signIn(email, password);
      return DataSuccess(user);
    } on FirebaseAuthException catch (e) {
      return DataFailed(DioError(
        error: _friendlyMessage(e.code),
        type: DioErrorType.other,
        requestOptions: RequestOptions(path: ''),
      ));
    }
  }

  @override
  Future<DataState<AuthUserEntity>> register(String email, String password) async {
    try {
      final user = await _service.register(email, password);
      return DataSuccess(user);
    } on FirebaseAuthException catch (e) {
      return DataFailed(DioError(
        error: _friendlyMessage(e.code),
        type: DioErrorType.other,
        requestOptions: RequestOptions(path: ''),
      ));
    }
  }

  @override
  Future<void> signOut() => _service.signOut();

  @override
  Stream<AuthUserEntity?> watchAuthState() => _service.watchAuthState();

  String _friendlyMessage(String code) {
    switch (code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}
