import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/ai_chat/domain/entities/chat_message.dart';
import 'package:news_app_clean_architecture/features/ai_chat/domain/usecases/send_chat_message_usecase.dart';
import 'package:news_app_clean_architecture/features/ai_chat/presentation/bloc/ai_chat_bloc.dart';
import 'package:news_app_clean_architecture/features/ai_chat/presentation/bloc/ai_chat_event.dart';
import 'package:news_app_clean_architecture/features/ai_chat/presentation/bloc/ai_chat_state.dart';

import '../../../../helpers/fake_ai_chat_repository.dart';

void main() {
  late AiChatBloc bloc;
  late FakeAiChatRepository fakeRepo;

  setUp(() {
    fakeRepo = FakeAiChatRepository(tokens: ['He', 'llo', '!']);
    bloc = AiChatBloc(SendChatMessageUseCase(fakeRepo));
  });

  tearDown(() => bloc.close());

  group('AiChatBloc — initial state', () {
    test('is AiChatInitial with empty messages', () {
      expect(bloc.state, isA<AiChatInitial>());
      expect(bloc.state.messages, isEmpty);
    });
  });

  group('AiChatBloc — AiChatMessageSent', () {
    test('emits AiChatStreaming states as tokens arrive', () {
      expect(
        bloc.stream,
        emitsInOrder([
          isA<AiChatStreaming>(), // initial placeholder emit
          isA<AiChatStreaming>(), // token 'He'
          isA<AiChatStreaming>(), // token 'llo'
          isA<AiChatStreaming>(), // token '!'
          isA<AiChatReady>(),    // stream closed
        ]),
      );
      bloc.add(const AiChatMessageSent('Hi'));
    });

    test('final state is AiChatReady with isStreaming=false on last message',
        () async {
      bloc.add(const AiChatMessageSent('Hi'));

      final ready = await bloc.stream.firstWhere((s) => s is AiChatReady)
          as AiChatReady;

      expect(ready.messages.last.isStreaming, isFalse);
      expect(ready.messages.last.role, ChatRole.assistant);
    });

    test('accumulated content equals joined tokens', () async {
      bloc.add(const AiChatMessageSent('Hi'));

      final ready = await bloc.stream.firstWhere((s) => s is AiChatReady)
          as AiChatReady;

      expect(ready.messages.last.content, equals('Hello!'));
    });

    test('user message is first, assistant message is last', () async {
      bloc.add(const AiChatMessageSent('Hi'));

      final ready = await bloc.stream.firstWhere((s) => s is AiChatReady)
          as AiChatReady;

      expect(ready.messages.length, equals(2));
      expect(ready.messages.first.role, ChatRole.user);
      expect(ready.messages.first.content, equals('Hi'));
      expect(ready.messages.last.role, ChatRole.assistant);
    });

    test('history passed to use case includes the new user message', () async {
      bloc.add(const AiChatMessageSent('What happened today?'));

      await bloc.stream.firstWhere((s) => s is AiChatReady);

      expect(fakeRepo.lastHistory, isNotNull);
      expect(fakeRepo.lastHistory!.last.content, equals('What happened today?'));
      expect(fakeRepo.lastHistory!.last.role, ChatRole.user);
    });

    test('emits AiChatError when repository throws', () {
      fakeRepo = FakeAiChatRepository(shouldError: true);
      bloc = AiChatBloc(SendChatMessageUseCase(fakeRepo));

      expect(
        bloc.stream,
        emitsInOrder([
          isA<AiChatStreaming>(),
          isA<AiChatError>(),
        ]),
      );
      bloc.add(const AiChatMessageSent('Hi'));
    });

    test('AiChatError contains a non-empty errorMessage', () async {
      fakeRepo = FakeAiChatRepository(shouldError: true);
      bloc = AiChatBloc(SendChatMessageUseCase(fakeRepo));
      bloc.add(const AiChatMessageSent('Hi'));

      final error = await bloc.stream.firstWhere((s) => s is AiChatError)
          as AiChatError;

      expect(error.errorMessage, isNotEmpty);
    });

    test('AiChatError preserves user message in messages list', () async {
      fakeRepo = FakeAiChatRepository(shouldError: true);
      bloc = AiChatBloc(SendChatMessageUseCase(fakeRepo));
      bloc.add(const AiChatMessageSent('Hi'));

      final error = await bloc.stream.firstWhere((s) => s is AiChatError)
          as AiChatError;

      expect(error.messages.first.role, ChatRole.user);
      expect(error.messages.first.content, equals('Hi'));
    });
  });

  group('AiChatBloc — AiChatCleared', () {
    test('resets state to AiChatInitial with empty messages', () async {
      bloc.add(const AiChatMessageSent('Hi'));
      await bloc.stream.firstWhere((s) => s is AiChatReady);

      bloc.add(const AiChatCleared());

      final cleared = await bloc.stream.first;
      expect(cleared, isA<AiChatInitial>());
      expect(cleared.messages, isEmpty);
    });
  });
}
