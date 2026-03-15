import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/auth_user_entity.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/auth_repository.dart';

const _fakeUser = AuthUserEntity(
  uid: 'fake-uid-123',
  email: 'test@example.com',
  displayName: 'Test User',
);

DioError _fakeError(String msg) => DioError(
      error: msg,
      type: DioErrorType.other,
      requestOptions: RequestOptions(path: ''),
    );

class FakeAuthRepository implements AuthRepository {
  bool failNextCall = false;

  @override
  Future<DataState<AuthUserEntity>> signIn(String email, String password) async {
    if (failNextCall) {
      failNextCall = false;
      return DataFailed(_fakeError('wrong-password'));
    }
    return const DataSuccess(_fakeUser);
  }

  @override
  Future<DataState<AuthUserEntity>> register(String email, String password) async {
    if (failNextCall) {
      failNextCall = false;
      return DataFailed(_fakeError('email-already-in-use'));
    }
    return const DataSuccess(_fakeUser);
  }

  @override
  Future<void> signOut() async {}

  @override
  Stream<AuthUserEntity?> watchAuthState() => Stream.value(null);

  @override
  Future<DataState<AuthUserEntity>> updateProfile(
      String? displayName, String? photoURL) async {
    return DataSuccess(AuthUserEntity(
      uid: _fakeUser.uid,
      email: _fakeUser.email,
      displayName: displayName ?? _fakeUser.displayName,
      photoURL: photoURL ?? _fakeUser.photoURL,
    ));
  }

  @override
  Future<DataState<String>> uploadProfilePhoto(
      Uint8List bytes, String uid, String fileName) async {
    return const DataSuccess('https://fake-photo-url.example.com/avatar.jpg');
  }
}
