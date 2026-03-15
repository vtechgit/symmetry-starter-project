import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/social/add_comment_usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/social/check_like_usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/social/get_article_counts_usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/social/toggle_like_usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/social/watch_comments_usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/comment_entity.dart';
import 'social_event.dart';
import 'social_state.dart';

class SocialUseCases {
  final ToggleLikeUseCase toggleLike;
  final AddCommentUseCase addComment;
  final WatchCommentsUseCase watchComments;
  final CheckLikeUseCase checkLike;
  final GetArticleCountsUseCase getArticleCounts;

  const SocialUseCases({
    required this.toggleLike,
    required this.addComment,
    required this.watchComments,
    required this.checkLike,
    required this.getArticleCounts,
  });
}

class SocialBloc extends Bloc<SocialEvent, SocialState> {
  final SocialUseCases _useCases;

  SocialBloc(this._useCases) : super(const SocialState()) {
    on<SocialLoadRequested>(_onLoadRequested);
    on<LikeToggled>(_onLikeToggled);
    on<CommentAdded>(_onCommentAdded);
  }

  Future<void> _onLoadRequested(
    SocialLoadRequested event,
    Emitter<SocialState> emit,
  ) async {
    emit(state.copyWith(
      status: SocialStatus.loading,
      likeCount: event.initialLikeCount,
      commentCount: event.initialCommentCount,
    ));
    final results = await Future.wait([
      _useCases.checkLike.call(params: event.articleId),
      _useCases.getArticleCounts.call(event.articleId),
    ]);
    final isLiked = results[0] as bool;
    final counts = results[1] as Map<String, int>;
    emit(state.copyWith(
      isLiked: isLiked,
      likeCount: counts['likeCount']!,
      commentCount: counts['commentCount']!,
    ));

    await emit.forEach<List<CommentEntity>>(
      _useCases.watchComments.call(event.articleId),
      onData: (comments) => state.copyWith(
        comments: comments,
        commentCount: comments.length,
        status: SocialStatus.loaded,
      ),
      onError: (_, __) => state.copyWith(status: SocialStatus.error),
    );
  }

  Future<void> _onLikeToggled(LikeToggled event, Emitter<SocialState> emit) async {
    final newLiked = !state.isLiked;
    emit(state.copyWith(
      isLiked: newLiked,
      likeCount: state.likeCount + (newLiked ? 1 : -1),
    ));
    await _useCases.toggleLike.call(params: event.articleId);
  }

  Future<void> _onCommentAdded(CommentAdded event, Emitter<SocialState> emit) async {
    await _useCases.addComment.call(
      params: AddCommentParams(articleId: event.articleId, text: event.text),
    );
  }
}
