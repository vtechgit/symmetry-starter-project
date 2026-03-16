import 'package:news_app_clean_architecture/features/ai_chat/domain/entities/chat_message.dart';
import 'package:news_app_clean_architecture/features/ai_chat/domain/repository/ai_chat_repository.dart';

class FakeAiChatRepository implements AiChatRepository {
  final List<String> tokens;
  final bool shouldError;
  List<ChatMessage>? lastHistory;

  FakeAiChatRepository({
    this.tokens = const ['Hello', ', ', 'world', '!'],
    this.shouldError = false,
  });

  @override
  Stream<String> sendMessage(List<ChatMessage> history) async* {
    lastHistory = history;
    if (shouldError) {
      throw Exception('network error');
    }
    for (final token in tokens) {
      yield token;
    }
  }
}
