import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

abstract class ArticleRepository {
  // NewsAPI methods
  Future<DataState<List<ArticleEntity>>> getNewsArticles();

  // Firestore methods
  Future<DataState<List<ArticleEntity>>> getFirestoreArticles();
  Future<DataState<void>> uploadArticle(ArticleEntity article);
  Stream<List<ArticleEntity>> watchFirestoreArticles();

  // Local database methods
  Future<List<ArticleEntity>> getSavedArticles();
  Future<void> saveArticle(ArticleEntity article);
  Future<void> removeArticle(ArticleEntity article);
}