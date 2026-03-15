import 'package:news_app_clean_architecture/features/daily_news/domain/repository/social_repository.dart';

class GetArticleCountsUseCase {
  final SocialRepository _repository;

  GetArticleCountsUseCase(this._repository);

  Future<Map<String, int>> call(String articleId) =>
      _repository.getArticleCounts(articleId);
}
