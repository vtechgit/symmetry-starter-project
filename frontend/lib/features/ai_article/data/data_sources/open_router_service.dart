import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:news_app_clean_architecture/core/constants/constants.dart';
import 'ai_text_provider.dart';

class OpenRouterService implements AiTextProvider {
  final Dio _dio;

  OpenRouterService(this._dio);

  @override
  Future<String> completeText({required String system, required String user}) async {
    final response = await _dio.post(
      '$kOpenRouterBaseUrl/chat/completions',
      options: Options(
        headers: {
          'Authorization': 'Bearer $kOpenRouterApiKey',
          'Content-Type': 'application/json',
        },
      ),
      data: jsonEncode({
        'model': kOpenRouterModel,
        'messages': [
          {'role': 'system', 'content': system},
          {'role': 'user', 'content': user},
        ],
        'response_format': {'type': 'json_object'},
      }),
    );

    final data = response.data is String ? jsonDecode(response.data) : response.data;
    return data['choices'][0]['message']['content'] as String;
  }
}
