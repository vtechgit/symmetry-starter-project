import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_firestore_articles.dart';

void main() {
  late GetFirestoreArticlesUseCase useCase;

  setUp(() {
    useCase = GetFirestoreArticlesUseCase();
  });

  group('GetFirestoreArticlesUseCase', () {
    test('should return DataSuccess with a list of articles', () async {
      final result = await useCase.call();

      expect(result, isA<DataSuccess<List<ArticleEntity>>>());
    });

    test('should return a non-empty list of articles', () async {
      final result = await useCase.call();

      expect(result.data, isNotEmpty);
    });

    test('should return articles with non-null required fields', () async {
      final result = await useCase.call();
      final articles = result.data!;

      for (final article in articles) {
        expect(article.title, isNotNull);
        expect(article.author, isNotNull);
        expect(article.description, isNotNull);
        expect(article.content, isNotNull);
      }
    });

    test('should never return DataFailed', () async {
      final result = await useCase.call();

      expect(result, isNot(isA<DataFailed<List<ArticleEntity>>>()));
    });
  });
}
