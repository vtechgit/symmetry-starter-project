import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/auth_user_entity.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/auth_repository.dart';

class RegisterParams {
  final String email;
  final String password;

  const RegisterParams({required this.email, required this.password});
}

class RegisterUseCase implements UseCase<DataState<AuthUserEntity>, RegisterParams> {
  final AuthRepository _repository;

  RegisterUseCase(this._repository);

  @override
  Future<DataState<AuthUserEntity>> call({RegisterParams? params}) {
    return _repository.register(params!.email, params.password);
  }
}
