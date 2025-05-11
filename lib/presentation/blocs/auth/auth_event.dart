// lib/presentation/blocs/auth/auth_event.dart
import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Event to check the current authentication status
class AuthCheckRequested extends AuthEvent {}

/// Event to sign in with email and password
class SignInRequested extends AuthEvent {
  final String email;
  final String password;

  const SignInRequested({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

/// Event to sign up with email and password
class SignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;
  final String personalNumber;

  const SignUpRequested({required this.email, required this.password, required this.name, required this.personalNumber});

  @override
  List<Object> get props => [email, password, name, personalNumber];
}

/// Event to complete user profile with required information
class CompleteProfileRequested extends AuthEvent {
  final String name;
  final String personalNumber;

  const CompleteProfileRequested({required this.name, required this.personalNumber});

  @override
  List<Object> get props => [name, personalNumber];
}

/// Event to sign out the current user
class SignOutRequested extends AuthEvent {}

/// Event to update the user's profile picture
class UpdateProfilePictureRequested extends AuthEvent {
  final String filePath;

  const UpdateProfilePictureRequested({required this.filePath});

  @override
  List<Object> get props => [filePath];
}

/// Event to refresh the current user's profile data
class RefreshProfileRequested extends AuthEvent {
  const RefreshProfileRequested();
}
