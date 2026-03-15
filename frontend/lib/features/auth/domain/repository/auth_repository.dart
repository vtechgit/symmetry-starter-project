import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/auth_user_entity.dart';

abstract class AuthRepository {
  Future<DataState<AuthUserEntity>> signIn(String email, String password);
  Future<DataState<AuthUserEntity>> register(String email, String password);
  Future<void> signOut();
  Stream<AuthUserEntity?> watchAuthState();
}
