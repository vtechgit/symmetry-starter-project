import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:floor/floor.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import '../../../../core/constants/constants.dart';

@Entity(tableName: 'article', primaryKeys: ['id'])
class ArticleModel extends ArticleEntity {
  const ArticleModel({
    int? id,
    String? author,
    String? title,
    String? description,
    String? url,
    String? urlToImage,
    String? publishedAt,
    String? content,
    String? firestoreId,
    String? authorId,
    int? likeCount,
    int? commentCount,
  }) : super(
          id: id,
          author: author,
          title: title,
          description: description,
          url: url,
          urlToImage: urlToImage,
          publishedAt: publishedAt,
          content: content,
          firestoreId: firestoreId,
          authorId: authorId,
          likeCount: likeCount,
          commentCount: commentCount,
        );

  factory ArticleModel.fromJson(Map<String, dynamic> map) {
    return ArticleModel(
      author: map['author'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      url: map['url'] ?? '',
      urlToImage: map['urlToImage'] != null && map['urlToImage'] != ''
          ? map['urlToImage']
          : kDefaultImage,
      publishedAt: map['publishedAt'] ?? '',
      content: map['content'] ?? '',
    );
  }

  factory ArticleModel.fromEntity(ArticleEntity entity) {
    return ArticleModel(
      id: entity.id,
      author: entity.author,
      title: entity.title,
      description: entity.description,
      url: entity.url,
      urlToImage: entity.urlToImage,
      publishedAt: entity.publishedAt,
      content: entity.content,
      firestoreId: entity.firestoreId,
      authorId: entity.authorId,
      likeCount: entity.likeCount,
      commentCount: entity.commentCount,
    );
  }

  factory ArticleModel.fromFirestore(Map<String, dynamic> map, {required String docId}) {
    String resolvePublishedAt() {
      final raw = map['publishedAt'];
      if (raw == null) return '';
      if (raw is Timestamp) return raw.toDate().toIso8601String().substring(0, 10);
      return raw.toString();
    }

    return ArticleModel(
      firestoreId: docId,
      author: map['author'] ?? '',
      authorId: map['authorId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      url: map['url'] ?? '',
      urlToImage: map['thumbnailURL'] ?? '',
      publishedAt: resolvePublishedAt(),
      content: map['content'] ?? '',
      likeCount: (map['likeCount'] as num?)?.toInt() ?? 0,
      commentCount: (map['commentCount'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson({String? authorId}) {
    final now = FieldValue.serverTimestamp();
    final publishedTimestamp = _toTimestamp(publishedAt);
    return {
      'author': author ?? '',
      'authorId': authorId ?? this.authorId ?? '',
      'title': title ?? '',
      'description': description ?? '',
      'content': content ?? '',
      'thumbnailURL': urlToImage ?? '',
      'publishedAt': publishedTimestamp,
      'createdAt': now,
      'updatedAt': now,
      'likeCount': 0,
      'commentCount': 0,
    };
  }

  dynamic _toTimestamp(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return FieldValue.serverTimestamp();
    try {
      return Timestamp.fromDate(DateTime.parse(dateStr));
    } catch (_) {
      return FieldValue.serverTimestamp();
    }
  }
}
