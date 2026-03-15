import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/social_repository.dart';

class ToggleLikeUseCase implements UseCase<DataState<void>, String> {
  final SocialRepository _repository;

  ToggleLikeUseCase(this._repository);

  @override
  Future<DataState<void>> call({String? params}) {
    return _repository.toggleLike(params!);
  }
}
