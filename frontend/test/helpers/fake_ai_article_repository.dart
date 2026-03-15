import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/ai_article/domain/entities/ai_generated_article.dart';
import 'package:news_app_clean_architecture/features/ai_article/domain/repository/ai_article_repository.dart';
import 'package:dio/dio.dart';

const kFakeGeneratedArticle = AiGeneratedArticle(
  title: 'AI Generated Title',
  description: 'AI generated description.',
  content: 'AI generated content body.',
  thumbnailUrl: 'https://picsum.photos/seed/test/640/360',
);

class FakeAiArticleRepository implements AiArticleRepository {
  bool shouldFail;

  FakeAiArticleRepository({this.shouldFail = false});

  @override
  Future<DataState<AiGeneratedArticle>> generateArticle(String idea) async {
    if (shouldFail) {
      return DataFailed(DioError(
        requestOptions: RequestOptions(path: ''),
        error: Exception('generation failed'),
      ));
    }
    return DataSuccess(kFakeGeneratedArticle);
  }
}
