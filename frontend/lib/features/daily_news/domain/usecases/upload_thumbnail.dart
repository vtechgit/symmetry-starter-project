import 'dart:typed_data';

import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';

class ThumbnailParams {
  final Uint8List bytes;
  final String fileName;

  const ThumbnailParams({required this.bytes, required this.fileName});
}

class UploadThumbnailUseCase implements UseCase<DataState<String>, ThumbnailParams> {
  final ArticleRepository _repository;

  UploadThumbnailUseCase(this._repository);

  @override
  Future<DataState<String>> call({ThumbnailParams? params}) =>
      _repository.uploadThumbnail(params!.bytes, params.fileName);
}
