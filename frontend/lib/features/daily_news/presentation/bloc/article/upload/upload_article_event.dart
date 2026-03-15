import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

abstract class UploadArticleEvent extends Equatable {
  const UploadArticleEvent();

  @override
  List<Object?> get props => [];
}

class UploadArticle extends UploadArticleEvent {
  final ArticleEntity article;

  /// Raw bytes of the thumbnail picked by the user. Null when [imageUrl] is set.
  final Uint8List? imageBytes;

  /// File name used when uploading [imageBytes] to Storage. Null when [imageUrl] is set.
  final String? imageFileName;

  /// Pre-existing URL (e.g. AI-generated). When set, Storage upload is skipped.
  final String? imageUrl;

  const UploadArticle(
    this.article, {
    this.imageBytes,
    this.imageFileName,
    this.imageUrl,
  }) : assert(
          (imageBytes != null && imageFileName != null) || imageUrl != null,
          'Provide either imageBytes+imageFileName or imageUrl',
        );

  @override
  List<Object?> get props => [article, imageFileName, imageUrl];
}
