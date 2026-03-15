import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/ai_article/domain/usecases/generate_article_usecase.dart';
import 'package:news_app_clean_architecture/features/ai_article/presentation/bloc/generate_article_bloc.dart';
import 'package:news_app_clean_architecture/features/ai_article/presentation/bloc/generate_article_event.dart';
import 'package:news_app_clean_architecture/features/ai_article/presentation/bloc/generate_article_state.dart';

import '../../../../helpers/fake_ai_article_repository.dart';

void main() {
  late GenerateArticleBloc bloc;

  setUp(() {
    bloc = GenerateArticleBloc(
      GenerateArticleUseCase(FakeAiArticleRepository()),
    );
  });

  tearDown(() => bloc.close());

  group('GenerateArticleBloc', () {
    test('initial state is GenerateArticleInitial', () {
      expect(bloc.state, isA<GenerateArticleInitial>());
    });

    test('GenerateArticleRequested emits Loading then Success', () {
      expect(
        bloc.stream,
        emitsInOrder([
          isA<GenerateArticleLoading>(),
          isA<GenerateArticleSuccess>(),
        ]),
      );
      bloc.add(const GenerateArticleRequested('climate summit'));
    });

    test('GenerateArticleSuccess contains the generated article', () async {
      bloc.add(const GenerateArticleRequested('climate summit'));

      final success = await bloc.stream
          .firstWhere((s) => s is GenerateArticleSuccess) as GenerateArticleSuccess;

      expect(success.article.title, kFakeGeneratedArticle.title);
      expect(success.article.description, kFakeGeneratedArticle.description);
    });

    test('emits Loading then Error when repository fails', () {
      bloc = GenerateArticleBloc(
        GenerateArticleUseCase(FakeAiArticleRepository(shouldFail: true)),
      );

      expect(
        bloc.stream,
        emitsInOrder([
          isA<GenerateArticleLoading>(),
          isA<GenerateArticleError>(),
        ]),
      );
      bloc.add(const GenerateArticleRequested('bad idea'));
    });

    test('GenerateArticleError contains a non-empty message', () async {
      bloc = GenerateArticleBloc(
        GenerateArticleUseCase(FakeAiArticleRepository(shouldFail: true)),
      );

      bloc.add(const GenerateArticleRequested('bad idea'));

      final error = await bloc.stream
          .firstWhere((s) => s is GenerateArticleError) as GenerateArticleError;

      expect(error.message, isNotEmpty);
    });
  });
}
