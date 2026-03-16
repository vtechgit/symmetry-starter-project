import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/auth/data/data_sources/firebase_auth_service.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/auth_user_entity.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/auth_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/storage_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthService _service;
  final StorageService _storage;

  AuthRepositoryImpl(this._service, this._storage);

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

  @override
  Future<DataState<AuthUserEntity>> updateProfile(
      String? displayName, String? photoURL) async {
    try {
      final user = await _service.updateProfile(
          displayName: displayName, photoURL: photoURL);
      return DataSuccess(user);
    } catch (e) {
      return DataFailed(DioError(
        error: 'Failed to update profile.',
        type: DioErrorType.other,
        requestOptions: RequestOptions(path: ''),
      ));
    }
  }

  @override
  Future<DataState<String>> uploadProfilePhoto(
      Uint8List bytes, String uid, String fileName) async {
    try {
      final url = await _storage.uploadProfilePhoto(bytes, uid, fileName);
      return DataSuccess(url);
    } catch (e) {
      return DataFailed(DioError(
        error: 'Failed to upload photo.',
        type: DioErrorType.other,
        requestOptions: RequestOptions(path: ''),
      ));
    }
  }

  @override
  Future<DataState<AuthUserEntity>> signInWithGoogle() async {
    try {
      final user = await _service.signInWithGoogle();
      return DataSuccess(user);
    } on FirebaseAuthException catch (e) {
      return DataFailed(DioError(
        error: _googleErrorMessage(e.code),
        type: DioErrorType.other,
        requestOptions: RequestOptions(path: ''),
      ));
    } catch (e) {
      final msg = e.toString().contains('cancelled')
          ? 'Google sign-in was cancelled.'
          : 'Google sign-in failed. Please try again.';
      return DataFailed(DioError(
        error: msg,
        type: DioErrorType.other,
        requestOptions: RequestOptions(path: ''),
      ));
    }
  }

  String _googleErrorMessage(String code) {
    switch (code) {
      case 'account-exists-with-different-credential':
        return 'An account already exists with a different sign-in method.';
      case 'user-disabled':
        return 'This account has been disabled.';
      default:
        return 'Google sign-in failed. Please try again.';
    }
  }

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
