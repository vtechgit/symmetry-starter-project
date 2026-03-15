import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/comment_entity.dart';

abstract class SocialRepository {
  Future<DataState<void>> toggleLike(String articleId);
  Future<DataState<void>> addComment(String articleId, String text);
  Stream<List<CommentEntity>> watchComments(String articleId);
  Future<bool> isLiked(String articleId);
  Future<Map<String, int>> getArticleCounts(String articleId);
}
