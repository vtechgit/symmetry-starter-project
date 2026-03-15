import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/comment_entity.dart';

class CommentModel extends CommentEntity {
  const CommentModel({
    required String commentId,
    required String authorId,
    required String authorName,
    required String text,
    DateTime? createdAt,
  }) : super(
          commentId: commentId,
          authorId: authorId,
          authorName: authorName,
          text: text,
          createdAt: createdAt,
        );

  factory CommentModel.fromFirestore(Map<String, dynamic> data, String docId) {
    DateTime? createdAt;
    final raw = data['createdAt'];
    if (raw is Timestamp) createdAt = raw.toDate();

    return CommentModel(
      commentId: docId,
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? '',
      text: data['text'] ?? '',
      createdAt: createdAt,
    );
  }
}
