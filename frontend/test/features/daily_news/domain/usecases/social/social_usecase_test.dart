import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/comment_entity.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/social_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/social/add_comment_usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/social/check_like_usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/social/toggle_like_usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/social/watch_comments_usecase.dart';

class FakeSocialRepository implements SocialRepository {
  bool liked = false;
  final List<CommentEntity> comments = [];

  @override
  Future<DataState<void>> toggleLike(String articleId) async {
    liked = !liked;
    return const DataSuccess(null);
  }

  @override
  Future<DataState<void>> addComment(String articleId, String text) async {
    comments.add(CommentEntity(
      commentId: 'c1',
      authorId: 'uid',
      authorName: 'Test',
      text: text,
    ));
    return const DataSuccess(null);
  }

  @override
  Stream<List<CommentEntity>> watchComments(String articleId) =>
      Stream.value(List.unmodifiable(comments));

  @override
  Future<bool> isLiked(String articleId) async => liked;

  @override
  Future<Map<String, int>> getArticleCounts(String articleId) async =>
      {'likeCount': 0, 'commentCount': 0};
}

void main() {
  late FakeSocialRepository repo;

  setUp(() => repo = FakeSocialRepository());

  group('ToggleLikeUseCase', () {
    test('toggles liked state', () async {
      final useCase = ToggleLikeUseCase(repo);
      expect(repo.liked, false);
      await useCase.call(params: 'article1');
      expect(repo.liked, true);
      await useCase.call(params: 'article1');
      expect(repo.liked, false);
    });
  });

  group('AddCommentUseCase', () {
    test('adds a comment to the repository', () async {
      final useCase = AddCommentUseCase(repo);
      await useCase.call(
        params: const AddCommentParams(articleId: 'article1', text: 'Hello!'),
      );
      expect(repo.comments.length, 1);
      expect(repo.comments.first.text, 'Hello!');
    });
  });

  group('WatchCommentsUseCase', () {
    test('returns stream of comments', () async {
      repo.comments.add(const CommentEntity(
        commentId: 'c1',
        authorId: 'uid',
        authorName: 'Alice',
        text: 'First comment',
      ));
      final useCase = WatchCommentsUseCase(repo);
      final result = await useCase.call('article1').first;
      expect(result.length, 1);
      expect(result.first.text, 'First comment');
    });
  });

  group('CheckLikeUseCase', () {
    test('returns false when not liked', () async {
      final result = await CheckLikeUseCase(repo).call(params: 'article1');
      expect(result, false);
    });

    test('returns true after toggle', () async {
      await ToggleLikeUseCase(repo).call(params: 'article1');
      final result = await CheckLikeUseCase(repo).call(params: 'article1');
      expect(result, true);
    });
  });
}
