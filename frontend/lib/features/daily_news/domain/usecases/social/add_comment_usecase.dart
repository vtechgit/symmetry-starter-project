import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/social_repository.dart';

class AddCommentParams {
  final String articleId;
  final String text;

  const AddCommentParams({required this.articleId, required this.text});
}

class AddCommentUseCase implements UseCase<DataState<void>, AddCommentParams> {
  final SocialRepository _repository;

  AddCommentUseCase(this._repository);

  @override
  Future<DataState<void>> call({AddCommentParams? params}) {
    return _repository.addComment(params!.articleId, params.text);
  }
}
