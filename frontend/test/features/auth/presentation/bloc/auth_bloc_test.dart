import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_event.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_state.dart';
import '../../../../helpers/fake_auth_repository.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/change_password_usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/register_usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/update_profile_usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/watch_auth_state_usecase.dart';

AuthBloc _makeBloc(FakeAuthRepository repo) {
  return AuthBloc(AuthUseCases(
    watchAuthState: WatchAuthStateUseCase(repo),
    signOut: SignOutUseCase(repo),
    signIn: SignInUseCase(repo),
    register: RegisterUseCase(repo),
    updateProfile: UpdateProfileUseCase(repo),
    changePassword: ChangePasswordUseCase(repo),
  ));
}

void main() {
  late FakeAuthRepository repo;
  late AuthBloc bloc;

  setUp(() {
    repo = FakeAuthRepository();
    bloc = _makeBloc(repo);
  });

  tearDown(() => bloc.close());

  group('AuthBloc', () {
    test('initial state is AuthInitial', () {
      expect(bloc.state, isA<AuthInitial>());
    });

    test('SignInRequested with valid credentials emits Loading then Authenticated', () async {
      expect(
        bloc.stream,
        emitsInOrder([
          isA<AuthLoading>(),
          isA<AuthAuthenticated>(),
        ]),
      );
      bloc.add(const SignInRequested(email: 'test@example.com', password: 'password123'));
    });

    test('SignInRequested with wrong password emits Loading then AuthError', () async {
      repo.failNextCall = true;
      expect(
        bloc.stream,
        emitsInOrder([
          isA<AuthLoading>(),
          isA<AuthError>(),
        ]),
      );
      bloc.add(const SignInRequested(email: 'test@example.com', password: 'wrong'));
    });

    test('RegisterRequested emits Loading then Authenticated', () async {
      expect(
        bloc.stream,
        emitsInOrder([
          isA<AuthLoading>(),
          isA<AuthAuthenticated>(),
        ]),
      );
      bloc.add(const RegisterRequested(email: 'new@example.com', password: 'password123'));
    });
  });

  group('ChangePasswordRequested', () {
    test('emits Loading, AuthPasswordChanged, then AuthAuthenticated on success',
        () async {
      // Sign in first so bloc has a current user
      bloc.add(const SignInRequested(
          email: 'test@example.com', password: 'password123'));
      await bloc.stream.firstWhere((s) => s is AuthAuthenticated);

      expect(
        bloc.stream,
        emitsInOrder([
          isA<AuthLoading>(),
          isA<AuthPasswordChanged>(),
          isA<AuthAuthenticated>(),
        ]),
      );
      bloc.add(const ChangePasswordRequested(
        currentPassword: 'oldPass',
        newPassword: 'newPass123',
      ));
    });

    test('emits Loading then AuthError when repository fails', () async {
      repo.failChangePassword = true;
      expect(
        bloc.stream,
        emitsInOrder([
          isA<AuthLoading>(),
          isA<AuthError>(),
        ]),
      );
      bloc.add(const ChangePasswordRequested(
        currentPassword: 'wrongPass',
        newPassword: 'newPass123',
      ));
    });
  });
}
