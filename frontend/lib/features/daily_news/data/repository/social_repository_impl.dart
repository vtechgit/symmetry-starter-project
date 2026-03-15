import 'package:dio/dio.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/social_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/comment_entity.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/social_repository.dart';

class SocialRepositoryImpl implements SocialRepository {
  final SocialService _socialService;

  SocialRepositoryImpl(this._socialService);

  @override
  Future<DataState<void>> toggleLike(String articleId) async {
    try {
      await _socialService.toggleLike(articleId);
      return const DataSuccess(null);
    } catch (e) {
      return DataFailed(_dioError(e));
    }
  }

  @override
  Future<DataState<void>> addComment(String articleId, String text) async {
    try {
      await _socialService.addComment(articleId, text);
      return const DataSuccess(null);
    } catch (e) {
      return DataFailed(_dioError(e));
    }
  }

  @override
  Stream<List<CommentEntity>> watchComments(String articleId) {
    return _socialService.watchComments(articleId);
  }

  @override
  Future<bool> isLiked(String articleId) => _socialService.isLiked(articleId);

  @override
  Future<Map<String, int>> getArticleCounts(String articleId) =>
      _socialService.getArticleCounts(articleId);

  DioError _dioError(Object e) => DioError(
        error: e.toString(),
        type: DioErrorType.other,
        requestOptions: RequestOptions(path: ''),
      );
}
