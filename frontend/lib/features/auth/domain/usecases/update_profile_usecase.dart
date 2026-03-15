import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/auth_user_entity.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/auth_repository.dart';

class UpdateProfileParams {
  final String? displayName;
  final String? photoURL;

  const UpdateProfileParams({this.displayName, this.photoURL});
}

class UpdateProfileUseCase {
  final AuthRepository _repository;

  UpdateProfileUseCase(this._repository);

  Future<DataState<AuthUserEntity>> call(UpdateProfileParams params) =>
      _repository.updateProfile(params.displayName, params.photoURL);
}
