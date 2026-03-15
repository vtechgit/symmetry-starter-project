import 'package:news_app_clean_architecture/features/ai_chat/data/data_sources/ai_chat_service.dart';
import 'package:news_app_clean_architecture/features/ai_chat/domain/entities/chat_message.dart';
import 'package:news_app_clean_architecture/features/ai_chat/domain/repository/ai_chat_repository.dart';

class AiChatRepositoryImpl implements AiChatRepository {
  final AiChatService _service;

  AiChatRepositoryImpl(this._service);

  @override
  Stream<String> sendMessage(List<ChatMessage> history) {
    return _service.streamChat(history);
  }
}
