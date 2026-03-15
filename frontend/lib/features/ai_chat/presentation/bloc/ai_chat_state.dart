import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/features/ai_chat/domain/entities/chat_message.dart';

abstract class AiChatState extends Equatable {
  final List<ChatMessage> messages;
  const AiChatState({this.messages = const []});

  @override
  List<Object?> get props => [messages];
}

class AiChatInitial extends AiChatState {
  const AiChatInitial() : super(messages: const []);
}

/// Emitted for every token received.
/// The last message in [messages] has [isStreaming] = true.
class AiChatStreaming extends AiChatState {
  const AiChatStreaming({required List<ChatMessage> messages})
      : super(messages: messages);
}

/// Emitted when the token stream closes normally.
/// The last message has [isStreaming] = false.
class AiChatReady extends AiChatState {
  const AiChatReady({required List<ChatMessage> messages})
      : super(messages: messages);
}

/// Emitted on network or parse error.
/// Partial assistant content is preserved in [messages].
class AiChatError extends AiChatState {
  final String errorMessage;

  const AiChatError({
    required List<ChatMessage> messages,
    required this.errorMessage,
  }) : super(messages: messages);

  @override
  List<Object?> get props => [messages, errorMessage];
}
