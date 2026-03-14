import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/upload_article.dart';

void main() {
  late UploadArticleUseCase useCase;

  const testArticle = ArticleEntity(
    author: 'Test Author',
    title: 'Test Title',
    description: 'Test description.',
    content: 'Test content body.',
    urlToImage: 'https://via.placeholder.com/400x200.png',
    publishedAt: '2026-03-14',
  );

  setUp(() {
    useCase = UploadArticleUseCase();
  });

  group('UploadArticleUseCase', () {
    test('should return DataSuccess when upload succeeds', () async {
      final result = await useCase.call(params: testArticle);

      expect(result, isA<DataSuccess<void>>());
    });

    test('should never return DataFailed', () async {
      final result = await useCase.call(params: testArticle);

      expect(result, isNot(isA<DataFailed<void>>()));
    });

    test('should complete without error when params are null', () async {
      final result = await useCase.call();

      expect(result, isA<DataSuccess<void>>());
    });
  });
}
