import 'package:equatable/equatable.dart';

class CommentEntity extends Equatable {
  final String commentId;
  final String authorId;
  final String authorName;
  final String text;
  final DateTime? createdAt;

  const CommentEntity({
    required this.commentId,
    required this.authorId,
    required this.authorName,
    required this.text,
    this.createdAt,
  });

  @override
  List<Object?> get props => [commentId, authorId, authorName, text, createdAt];
}
