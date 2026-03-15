import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/comment_entity.dart';

enum SocialStatus { initial, loading, loaded, error }

class SocialState extends Equatable {
  final bool isLiked;
  final int likeCount;
  final int commentCount;
  final List<CommentEntity> comments;
  final SocialStatus status;

  const SocialState({
    this.isLiked = false,
    this.likeCount = 0,
    this.commentCount = 0,
    this.comments = const [],
    this.status = SocialStatus.initial,
  });

  SocialState copyWith({
    bool? isLiked,
    int? likeCount,
    int? commentCount,
    List<CommentEntity>? comments,
    SocialStatus? status,
  }) {
    return SocialState(
      isLiked: isLiked ?? this.isLiked,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      comments: comments ?? this.comments,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [isLiked, likeCount, commentCount, comments, status];
}
