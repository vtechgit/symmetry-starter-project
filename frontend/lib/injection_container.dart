import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:news_app_clean_architecture/features/auth/data/data_sources/firebase_auth_service.dart';
import 'package:news_app_clean_architecture/features/auth/data/repository/auth_repository_impl.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/auth_repository.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/register_usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/watch_auth_state_usecase.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/bookmark_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/firestore_article_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/news_api_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/remote_article_data_sources.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/social_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/storage_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/repository/article_repository_impl.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/repository/social_repository_impl.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/social_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/delete_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_saved_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/remove_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/save_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/social/add_comment_usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/social/check_like_usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/social/get_article_counts_usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/social/toggle_like_usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/social/watch_comments_usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/upload_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/upload_thumbnail.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/bookmark/bookmark_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/social/social_bloc.dart';
import 'features/daily_news/domain/usecases/get_firestore_articles.dart';
import 'features/daily_news/domain/usecases/watch_firestore_articles.dart';
import 'features/daily_news/presentation/bloc/article/firestore/firestore_article_bloc.dart';
import 'features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'features/daily_news/presentation/bloc/article/upload/upload_article_bloc.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  // Dio
  sl.registerSingleton<Dio>(Dio());

  // Firebase singletons
  sl.registerSingleton<FirebaseFirestore>(FirebaseFirestore.instance);
  sl.registerSingleton<FirebaseStorage>(FirebaseStorage.instance);
  sl.registerSingleton<FirebaseAuth>(FirebaseAuth.instance);

  // Services
  sl.registerSingleton<NewsApiService>(NewsApiService(sl()));
  sl.registerSingleton<FirestoreArticleService>(FirestoreArticleService(sl()));
  sl.registerSingleton<StorageService>(StorageService(sl()));
  sl.registerSingleton<BookmarkService>(BookmarkService(sl()));
  sl.registerSingleton<SocialService>(SocialService(sl()));
  sl.registerSingleton<FirebaseAuthService>(FirebaseAuthService(sl()));

  // Remote data source wrapper
  sl.registerSingleton<RemoteArticleDataSources>(
    RemoteArticleDataSources(
      newsApi: sl(),
      firestore: sl(),
      storage: sl(),
    ),
  );

  // Repositories
  sl.registerSingleton<ArticleRepository>(
    ArticleRepositoryImpl(sl(), sl()),
  );
  sl.registerSingleton<SocialRepository>(
    SocialRepositoryImpl(sl()),
  );
  sl.registerSingleton<AuthRepository>(
    AuthRepositoryImpl(sl()),
  );

  // Use cases — daily_news
  sl.registerSingleton<GetArticleUseCase>(GetArticleUseCase(sl()));
  sl.registerSingleton<GetSavedArticleUseCase>(GetSavedArticleUseCase(sl()));
  sl.registerSingleton<SaveArticleUseCase>(SaveArticleUseCase(sl()));
  sl.registerSingleton<RemoveArticleUseCase>(RemoveArticleUseCase(sl()));
  sl.registerSingleton<GetFirestoreArticlesUseCase>(GetFirestoreArticlesUseCase(sl()));
  sl.registerSingleton<WatchFirestoreArticlesUseCase>(WatchFirestoreArticlesUseCase(sl()));
  sl.registerSingleton<UploadArticleUseCase>(UploadArticleUseCase(sl()));
  sl.registerSingleton<UploadThumbnailUseCase>(UploadThumbnailUseCase(sl()));
  sl.registerSingleton<DeleteArticleUseCase>(DeleteArticleUseCase(sl()));

  // Use cases — social
  sl.registerSingleton<ToggleLikeUseCase>(ToggleLikeUseCase(sl()));
  sl.registerSingleton<AddCommentUseCase>(AddCommentUseCase(sl()));
  sl.registerSingleton<WatchCommentsUseCase>(WatchCommentsUseCase(sl()));
  sl.registerSingleton<CheckLikeUseCase>(CheckLikeUseCase(sl()));
  sl.registerSingleton<GetArticleCountsUseCase>(GetArticleCountsUseCase(sl()));
  sl.registerSingleton<SocialUseCases>(SocialUseCases(
    toggleLike: sl(),
    addComment: sl(),
    watchComments: sl(),
    checkLike: sl(),
    getArticleCounts: sl(),
  ));

  // Use cases — auth
  sl.registerSingleton<WatchAuthStateUseCase>(WatchAuthStateUseCase(sl()));
  sl.registerSingleton<SignOutUseCase>(SignOutUseCase(sl()));
  sl.registerSingleton<SignInUseCase>(SignInUseCase(sl()));
  sl.registerSingleton<RegisterUseCase>(RegisterUseCase(sl()));
  sl.registerSingleton<AuthUseCases>(AuthUseCases(
    watchAuthState: sl(),
    signOut: sl(),
    signIn: sl(),
    register: sl(),
  ));

  // Blocs
  sl.registerFactory<RemoteArticlesBloc>(() => RemoteArticlesBloc(sl()));
  sl.registerFactory<FirestoreArticlesBloc>(() => FirestoreArticlesBloc(sl(), sl()));
  sl.registerFactory<UploadArticleBloc>(() => UploadArticleBloc(sl(), sl()));
  sl.registerFactory<BookmarkBloc>(() => BookmarkBloc(sl(), sl(), sl()));
  sl.registerFactory<SocialBloc>(() => SocialBloc(sl()));
  sl.registerSingleton<AuthBloc>(AuthBloc(sl()));
}
