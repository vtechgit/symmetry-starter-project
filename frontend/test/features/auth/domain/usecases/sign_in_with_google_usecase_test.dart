import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/sign_in_with_google_usecase.dart';

import '../../../../helpers/fake_auth_repository.dart';

void main() {
  late FakeAuthRepository repo;
  late SignInWithGoogleUseCase useCase;

  setUp(() {
    repo = FakeAuthRepository();
    useCase = SignInWithGoogleUseCase(repo);
  });

  test('returns DataSuccess with user when repository succeeds', () async {
    final result = await useCase.call();
    expect(result, isA<DataSuccess>());
    expect(result.data, isNotNull);
  });

  test('returns DataFailed when repository fails', () async {
    repo.failNextCall = true;
    final result = await useCase.call();
    expect(result, isA<DataFailed>());
  });
}
