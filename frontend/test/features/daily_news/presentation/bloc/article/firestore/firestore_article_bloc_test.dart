import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_firestore_articles.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/firestore/firestore_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/firestore/firestore_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/firestore/firestore_article_state.dart';

void main() {
  late FirestoreArticlesBloc bloc;

  setUp(() {
    bloc = FirestoreArticlesBloc(GetFirestoreArticlesUseCase());
  });

  tearDown(() {
    bloc.close();
  });

  group('FirestoreArticlesBloc', () {
    test('initial state is FirestoreArticlesLoading', () {
      expect(bloc.state, isA<FirestoreArticlesLoading>());
    });

    test('GetFirestoreArticles emits Loading then Done', () async {
      expect(
        bloc.stream,
        emitsInOrder([
          isA<FirestoreArticlesLoading>(),
          isA<FirestoreArticlesDone>(),
        ]),
      );

      bloc.add(const GetFirestoreArticles());
    });

    test('Done state contains a non-empty list of articles', () async {
      bloc.add(const GetFirestoreArticles());

      final doneState = await bloc.stream
          .firstWhere((state) => state is FirestoreArticlesDone)
          as FirestoreArticlesDone;

      expect(doneState.articles, isNotEmpty);
    });

    test('Done state articles have non-null title and author', () async {
      bloc.add(const GetFirestoreArticles());

      final doneState = await bloc.stream
          .firstWhere((state) => state is FirestoreArticlesDone)
          as FirestoreArticlesDone;

      for (final article in doneState.articles!) {
        expect(article.title, isNotNull);
        expect(article.author, isNotNull);
      }
    });

    test('state is never FirestoreArticlesError with valid use case', () async {
      bloc.add(const GetFirestoreArticles());

      final states = await bloc.stream.take(2).toList();

      expect(states, everyElement(isNot(isA<FirestoreArticlesError>())));
    });
  });
}
