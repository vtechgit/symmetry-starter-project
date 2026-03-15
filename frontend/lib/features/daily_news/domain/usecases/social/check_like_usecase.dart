import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/social_repository.dart';

class CheckLikeUseCase implements UseCase<bool, String> {
  final SocialRepository _repository;

  CheckLikeUseCase(this._repository);

  @override
  Future<bool> call({String? params}) {
    return _repository.isLiked(params!);
  }
}
