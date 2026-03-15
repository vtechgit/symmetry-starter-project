import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';

class WatchFirestoreArticlesUseCase {
  final ArticleRepository _repository;

  WatchFirestoreArticlesUseCase(this._repository);

  Stream<List<ArticleEntity>> call() => _repository.watchFirestoreArticles();
}
