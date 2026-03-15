import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/upload_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/upload/upload_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/upload/upload_article_state.dart';

class UploadArticleBloc extends Bloc<UploadArticleEvent, UploadArticleState> {
  final UploadArticleUseCase _uploadArticleUseCase;

  UploadArticleBloc(this._uploadArticleUseCase)
      : super(const UploadArticleInitial()) {
    on<UploadArticle>(onUploadArticle);
  }

  void onUploadArticle(
    UploadArticle event,
    Emitter<UploadArticleState> emit,
  ) async {
    emit(const UploadArticleLoading());
    final result = await _uploadArticleUseCase.call(params: event.article);
    if (result is DataSuccess) {
      emit(const UploadArticleDone());
    } else {
      emit(const UploadArticleError('Failed to publish article'));
    }
  }
}
