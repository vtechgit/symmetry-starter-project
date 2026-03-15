import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/ai_chat/domain/entities/chat_message.dart';
import 'package:news_app_clean_architecture/features/ai_chat/domain/usecases/send_chat_message_usecase.dart';

import '../../../../helpers/fake_ai_chat_repository.dart';

void main() {
  const testHistory = [
    ChatMessage(
      id: '1',
      role: ChatRole.user,
      content: 'What is today\'s top news?',
    ),
  ];

  group('SendChatMessageUseCase', () {
    test('delegates to repository and returns the same stream tokens', () {
      final repo = FakeAiChatRepository(tokens: ['token1', 'token2']);
      final useCase = SendChatMessageUseCase(repo);

      expect(
        useCase.call(params: testHistory),
        emitsInOrder(['token1', 'token2', emitsDone]),
      );
    });

    test('propagates repository errors as stream errors', () {
      final repo = FakeAiChatRepository(shouldError: true);
      final useCase = SendChatMessageUseCase(repo);

      expect(
        useCase.call(params: testHistory),
        emitsError(isA<Exception>()),
      );
    });
  });
}
