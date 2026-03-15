import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

abstract class UploadArticleEvent extends Equatable {
  const UploadArticleEvent();

  @override
  List<Object?> get props => [];
}

class UploadArticle extends UploadArticleEvent {
  final ArticleEntity article;

  const UploadArticle(this.article);

  @override
  List<Object?> get props => [article];
}
