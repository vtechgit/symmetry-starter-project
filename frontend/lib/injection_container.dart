import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/firestore_article_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/news_api_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/repository/article_repository_impl.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'features/daily_news/data/data_sources/local/app_database.dart';
import 'features/daily_news/domain/usecases/get_firestore_articles.dart';
import 'features/daily_news/domain/usecases/watch_firestore_articles.dart';
import 'features/daily_news/domain/usecases/get_saved_article.dart';
import 'features/daily_news/domain/usecases/remove_article.dart';
import 'features/daily_news/domain/usecases/save_article.dart';
import 'features/daily_news/domain/usecases/upload_article.dart';
import 'features/daily_news/presentation/bloc/article/firestore/firestore_article_bloc.dart';
import 'features/daily_news/presentation/bloc/article/local/local_article_bloc.dart';
import 'features/daily_news/presentation/bloc/article/upload/upload_article_bloc.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  if (!kIsWeb) {
    final database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
    sl.registerSingleton<AppDatabase>(database);
  }

  // Dio
  sl.registerSingleton<Dio>(Dio());

  // NewsAPI
  sl.registerSingleton<NewsApiService>(NewsApiService(sl()));

  // Firestore
  sl.registerSingleton<FirebaseFirestore>(FirebaseFirestore.instance);
  sl.registerSingleton<FirestoreArticleService>(FirestoreArticleService(sl()));

  // Repository
  sl.registerSingleton<ArticleRepository>(
    ArticleRepositoryImpl(sl(), sl(), kIsWeb ? null : sl()),
  );

  // Use cases
  sl.registerSingleton<GetArticleUseCase>(GetArticleUseCase(sl()));
  sl.registerSingleton<GetSavedArticleUseCase>(GetSavedArticleUseCase(sl()));
  sl.registerSingleton<SaveArticleUseCase>(SaveArticleUseCase(sl()));
  sl.registerSingleton<RemoveArticleUseCase>(RemoveArticleUseCase(sl()));
  sl.registerSingleton<GetFirestoreArticlesUseCase>(GetFirestoreArticlesUseCase(sl()));
  sl.registerSingleton<WatchFirestoreArticlesUseCase>(WatchFirestoreArticlesUseCase(sl()));
  sl.registerSingleton<UploadArticleUseCase>(UploadArticleUseCase(sl()));

  // Blocs
  sl.registerFactory<RemoteArticlesBloc>(() => RemoteArticlesBloc(sl()));
  sl.registerFactory<LocalArticleBloc>(() => LocalArticleBloc(sl(), sl(), sl()));
  sl.registerFactory<FirestoreArticlesBloc>(() => FirestoreArticlesBloc(sl()));
  sl.registerFactory<UploadArticleBloc>(() => UploadArticleBloc(sl()));
}
