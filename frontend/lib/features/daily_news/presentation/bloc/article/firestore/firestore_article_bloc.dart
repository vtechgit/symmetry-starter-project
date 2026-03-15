import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_firestore_articles.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/firestore/firestore_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/firestore/firestore_article_state.dart';

class FirestoreArticlesBloc
    extends Bloc<FirestoreArticlesEvent, FirestoreArticlesState> {
  final GetFirestoreArticlesUseCase _getFirestoreArticlesUseCase;

  FirestoreArticlesBloc(this._getFirestoreArticlesUseCase)
      : super(const FirestoreArticlesLoading()) {
    on<GetFirestoreArticles>(onGetFirestoreArticles);
  }

  void onGetFirestoreArticles(
    GetFirestoreArticles event,
    Emitter<FirestoreArticlesState> emit,
  ) async {
    emit(const FirestoreArticlesLoading());
    final result = await _getFirestoreArticlesUseCase.call();
    if (result is DataSuccess && result.data!.isNotEmpty) {
      emit(FirestoreArticlesDone(result.data!));
    } else {
      emit(const FirestoreArticlesError('Failed to load journalist articles'));
    }
  }
}
