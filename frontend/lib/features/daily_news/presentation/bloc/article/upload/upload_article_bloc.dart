import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/upload_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/upload_thumbnail.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/upload/upload_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/upload/upload_article_state.dart';

class UploadArticleBloc extends Bloc<UploadArticleEvent, UploadArticleState> {
  final UploadArticleUseCase _uploadArticleUseCase;
  final UploadThumbnailUseCase _uploadThumbnailUseCase;

  UploadArticleBloc(this._uploadArticleUseCase, this._uploadThumbnailUseCase)
      : super(const UploadArticleInitial()) {
    on<UploadArticle>(onUploadArticle);
  }

  Future<void> onUploadArticle(
    UploadArticle event,
    Emitter<UploadArticleState> emit,
  ) async {
    emit(const UploadArticleLoading());

    String? thumbUrl = event.imageUrl;

    if (thumbUrl == null) {
      final thumbResult = await _uploadThumbnailUseCase.call(
        params: ThumbnailParams(
          bytes: event.imageBytes!,
          fileName: event.imageFileName!,
        ),
      );
      if (thumbResult is DataFailed) {
        emit(const UploadArticleError('Failed to upload thumbnail'));
        return;
      }
      thumbUrl = thumbResult.data!;
    }

    final article = ArticleEntity(
      title: event.article.title,
      author: event.article.author,
      authorPhotoURL: event.article.authorPhotoURL,
      description: event.article.description,
      content: event.article.content,
      urlToImage: thumbUrl,
      publishedAt: event.article.publishedAt,
    );

    final result = await _uploadArticleUseCase.call(params: article);
    if (result is DataSuccess) {
      emit(const UploadArticleDone());
    } else {
      emit(const UploadArticleError('Failed to publish article'));
    }
  }
}
