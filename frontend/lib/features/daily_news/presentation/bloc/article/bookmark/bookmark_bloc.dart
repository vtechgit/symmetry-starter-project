import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/bookmark/bookmark_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/bookmark/bookmark_state.dart';
import '../../../../domain/usecases/get_saved_article.dart';
import '../../../../domain/usecases/remove_article.dart';
import '../../../../domain/usecases/save_article.dart';

class BookmarkBloc extends Bloc<BookmarkEvent, BookmarkState> {
  final GetSavedArticleUseCase _getSavedArticleUseCase;
  final SaveArticleUseCase _saveArticleUseCase;
  final RemoveArticleUseCase _removeArticleUseCase;

  BookmarkBloc(
    this._getSavedArticleUseCase,
    this._saveArticleUseCase,
    this._removeArticleUseCase,
  ) : super(const BookmarkLoading()) {
    on<GetBookmarks>(_onGetBookmarks);
    on<SaveBookmark>(_onSaveBookmark);
    on<RemoveBookmark>(_onRemoveBookmark);
  }

  Future<void> _onGetBookmarks(GetBookmarks event, Emitter<BookmarkState> emit) async {
    final articles = await _getSavedArticleUseCase();
    emit(BookmarkDone(articles));
  }

  Future<void> _onSaveBookmark(SaveBookmark event, Emitter<BookmarkState> emit) async {
    await _saveArticleUseCase(params: event.article);
    final articles = await _getSavedArticleUseCase();
    emit(BookmarkDone(articles));
  }

  Future<void> _onRemoveBookmark(RemoveBookmark event, Emitter<BookmarkState> emit) async {
    await _removeArticleUseCase(params: event.article);
    final articles = await _getSavedArticleUseCase();
    emit(BookmarkDone(articles));
  }
}
