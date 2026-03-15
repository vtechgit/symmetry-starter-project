import 'package:news_app_clean_architecture/features/auth/domain/entities/auth_user_entity.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/auth_repository.dart';

class WatchAuthStateUseCase {
  final AuthRepository _repository;

  WatchAuthStateUseCase(this._repository);

  Stream<AuthUserEntity?> call() {
    return _repository.watchAuthState();
  }
}
