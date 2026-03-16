import '../entities/chat_message.dart';

abstract class AiChatRepository {
  /// Sends the full conversation history and returns a stream of token fragments.
  /// The stream completes normally when the API sends [DONE].
  /// Network or parse errors are forwarded as stream errors.
  Stream<String> sendMessage(List<ChatMessage> history);
}
