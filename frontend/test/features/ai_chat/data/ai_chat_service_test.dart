import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/ai_chat/data/data_sources/ai_chat_service.dart';

// Tests cover the SSE line parsing logic via the @visibleForTesting
// parseSseLine helper. The Dio integration (streamChat) is exercised
// end-to-end through ai_chat_bloc_test.dart via FakeAiChatRepository.

void main() {
  group('AiChatService.parseSseLine', () {
    test('returns token content from a valid SSE data line', () {
      const line =
          'data: {"choices":[{"delta":{"content":"Hello"}}]}';

      expect(AiChatService.parseSseLine(line), equals('Hello'));
    });

    test('returns empty string for the [DONE] sentinel', () {
      const line = 'data: [DONE]';

      expect(AiChatService.parseSseLine(line), equals(''));
    });

    test('returns null for an empty line', () {
      expect(AiChatService.parseSseLine(''), isNull);
      expect(AiChatService.parseSseLine('   '), isNull);
    });

    test('returns null for a non-data SSE line (e.g. comment)', () {
      expect(AiChatService.parseSseLine(': keep-alive'), isNull);
    });

    test('returns null for a malformed JSON data line without throwing', () {
      const line = 'data: {not valid json{{{{';

      expect(AiChatService.parseSseLine(line), isNull);
    });

    test('returns null when delta has no content field', () {
      const line =
          'data: {"choices":[{"delta":{}}]}';

      expect(AiChatService.parseSseLine(line), isNull);
    });

    test('returns null when choices list is empty', () {
      const line = 'data: {"choices":[]}';

      expect(AiChatService.parseSseLine(line), isNull);
    });

    test('throws Exception when error field is present (e.g. 502 mid-stream)', () {
      const line =
          'data: {"choices":[],"error":{"code":502,"message":"Network connection lost."}}';

      expect(() => AiChatService.parseSseLine(line), throwsException);
    });

    test('error message is included in thrown exception', () {
      const line =
          'data: {"choices":[],"error":{"code":429,"message":"Rate limited"}}';

      expect(
        () => AiChatService.parseSseLine(line),
        throwsA(
          predicate((e) => e.toString().contains('Rate limited')),
        ),
      );
    });
  });
}
