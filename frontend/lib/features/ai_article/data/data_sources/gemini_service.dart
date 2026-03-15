import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:news_app_clean_architecture/core/constants/constants.dart';
import 'ai_text_provider.dart';

/// Gemini implementation of [AiTextProvider].
/// To activate: in injection_container.dart, register GeminiService instead of OpenRouterService.
/// Requires GEMINI_API_KEY passed via --dart-define=GEMINI_API_KEY=<key>.
class GeminiService implements AiTextProvider {
  final Dio _dio;

  GeminiService(this._dio);

  @override
  Future<String> completeText({required String system, required String user}) async {
    const url =
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$kGeminiApiKey';

    final response = await _dio.post(
      url,
      options: Options(headers: {'Content-Type': 'application/json'}),
      data: jsonEncode({
        'system_instruction': {
          'parts': [
            {'text': system}
          ]
        },
        'contents': [
          {
            'parts': [
              {'text': user}
            ]
          }
        ],
        'generationConfig': {
          'responseMimeType': 'application/json',
        },
      }),
    );

    final data = response.data is String ? jsonDecode(response.data) : response.data;
    return data['candidates'][0]['content']['parts'][0]['text'] as String;
  }
}
