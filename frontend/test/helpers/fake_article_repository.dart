import 'dart:typed_data';

import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';

const kSeedArticles = [
  ArticleEntity(
    author: 'Jane Doe',
    title: 'Flutter Web Support Improves',
    description: 'Flutter team announces better web rendering.',
    content: 'Significant improvements to the web renderer.',
    urlToImage: 'https://example.com/image1.jpg',
    publishedAt: '2026-03-14',
  ),
  ArticleEntity(
    author: 'John Smith',
    title: 'Clean Architecture in Mobile Apps',
    description: 'Why separating concerns matters.',
    content: 'Clean Architecture prevents tight coupling.',
    urlToImage: 'https://example.com/image2.jpg',
    publishedAt: '2026-03-13',
  ),
];

class FakeArticleRepository implements ArticleRepository {
  final List<ArticleEntity> _firestoreArticles =
      List<ArticleEntity>.from(kSeedArticles);

  @override
  Future<DataState<List<ArticleEntity>>> getFirestoreArticles() async =>
      DataSuccess(List.unmodifiable(_firestoreArticles));

  @override
  Future<DataState<void>> uploadArticle(ArticleEntity article) async {
    _firestoreArticles.add(article);
    return const DataSuccess(null);
  }

  @override
  Stream<List<ArticleEntity>> watchFirestoreArticles() =>
      Stream.value(List.unmodifiable(_firestoreArticles));

  @override
  Future<DataState<String>> uploadThumbnail(
    Uint8List bytes,
    String fileName,
  ) async =>
      const DataSuccess('https://example.com/fake-thumbnail.jpg');

  @override
  Future<DataState<List<ArticleEntity>>> getNewsArticles() async =>
      const DataSuccess([]);

  @override
  Future<List<ArticleEntity>> getSavedArticles() async => [];

  @override
  Future<void> saveArticle(ArticleEntity article) async {}

  @override
  Future<void> removeArticle(ArticleEntity article) async {}

  @override
  Future<DataState<void>> deleteArticle(String articleId) async =>
      const DataSuccess(null);
}
