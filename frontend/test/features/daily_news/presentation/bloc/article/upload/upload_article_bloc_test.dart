import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/upload_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/upload_thumbnail.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/upload/upload_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/upload/upload_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/upload/upload_article_state.dart';
import '../../../../../../helpers/fake_article_repository.dart';

void main() {
  late UploadArticleBloc bloc;

  const testArticle = ArticleEntity(
    title: 'Test Article',
    content: 'Test content for the article',
    description: 'Test description',
    author: 'Mario García',
    publishedAt: '2026-03-14',
  );

  final fakeImageBytes = Uint8List.fromList([0, 1, 2, 3]);
  const fakeImageFileName = 'test_thumbnail.jpg';
  const fakeImageUrl = 'https://loremflickr.com/640/360/cars?lock=1234';

  setUp(() {
    final repo = FakeArticleRepository();
    bloc = UploadArticleBloc(
      UploadArticleUseCase(repo),
      UploadThumbnailUseCase(repo),
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('UploadArticleBloc — bytes path', () {
    test('initial state is UploadArticleInitial', () {
      expect(bloc.state, isA<UploadArticleInitial>());
    });

    test('emits Loading then Done', () async {
      expect(
        bloc.stream,
        emitsInOrder([
          isA<UploadArticleLoading>(),
          isA<UploadArticleDone>(),
        ]),
      );

      bloc.add(UploadArticle(
        testArticle,
        imageBytes: fakeImageBytes,
        imageFileName: fakeImageFileName,
      ));
    });

    test('Done state is reached after upload', () async {
      bloc.add(UploadArticle(
        testArticle,
        imageBytes: fakeImageBytes,
        imageFileName: fakeImageFileName,
      ));

      final doneState =
          await bloc.stream.firstWhere((s) => s is UploadArticleDone);

      expect(doneState, isA<UploadArticleDone>());
    });

    test('never emits Error with valid use case', () async {
      bloc.add(UploadArticle(
        testArticle,
        imageBytes: fakeImageBytes,
        imageFileName: fakeImageFileName,
      ));

      final states = await bloc.stream.take(2).toList();

      expect(states, everyElement(isNot(isA<UploadArticleError>())));
    });
  });

  group('UploadArticleBloc — imageUrl path (AI-generated thumbnail)', () {
    test('emits Loading then Done when imageUrl is provided', () async {
      expect(
        bloc.stream,
        emitsInOrder([
          isA<UploadArticleLoading>(),
          isA<UploadArticleDone>(),
        ]),
      );

      bloc.add(const UploadArticle(testArticle, imageUrl: fakeImageUrl));
    });

    test('skips Storage upload and still reaches Done', () async {
      bloc.add(const UploadArticle(testArticle, imageUrl: fakeImageUrl));

      final doneState =
          await bloc.stream.firstWhere((s) => s is UploadArticleDone);

      expect(doneState, isA<UploadArticleDone>());
    });

    test('never emits Error with valid use case and imageUrl', () async {
      bloc.add(const UploadArticle(testArticle, imageUrl: fakeImageUrl));

      final states = await bloc.stream.take(2).toList();

      expect(states, everyElement(isNot(isA<UploadArticleError>())));
    });
  });
}
