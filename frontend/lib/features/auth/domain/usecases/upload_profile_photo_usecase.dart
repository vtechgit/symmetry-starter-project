import 'dart:typed_data';

import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/auth_repository.dart';

class UploadProfilePhotoParams {
  final Uint8List bytes;
  final String uid;
  final String fileName;

  const UploadProfilePhotoParams({
    required this.bytes,
    required this.uid,
    required this.fileName,
  });
}

class UploadProfilePhotoUseCase {
  final AuthRepository _repository;

  UploadProfilePhotoUseCase(this._repository);

  Future<DataState<String>> call(UploadProfilePhotoParams params) =>
      _repository.uploadProfilePhoto(params.bytes, params.uid, params.fileName);
}
