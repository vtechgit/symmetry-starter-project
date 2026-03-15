import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/core/utils/article_filter.dart';

const _articles = [
  ArticleEntity(
    title: 'Flutter Web Rendering Improves',
    author: 'Jane Doe',
    description: 'Better performance on the web.',
    publishedAt: '2026-03-14',
  ),
  ArticleEntity(
    title: 'Clean Architecture in Mobile',
    author: 'John Smith',
    description: 'Why separating concerns matters.',
    publishedAt: '2026-03-13',
  ),
  ArticleEntity(
    title: 'Dart 3 Sealed Classes',
    author: 'Alice Johnson',
    description: 'Pattern matching made easy.',
    publishedAt: '2026-03-12',
  ),
];

void main() {
  group('filterArticles', () {
    test('empty query returns all articles unchanged', () {
      final result = filterArticles(_articles, '');
      expect(result, _articles);
    });

    test('query matching title returns correct subset', () {
      final result = filterArticles(_articles, 'Flutter');
      expect(result.length, 1);
      expect(result.first.title, contains('Flutter'));
    });

    test('query matching author returns correct subset', () {
      final result = filterArticles(_articles, 'Smith');
      expect(result.length, 1);
      expect(result.first.author, 'John Smith');
    });

    test('matching is case-insensitive', () {
      final result = filterArticles(_articles, 'flutter');
      expect(result.length, 1);
      expect(result.first.title, contains('Flutter'));
    });

    test('query with no matches returns empty list', () {
      final result = filterArticles(_articles, 'nonexistent xyz');
      expect(result, isEmpty);
    });

    test('partial match works (contains, not exact)', () {
      final result = filterArticles(_articles, 'Dart');
      expect(result.length, 1);
      expect(result.first.title, contains('Dart'));
    });
  });
}
