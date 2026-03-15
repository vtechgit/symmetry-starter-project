import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

void main() {
  const firestoreMap = {
    'author': 'Jane Doe',
    'title': 'Test Article',
    'description': 'A test description',
    'content': 'Full article content here.',
    'url': 'https://example.com/article',
    'thumbnailURL': 'https://example.com/image.jpg',
    'publishedAt': '2026-03-14',
  };

  group('ArticleModel.fromFirestore', () {
    test('maps all fields correctly from a Firestore document', () {
      final model = ArticleModel.fromFirestore(firestoreMap, docId: 'test-doc-id');

      expect(model.author, 'Jane Doe');
      expect(model.title, 'Test Article');
      expect(model.description, 'A test description');
      expect(model.content, 'Full article content here.');
      expect(model.url, 'https://example.com/article');
      expect(model.urlToImage, 'https://example.com/image.jpg');
      expect(model.publishedAt, '2026-03-14');
    });

    test('defaults missing fields to empty string instead of null', () {
      final model = ArticleModel.fromFirestore(const {}, docId: 'test-doc-id');

      expect(model.author, '');
      expect(model.title, '');
      expect(model.content, '');
    });

    test('returns an ArticleEntity subtype', () {
      final model = ArticleModel.fromFirestore(firestoreMap, docId: 'test-doc-id');

      expect(model, isA<ArticleEntity>());
    });
  });

  group('ArticleModel.toJson', () {
    test('uses thumbnailURL as the Firestore field name for the image', () {
      final model = ArticleModel.fromFirestore(firestoreMap, docId: 'test-doc-id');
      final json = model.toJson();

      expect(json.containsKey('thumbnailURL'), isTrue);
      expect(json['thumbnailURL'], 'https://example.com/image.jpg');
      expect(json.containsKey('urlToImage'), isFalse);
    });

    test('serializes text fields correctly', () {
      final model = ArticleModel.fromFirestore(firestoreMap, docId: 'test-doc-id');
      final json = model.toJson();

      expect(json['author'], 'Jane Doe');
      expect(json['title'], 'Test Article');
      expect(json['description'], 'A test description');
      expect(json['content'], 'Full article content here.');
    });

    test('includes createdAt and updatedAt fields', () {
      final model = ArticleModel.fromFirestore(firestoreMap, docId: 'test-doc-id');
      final json = model.toJson();

      expect(json.containsKey('createdAt'), isTrue);
      expect(json.containsKey('updatedAt'), isTrue);
    });

    test('null fields serialize to empty string', () {
      const entity = ArticleEntity(title: 'Only title');
      final model = ArticleModel.fromEntity(entity);
      final json = model.toJson();

      expect(json['author'], '');
      expect(json['content'], '');
    });
  });
}
