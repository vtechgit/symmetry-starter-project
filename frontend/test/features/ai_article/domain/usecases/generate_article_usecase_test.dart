import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/ai_article/domain/entities/ai_generated_article.dart';
import 'package:news_app_clean_architecture/features/ai_article/domain/usecases/generate_article_usecase.dart';

import '../../../../helpers/fake_ai_article_repository.dart';

void main() {
  group('GenerateArticleUseCase', () {
    test('delegates to repository and returns DataSuccess', () async {
      final useCase = GenerateArticleUseCase(FakeAiArticleRepository());

      final result = await useCase.call(params: 'space exploration');

      expect(result, isA<DataSuccess<AiGeneratedArticle>>());
      expect((result as DataSuccess).data, isA<AiGeneratedArticle>());
    });

    test('returns DataFailed when repository fails', () async {
      final useCase = GenerateArticleUseCase(
        FakeAiArticleRepository(shouldFail: true),
      );

      final result = await useCase.call(params: 'idea');

      expect(result, isA<DataFailed<AiGeneratedArticle>>());
    });

    test('passes idea string to repository', () async {
      final repo = _TrackingFakeRepository();
      final useCase = GenerateArticleUseCase(repo);

      await useCase.call(params: 'AI in healthcare');

      expect(repo.lastIdea, 'AI in healthcare');
    });
  });
}

class _TrackingFakeRepository extends FakeAiArticleRepository {
  String? lastIdea;

  @override
  Future<DataState<AiGeneratedArticle>> generateArticle(String idea) {
    lastIdea = idea;
    return super.generateArticle(idea);
  }
}
