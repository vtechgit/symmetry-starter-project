import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_event.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_state.dart';
import '../../../../helpers/fake_auth_repository.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/register_usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/sign_in_with_google_usecase.dart';
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
    signInWithGoogle: SignInWithGoogleUseCase(repo),
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

  group('GoogleSignInRequested', () {
    test('emits Loading then AuthAuthenticated on success', () async {
      expect(
        bloc.stream,
        emitsInOrder([
          isA<AuthLoading>(),
          isA<AuthAuthenticated>(),
        ]),
      );
      bloc.add(const GoogleSignInRequested());
    });

    test('emits Loading then AuthError on failure', () async {
      repo.failNextCall = true;
      expect(
        bloc.stream,
        emitsInOrder([
          isA<AuthLoading>(),
          isA<AuthError>(),
        ]),
      );
      bloc.add(const GoogleSignInRequested());
    });
  });
}
