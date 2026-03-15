import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import '../../domain/entities/ai_generated_article.dart';
import '../../domain/repository/ai_article_repository.dart';
import '../data_sources/ai_image_provider.dart';
import '../data_sources/ai_text_provider.dart';

class AiArticleRepositoryImpl implements AiArticleRepository {
  final AiTextProvider _textProvider;
  final AiImageProvider _imageProvider;

  AiArticleRepositoryImpl(this._textProvider, this._imageProvider);

  static const String _systemPrompt = '''
You are a professional journalist. Given a topic idea, generate a short news article.
Respond ONLY with valid JSON (no markdown, no code fences):
{
  "title": "compelling headline (max 80 chars)",
  "description": "1 sentence summary",
  "content": "2 short paragraphs, 2-3 sentences each",
  "imageKeywords": "2-3 comma-separated single English words (no spaces, no phrases) to find a relevant photo (e.g. cars,electric,technology)"
}
''';

  @override
  Future<DataState<AiGeneratedArticle>> generateArticle(String idea) async {
    try {
      final rawJson = await _textProvider.completeText(
        system: _systemPrompt,
        user: idea,
      );

      final map = jsonDecode(rawJson) as Map<String, dynamic>;
      final imagePrompt = map['imageKeywords'] as String? ?? 'news';

      final thumbnailUrl = await _imageProvider.generateImage(imagePrompt);

      return DataSuccess(AiGeneratedArticle(
        title: map['title'] as String? ?? '',
        description: map['description'] as String? ?? '',
        content: map['content'] as String? ?? '',
        thumbnailUrl: thumbnailUrl,
      ));
    } catch (e) {
      return DataFailed(DioError(
        requestOptions: RequestOptions(path: ''),
        error: e,
      ));
    }
  }
}
