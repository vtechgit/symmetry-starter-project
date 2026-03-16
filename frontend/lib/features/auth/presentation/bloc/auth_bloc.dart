import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/auth_user_entity.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/register_usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/update_profile_usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/sign_in_with_google_usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/watch_auth_state_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthUseCases {
  final WatchAuthStateUseCase watchAuthState;
  final SignOutUseCase signOut;
  final SignInUseCase signIn;
  final RegisterUseCase register;
  final UpdateProfileUseCase updateProfile;
  final SignInWithGoogleUseCase signInWithGoogle;

  const AuthUseCases({
    required this.watchAuthState,
    required this.signOut,
    required this.signIn,
    required this.register,
    required this.updateProfile,
    required this.signInWithGoogle,
  });
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthUseCases _useCases;

  AuthBloc(this._useCases) : super(const AuthInitial()) {
    on<AuthStarted>(_onAuthStarted);
    on<AuthSignedOut>(_onAuthSignedOut);
    on<SignInRequested>(_onSignInRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<ProfileUpdateRequested>(_onProfileUpdateRequested);
    on<GoogleSignInRequested>(_onGoogleSignInRequested);
  }

  Future<void> _onAuthStarted(AuthStarted event, Emitter<AuthState> emit) async {
    await emit.forEach<AuthUserEntity?>(
      _useCases.watchAuthState.call(),
      onData: (user) => user != null
          ? AuthAuthenticated(user)
          : const AuthUnauthenticated(),
    );
  }

  Future<void> _onAuthSignedOut(AuthSignedOut event, Emitter<AuthState> emit) async {
    await _useCases.signOut.call();
  }

  Future<void> _onSignInRequested(SignInRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await _useCases.signIn.call(
      params: SignInParams(email: event.email, password: event.password),
    );
    if (result is DataSuccess<AuthUserEntity>) {
      emit(AuthAuthenticated(result.data!));
    } else {
      emit(AuthError(result.error?.error?.toString() ?? 'Sign in failed'));
    }
  }

  Future<void> _onRegisterRequested(RegisterRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await _useCases.register.call(
      params: RegisterParams(email: event.email, password: event.password),
    );
    if (result is DataSuccess<AuthUserEntity>) {
      emit(AuthAuthenticated(result.data!));
    } else {
      emit(AuthError(result.error?.error?.toString() ?? 'Registration failed'));
    }
  }

  Future<void> _onProfileUpdateRequested(
      ProfileUpdateRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await _useCases.updateProfile.call(
      UpdateProfileParams(displayName: event.displayName, photoURL: event.photoURL),
    );
    if (result is DataSuccess<AuthUserEntity>) {
      emit(AuthAuthenticated(result.data!));
    } else {
      emit(AuthError(result.error?.error?.toString() ?? 'Profile update failed'));
    }
  }

  Future<void> _onGoogleSignInRequested(
      GoogleSignInRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await _useCases.signInWithGoogle.call();
    if (result is DataSuccess<AuthUserEntity>) {
      emit(AuthAuthenticated(result.data!));
    } else {
      emit(AuthError(result.error?.error?.toString() ?? 'Google sign-in failed'));
    }
  }
}
