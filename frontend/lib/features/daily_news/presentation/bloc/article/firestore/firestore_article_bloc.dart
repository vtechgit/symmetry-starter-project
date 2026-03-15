import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/delete_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/watch_firestore_articles.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/firestore/firestore_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/firestore/firestore_article_state.dart';

class FirestoreArticlesBloc
    extends Bloc<FirestoreArticlesEvent, FirestoreArticlesState> {
  final WatchFirestoreArticlesUseCase _watchFirestoreArticlesUseCase;
  final DeleteArticleUseCase _deleteArticleUseCase;

  FirestoreArticlesBloc(
    this._watchFirestoreArticlesUseCase,
    this._deleteArticleUseCase,
  ) : super(const FirestoreArticlesLoading()) {
    on<GetFirestoreArticles>(onGetFirestoreArticles);
    on<DeleteFirestoreArticle>(onDeleteFirestoreArticle);
  }

  Future<void> onGetFirestoreArticles(
    GetFirestoreArticles event,
    Emitter<FirestoreArticlesState> emit,
  ) async {
    emit(const FirestoreArticlesLoading());
    await emit.forEach<List<ArticleEntity>>(
      _watchFirestoreArticlesUseCase.call(),
      onData: (articles) => FirestoreArticlesDone(articles),
      onError: (_, __) =>
          const FirestoreArticlesError('Failed to load journalist articles'),
    );
  }

  Future<void> onDeleteFirestoreArticle(
    DeleteFirestoreArticle event,
    Emitter<FirestoreArticlesState> emit,
  ) async {
    await _deleteArticleUseCase.call(params: event.firestoreId);
  }
}
