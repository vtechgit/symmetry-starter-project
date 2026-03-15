import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:news_app_clean_architecture/core/constants/constants.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/bookmark_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/remote_article_data_sources.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/article.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';

class ArticleRepositoryImpl implements ArticleRepository {
  final RemoteArticleDataSources _remote;
  final BookmarkService _bookmarks;

  ArticleRepositoryImpl(this._remote, this._bookmarks);

  @override
  Future<DataState<List<ArticleModel>>> getNewsArticles() async {
    try {
      final httpResponse = await _remote.newsApi.getNewsArticles(
        apiKey: newsAPIKey,
        country: countryQuery,
        category: categoryQuery,
      );

      if (httpResponse.response.statusCode == 200) {
        return DataSuccess(httpResponse.data);
      } else {
        return DataFailed(DioError(
          error: httpResponse.response.statusMessage,
          response: httpResponse.response,
          type: DioErrorType.response,
          requestOptions: httpResponse.response.requestOptions,
        ));
      }
    } on DioError catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Stream<List<ArticleEntity>> watchFirestoreArticles() {
    return _remote.firestore.watchArticles();
  }

  @override
  Future<DataState<List<ArticleEntity>>> getFirestoreArticles() async {
    try {
      final articles = await _remote.firestore.getArticles();
      return DataSuccess(articles);
    } catch (e) {
      return DataFailed(_dioError(e));
    }
  }

  @override
  Future<DataState<void>> uploadArticle(ArticleEntity article) async {
    try {
      final authorId = FirebaseAuth.instance.currentUser?.uid ?? '';
      await _remote.firestore.uploadArticle(
        ArticleModel.fromEntity(article),
        authorId: authorId,
      );
      return const DataSuccess(null);
    } catch (e) {
      return DataFailed(_dioError(e));
    }
  }

  @override
  Future<DataState<void>> deleteArticle(String articleId) async {
    try {
      await _remote.firestore.deleteArticle(articleId);
      return const DataSuccess(null);
    } catch (e) {
      return DataFailed(_dioError(e));
    }
  }

  @override
  Future<DataState<String>> uploadThumbnail(
    Uint8List bytes,
    String fileName,
  ) async {
    try {
      final url = await _remote.storage.uploadArticleThumbnail(bytes, fileName);
      return DataSuccess(url);
    } catch (e) {
      return DataFailed(_dioError(e));
    }
  }

  @override
  Future<List<ArticleEntity>> getSavedArticles() => _bookmarks.getBookmarks();

  @override
  Future<void> saveArticle(ArticleEntity article) => _bookmarks.saveBookmark(article);

  @override
  Future<void> removeArticle(ArticleEntity article) => _bookmarks.removeBookmark(article);

  DioError _dioError(Object e) => DioError(
        error: e.toString(),
        type: DioErrorType.other,
        requestOptions: RequestOptions(path: ''),
      );
}
