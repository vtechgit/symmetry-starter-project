import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:news_app_clean_architecture/core/constants/constants.dart';
import 'package:news_app_clean_architecture/features/ai_chat/domain/entities/chat_message.dart';

class AiChatService {
  final Dio _dio;

  AiChatService(this._dio);

  static const String _systemPrompt =
      'You are a concise, knowledgeable news journalist assistant. '
      'Answer questions about current events, help users understand news stories, '
      'and provide context for breaking news. '
      'Keep responses focused and factual. '
      'Avoid speculation. When unsure, say so.';

  /// Returns a [Stream<String>] of raw token fragments via SSE streaming.
  /// The stream completes normally when the API sends [DONE].
  /// Any network or parse error is forwarded as a stream error.
  Stream<String> streamChat(List<ChatMessage> history) {
    final controller = StreamController<String>();

    _doStream(history, controller).catchError((Object e) {
      if (!controller.isClosed) {
        controller.addError(e);
        controller.close();
      }
    });

    return controller.stream;
  }

  Future<void> _doStream(
    List<ChatMessage> history,
    StreamController<String> controller,
  ) async {
    final messages = [
      {'role': 'system', 'content': _systemPrompt},
      ...history.map((m) => {
            'role': m.role == ChatRole.user ? 'user' : 'assistant',
            'content': m.content,
          }),
    ];

    final response = await _dio.post(
      '$kOpenRouterBaseUrl/chat/completions',
      options: Options(
        responseType: ResponseType.stream,
        headers: {
          'Authorization': 'Bearer $kOpenRouterApiKey',
          'Content-Type': 'application/json',
        },
      ),
      data: jsonEncode({
        'model': kChatModel,
        'messages': messages,
        'stream': true,
      }),
    );

    final responseBody = response.data as ResponseBody;
    // Buffer handles chunk boundaries — an SSE line may be split across chunks
    String buffer = '';

    await for (final chunk in responseBody.stream) {
      buffer += utf8.decode(chunk, allowMalformed: true);
      final lines = buffer.split('\n');
      // Keep the last (potentially incomplete) line in the buffer
      buffer = lines.removeLast();

      for (final line in lines) {
        final trimmed = line.trim();
        if (trimmed.isEmpty || !trimmed.startsWith('data: ')) continue;
        final data = trimmed.substring(6);
        if (data == '[DONE]') {
          if (!controller.isClosed) await controller.close();
          return;
        }
        try {
          final json = jsonDecode(data) as Map<String, dynamic>;
          // Detect API-level errors embedded in SSE (e.g. 502, rate limits)
          final apiError = json['error'] as Map<String, dynamic>?;
          if (apiError != null) {
            final msg = apiError['message'] as String? ?? 'Unknown error';
            controller.addError(Exception('OpenRouter error: $msg'));
            await controller.close();
            return;
          }
          final choices = json['choices'] as List<dynamic>?;
          if (choices == null || choices.isEmpty) continue;
          final delta = choices[0]['delta'] as Map<String, dynamic>?;
          final token = delta?['content'] as String?;
          if (token != null && token.isNotEmpty && !controller.isClosed) {
            controller.add(token);
          }
        } catch (_) {
          // Malformed SSE line — skip and continue
        }
      }
    }

    if (!controller.isClosed) await controller.close();
  }

  /// Parses a single SSE line and returns the token content, or null if the
  /// line should be skipped (empty, non-data, malformed JSON).
  /// Returns an empty string specifically for the [DONE] sentinel.
  /// Returns the token string, empty string for [DONE], null to skip,
  /// or throws [Exception] if the line contains an API-level error.
  @visibleForTesting
  static String? parseSseLine(String line) {
    final trimmed = line.trim();
    if (trimmed.isEmpty || !trimmed.startsWith('data: ')) return null;
    final data = trimmed.substring(6);
    if (data == '[DONE]') return '';
    try {
      final json = jsonDecode(data) as Map<String, dynamic>;
      final apiError = json['error'] as Map<String, dynamic>?;
      if (apiError != null) {
        final msg = apiError['message'] as String? ?? 'Unknown error';
        throw Exception('OpenRouter error: $msg');
      }
      final choices = json['choices'] as List<dynamic>?;
      if (choices == null || choices.isEmpty) return null;
      final delta = choices[0]['delta'] as Map<String, dynamic>?;
      return delta?['content'] as String?;
    } on FormatException {
      // Malformed JSON from jsonDecode — skip line
      return null;
    } on Exception {
      rethrow;
    } catch (_) {
      return null;
    }
  }
}
