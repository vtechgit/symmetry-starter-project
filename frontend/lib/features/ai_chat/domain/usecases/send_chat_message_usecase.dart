import '../entities/chat_message.dart';
import '../repository/ai_chat_repository.dart';

/// Does NOT extend UseCase<T, P> because it returns Stream<String>, not Future<T>.
/// Same pattern as WatchCommentsUseCase and WatchFirestoreArticlesUseCase.
class SendChatMessageUseCase {
  final AiChatRepository _repository;

  SendChatMessageUseCase(this._repository);

  Stream<String> call({required List<ChatMessage> params}) {
    return _repository.sendMessage(params);
  }
}
