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
  final Uint8List imageBytes;
  final String imageFileName;

  const UploadArticle(this.article, this.imageBytes, this.imageFileName);

  @override
  List<Object?> get props => [article, imageFileName];
}
