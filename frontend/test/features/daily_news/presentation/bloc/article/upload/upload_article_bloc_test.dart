import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/upload_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/upload/upload_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/upload/upload_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/upload/upload_article_state.dart';

void main() {
  late UploadArticleBloc bloc;

  const testArticle = ArticleEntity(
    title: 'Test Article',
    content: 'Test content for the article',
    description: 'Test description',
    author: 'Journalist',
    publishedAt: '2026-03-14',
  );

  setUp(() {
    bloc = UploadArticleBloc(UploadArticleUseCase());
  });

  tearDown(() {
    bloc.close();
  });

  group('UploadArticleBloc', () {
    test('initial state is UploadArticleInitial', () {
      expect(bloc.state, isA<UploadArticleInitial>());
    });

    test('UploadArticle emits Loading then Done', () async {
      expect(
        bloc.stream,
        emitsInOrder([
          isA<UploadArticleLoading>(),
          isA<UploadArticleDone>(),
        ]),
      );

      bloc.add(const UploadArticle(testArticle));
    });

    test('Done state is reached after upload', () async {
      bloc.add(const UploadArticle(testArticle));

      final doneState = await bloc.stream
          .firstWhere((state) => state is UploadArticleDone);

      expect(doneState, isA<UploadArticleDone>());
    });

    test('state is never UploadArticleError with valid use case', () async {
      bloc.add(const UploadArticle(testArticle));

      final states = await bloc.stream.take(2).toList();

      expect(states, everyElement(isNot(isA<UploadArticleError>())));
    });

    test('UploadArticle with optional image URL emits Done', () async {
      const articleWithImage = ArticleEntity(
        title: 'Article with image',
        content: 'Content',
        description: 'Description',
        author: 'Journalist',
        publishedAt: '2026-03-14',
        urlToImage: 'https://example.com/image.jpg',
      );

      bloc.add(const UploadArticle(articleWithImage));

      final doneState = await bloc.stream
          .firstWhere((state) => state is UploadArticleDone);

      expect(doneState, isA<UploadArticleDone>());
    });
  });
}
