import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/ai_chat/domain/entities/chat_message.dart';
import 'package:news_app_clean_architecture/features/ai_chat/domain/usecases/send_chat_message_usecase.dart';

import 'ai_chat_event.dart';
import 'ai_chat_state.dart';

class AiChatBloc extends Bloc<AiChatEvent, AiChatState> {
  final SendChatMessageUseCase _sendMessage;

  AiChatBloc(this._sendMessage) : super(const AiChatInitial()) {
    on<AiChatMessageSent>(_onMessageSent);
    on<AiChatCleared>(_onCleared);
  }

  Future<void> _onMessageSent(
    AiChatMessageSent event,
    Emitter<AiChatState> emit,
  ) async {
    final userMessage = ChatMessage(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      role: ChatRole.user,
      content: event.text,
    );

    final assistantPlaceholder = ChatMessage(
      id: (DateTime.now().microsecondsSinceEpoch + 1).toString(),
      role: ChatRole.assistant,
      content: '',
      isStreaming: true,
    );

    // History sent to the API = existing messages + new user message (no placeholder)
    final historyForApi = [...state.messages, userMessage];

    // UI state = existing + user + empty streaming placeholder
    var currentMessages = <ChatMessage>[
      ...state.messages,
      userMessage,
      assistantPlaceholder,
    ];

    emit(AiChatStreaming(messages: List.unmodifiable(currentMessages)));

    // emit.forEach correctly stops emitting if the bloc is closed mid-stream
    await emit.forEach<String>(
      _sendMessage.call(params: historyForApi),
      onData: (token) {
        final updated = List<ChatMessage>.from(currentMessages);
        updated[updated.length - 1] =
            updated.last.copyWith(content: updated.last.content + token);
        currentMessages = updated;
        return AiChatStreaming(messages: List.unmodifiable(currentMessages));
      },
      onError: (error, _) {
        final updated = List<ChatMessage>.from(currentMessages);
        updated[updated.length - 1] =
            updated.last.copyWith(isStreaming: false);
        currentMessages = updated;
        return AiChatError(
          messages: List.unmodifiable(currentMessages),
          errorMessage: error.toString(),
        );
      },
    );

    // Stream completed normally — mark assistant message as done
    final finalMessages = List<ChatMessage>.from(currentMessages);
    finalMessages[finalMessages.length - 1] =
        finalMessages.last.copyWith(isStreaming: false);
    emit(AiChatReady(messages: List.unmodifiable(finalMessages)));
  }

  void _onCleared(AiChatCleared event, Emitter<AiChatState> emit) {
    emit(const AiChatInitial());
  }
}
