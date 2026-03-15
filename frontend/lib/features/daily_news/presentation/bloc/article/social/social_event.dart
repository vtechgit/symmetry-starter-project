import 'package:equatable/equatable.dart';

abstract class SocialEvent extends Equatable {
  const SocialEvent();

  @override
  List<Object?> get props => [];
}

class SocialLoadRequested extends SocialEvent {
  final String articleId;
  final int initialLikeCount;
  final int initialCommentCount;

  const SocialLoadRequested({
    required this.articleId,
    this.initialLikeCount = 0,
    this.initialCommentCount = 0,
  });

  @override
  List<Object?> get props => [articleId];
}

class LikeToggled extends SocialEvent {
  final String articleId;
  const LikeToggled(this.articleId);

  @override
  List<Object?> get props => [articleId];
}

class CommentAdded extends SocialEvent {
  final String articleId;
  final String text;
  const CommentAdded({required this.articleId, required this.text});

  @override
  List<Object?> get props => [articleId, text];
}
