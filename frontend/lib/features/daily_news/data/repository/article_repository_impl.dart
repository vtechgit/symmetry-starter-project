import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:news_app_clean_architecture/core/constants/constants.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/app_database.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/remote_article_data_sources.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/article.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';

class ArticleRepositoryImpl implements ArticleRepository {
  final RemoteArticleDataSources _remote;
  final AppDatabase? _appDatabase;

  ArticleRepositoryImpl(this._remote, this._appDatabase);

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
      return DataFailed(DioError(
        error: e.toString(),
        type: DioErrorType.other,
        requestOptions: RequestOptions(path: ''),
      ));
    }
  }

  @override
  Future<DataState<void>> uploadArticle(ArticleEntity article) async {
    try {
      await _remote.firestore.uploadArticle(ArticleModel.fromEntity(article));
      return const DataSuccess(null);
    } catch (e) {
      return DataFailed(DioError(
        error: e.toString(),
        type: DioErrorType.other,
        requestOptions: RequestOptions(path: ''),
      ));
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
      return DataFailed(DioError(
        error: e.toString(),
        type: DioErrorType.other,
        requestOptions: RequestOptions(path: ''),
      ));
    }
  }

  @override
  Future<List<ArticleModel>> getSavedArticles() async {
    if (_appDatabase == null) return [];
    return _appDatabase!.articleDAO.getArticles();
  }

  @override
  Future<void> saveArticle(ArticleEntity article) {
    if (_appDatabase == null) return Future.value();
    return _appDatabase!.articleDAO.insertArticle(ArticleModel.fromEntity(article));
  }

  @override
  Future<void> removeArticle(ArticleEntity article) {
    if (_appDatabase == null) return Future.value();
    return _appDatabase!.articleDAO.deleteArticle(ArticleModel.fromEntity(article));
  }
}
