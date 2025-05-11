// lib/presentation/blocs/auth/auth_bloc.dart
// ignore_for_file: avoid_print

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/auth_repository.dart';
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
    on<UpdateProfilePictureRequested>(_onUpdateProfilePictureRequested);
  }

  Future<void> _onAuthCheckRequested(AuthCheckRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    final userOrNull = repository.getCurrentUser();
    print("AuthCheckRequested: currentUser = $userOrNull");

    if (userOrNull != null) {
      // Refresh the user profile to get the latest data from Firestore
      print("AuthCheckRequested: Refreshing user profile to get complete data");
      final refreshResult = await repository.refreshUserProfile();

      await refreshResult.fold(
        (failure) async {
          print("AuthCheckRequested: Failed to refresh profile: ${failure.message}");
          // Even if refresh fails, proceed with the basic user data we have
          final hasCompleteProfile = repository.hasCompleteProfile();
          print("AuthCheckRequested: hasCompleteProfile = $hasCompleteProfile");

          if (hasCompleteProfile) {
            emit(Authenticated(userOrNull));
          } else {
            emit(ProfileIncomplete(userOrNull));
          }
        },
        (updatedUser) async {
          print("AuthCheckRequested: Profile refreshed successfully: $updatedUser");
          final hasCompleteProfile = updatedUser.hasCompleteProfile;
          print("AuthCheckRequested: hasCompleteProfile = $hasCompleteProfile");

          if (hasCompleteProfile) {
            emit(Authenticated(updatedUser));
          } else {
            emit(ProfileIncomplete(updatedUser));
          }
        },
      );
    } else {
      emit(Unauthenticated());
    }
  }

  Future<void> _onSignInRequested(SignInRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    final result = await repository.signIn(event.email, event.password);

    result.fold(
      (failure) {
        print("SignIn failed: ${failure.message}");
        emit(AuthError(failure.message));
      },
      (user) {
        print("SignIn successful for user: $user");
        final hasCompleteProfile = user.hasCompleteProfile;
        print("SignIn: hasCompleteProfile = $hasCompleteProfile");

        if (hasCompleteProfile) {
          emit(Authenticated(user));
        } else {
          emit(ProfileIncomplete(user));
        }
      },
    );
  }

  Future<void> _onSignUpRequested(SignUpRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    // First create the account
    final result = await repository.signUp(event.email, event.password);

    await result.fold(
      (failure) async {
        print("SignUp failed: ${failure.message}");
        emit(AuthError(failure.message));
      },
      (user) async {
        print("SignUp successful: $user");

        // Then update the profile
        print("Updating profile with name: ${event.name}, personalNumber: ${event.personalNumber}");
        final profileResult = await repository.updateUserProfile(userId: user.id!, name: event.name, personalNumber: event.personalNumber);

        profileResult.fold(
          (failure) {
            print("Profile update failed: ${failure.message}");
            emit(AuthError(failure.message));
          },
          (updatedUser) {
            print("Profile updated: $updatedUser");
            emit(Authenticated(updatedUser));
          },
        );
      },
    );
  }

  Future<void> _onCompleteProfileRequested(CompleteProfileRequested event, Emitter<AuthState> emit) async {
    final currentState = state;

    if (currentState is ProfileIncomplete || currentState is Authenticated) {
      final user = currentState is ProfileIncomplete ? currentState.user : (currentState as Authenticated).user;

      print("CompleteProfileRequested for user: $user");
      print("Updating with name: ${event.name}, personalNumber: ${event.personalNumber}");

      emit(AuthLoading());

      final result = await repository.updateUserProfile(userId: user.id!, name: event.name, personalNumber: event.personalNumber);

      result.fold(
        (failure) {
          print("Profile completion failed: ${failure.message}");
          emit(AuthError(failure.message));
        },
        (updatedUser) {
          print("Profile completed: $updatedUser");
          emit(Authenticated(updatedUser));
        },
      );
    } else {
      print("Cannot complete profile: Invalid state $currentState");
    }
  }

  Future<void> _onUpdateProfilePictureRequested(UpdateProfilePictureRequested event, Emitter<AuthState> emit) async {
    final currentState = state;

    if (currentState is Authenticated) {
      final user = currentState.user;

      print("UpdateProfilePictureRequested for user: $user");
      print("Using file: ${event.filePath}");

      emit(AuthLoading());

      final result = await repository.updateProfilePicture(userId: user.id!, filePath: event.filePath);

      result.fold(
        (failure) {
          print("Profile picture update failed: ${failure.message}");
          emit(AuthError(failure.message));
        },
        (updatedUser) {
          print("Profile picture updated: $updatedUser");
          emit(Authenticated(updatedUser));
        },
      );
    } else {
      print("Cannot update profile picture: Invalid state $currentState");
    }
  }

  Future<void> _onSignOutRequested(SignOutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    final result = await repository.signOut();

    result.fold(
      (failure) {
        print("Sign out failed: ${failure.message}");
        emit(AuthError(failure.message));
      },
      (_) {
        print("Sign out successful");
        emit(Unauthenticated());
      },
    );
  }
}
