import 'package:news_app_clean_architecture/features/daily_news/domain/entities/comment_entity.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/social_repository.dart';

class WatchCommentsUseCase {
  final SocialRepository _repository;

  WatchCommentsUseCase(this._repository);

  Stream<List<CommentEntity>> call(String articleId) {
    return _repository.watchComments(articleId);
  }
}
