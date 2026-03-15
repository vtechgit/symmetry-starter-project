import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/ai_article/data/data_sources/ai_image_provider.dart';
import 'package:news_app_clean_architecture/features/ai_article/data/data_sources/ai_text_provider.dart';
import 'package:news_app_clean_architecture/features/ai_article/data/repository/ai_article_repository_impl.dart';
import 'package:news_app_clean_architecture/features/ai_article/domain/entities/ai_generated_article.dart';

// ── Fakes ────────────────────────────────────────────────────────────────────

class FakeTextProvider implements AiTextProvider {
  final String? response;
  final bool shouldThrow;
  String? lastUser;

  FakeTextProvider({this.response, this.shouldThrow = false});

  @override
  Future<String> completeText({required String system, required String user}) async {
    lastUser = user;
    if (shouldThrow) throw DioError(requestOptions: RequestOptions(path: ''));
    return response!;
  }
}

class FakeImageProvider implements AiImageProvider {
  final String? url;
  final bool shouldThrow;

  FakeImageProvider({this.url, this.shouldThrow = false});

  @override
  Future<String> generateImage(String prompt) async {
    if (shouldThrow) throw DioError(requestOptions: RequestOptions(path: ''));
    return url!;
  }
}

// ── Tests ─────────────────────────────────────────────────────────────────────

const _validJson = '''
{
  "title": "Test Title",
  "description": "Test description.",
  "content": "Test article content.",
  "imagePrompt": "a vivid news scene"
}
''';

const _fakeImageUrl = 'https://picsum.photos/seed/test/640/360';

void main() {
  group('AiArticleRepositoryImpl', () {
    test('returns DataSuccess with correct fields on happy path', () async {
      final repo = AiArticleRepositoryImpl(
        FakeTextProvider(response: _validJson),
        FakeImageProvider(url: _fakeImageUrl),
      );

      final result = await repo.generateArticle('climate summit');

      expect(result, isA<DataSuccess<AiGeneratedArticle>>());
      final article = (result as DataSuccess<AiGeneratedArticle>).data!;
      expect(article.title, 'Test Title');
      expect(article.description, 'Test description.');
      expect(article.content, 'Test article content.');
      expect(article.thumbnailUrl, _fakeImageUrl);
    });

    test('returns DataFailed when text provider throws', () async {
      final repo = AiArticleRepositoryImpl(
        FakeTextProvider(shouldThrow: true),
        FakeImageProvider(url: _fakeImageUrl),
      );

      final result = await repo.generateArticle('idea');

      expect(result, isA<DataFailed<AiGeneratedArticle>>());
    });

    test('returns DataFailed when JSON is malformed', () async {
      final repo = AiArticleRepositoryImpl(
        FakeTextProvider(response: 'not valid json {{{{'),
        FakeImageProvider(url: _fakeImageUrl),
      );

      final result = await repo.generateArticle('idea');

      expect(result, isA<DataFailed<AiGeneratedArticle>>());
    });

    test('returns DataFailed when image provider throws', () async {
      final repo = AiArticleRepositoryImpl(
        FakeTextProvider(response: _validJson),
        FakeImageProvider(shouldThrow: true),
      );

      final result = await repo.generateArticle('idea');

      expect(result, isA<DataFailed<AiGeneratedArticle>>());
    });

    test('passes idea as user message to text provider', () async {
      final textProvider = FakeTextProvider(response: _validJson);
      final repo = AiArticleRepositoryImpl(
        textProvider,
        FakeImageProvider(url: _fakeImageUrl),
      );

      await repo.generateArticle('renewable energy trends');

      expect(textProvider.lastUser, 'renewable energy trends');
    });
  });
}
