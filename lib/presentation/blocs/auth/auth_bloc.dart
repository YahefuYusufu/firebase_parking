import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/entities/user_entity.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repository;

  AuthBloc({required this.repository}) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<SignInRequested>(_onSignInRequested);
    on<SignUpRequested>(_onSignUpRequested);
    on<CompleteProfileRequested>(_onCompleteProfileRequested);
    on<SignOutRequested>(_onSignOutRequested);
  }

  Future<void> _onAuthCheckRequested(AuthCheckRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    final userOrNull = repository.getCurrentUser();

    if (userOrNull != null) {
      if (_hasCompleteProfile(userOrNull)) {
        emit(Authenticated(userOrNull));
      } else {
        emit(ProfileIncomplete(userOrNull));
      }
    } else {
      emit(Unauthenticated());
    }
  }

  Future<void> _onSignInRequested(SignInRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    final result = await repository.signIn(event.email, event.password);

    result.fold((failure) => emit(AuthError(failure.message)), (user) {
      if (_hasCompleteProfile(user)) {
        emit(Authenticated(user));
      } else {
        emit(ProfileIncomplete(user));
      }
    });
  }

  Future<void> _onSignUpRequested(SignUpRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    // First create the account
    final result = await repository.signUp(event.email, event.password);

    await result.fold(
      (failure) async {
        emit(AuthError(failure.message));
      },
      (user) async {
        // Then update the profile
        final profileResult = await repository.updateUserProfile(userId: user.id!, name: event.name, personalNumber: event.personalNumber);

        profileResult.fold((failure) => emit(AuthError(failure.message)), (updatedUser) => emit(Authenticated(updatedUser)));
      },
    );
  }

  Future<void> _onCompleteProfileRequested(CompleteProfileRequested event, Emitter<AuthState> emit) async {
    final currentState = state;

    if (currentState is ProfileIncomplete || currentState is Authenticated) {
      final user = currentState is ProfileIncomplete ? currentState.user : (currentState as Authenticated).user;

      emit(AuthLoading());

      final result = await repository.updateUserProfile(userId: user.id!, name: event.name, personalNumber: event.personalNumber);

      result.fold((failure) => emit(AuthError(failure.message)), (updatedUser) => emit(Authenticated(updatedUser)));
    }
  }

  Future<void> _onSignOutRequested(SignOutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    final result = await repository.signOut();

    result.fold((failure) => emit(AuthError(failure.message)), (_) => emit(Unauthenticated()));
  }

  bool _hasCompleteProfile(UserEntity user) {
    return user.name != null && user.personalNumber != null && user.name!.isNotEmpty && user.personalNumber!.isNotEmpty;
  }
}
