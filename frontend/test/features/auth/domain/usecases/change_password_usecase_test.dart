import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/change_password_usecase.dart';

import '../../../../helpers/fake_auth_repository.dart';

void main() {
  late FakeAuthRepository repo;
  late ChangePasswordUseCase useCase;

  setUp(() {
    repo = FakeAuthRepository();
    useCase = ChangePasswordUseCase(repo);
  });

  test('returns DataSuccess when repository succeeds', () async {
    final result = await useCase.call(
      currentPassword: 'oldPass123',
      newPassword: 'newPass456',
    );
    expect(result, isA<DataSuccess>());
  });

  test('returns DataFailed when repository fails', () async {
    repo.failChangePassword = true;
    final result = await useCase.call(
      currentPassword: 'wrongPass',
      newPassword: 'newPass456',
    );
    expect(result, isA<DataFailed>());
  });
}
