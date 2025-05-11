import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class SignInRequested extends AuthEvent {
  final String email;
  final String password;

  const SignInRequested({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class SignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;
  final String personalNumber;

  const SignUpRequested({required this.email, required this.password, required this.name, required this.personalNumber});

  @override
  List<Object> get props => [email, password, name, personalNumber];
}

class CompleteProfileRequested extends AuthEvent {
  final String name;
  final String personalNumber;

  const CompleteProfileRequested({required this.name, required this.personalNumber});

  @override
  List<Object> get props => [name, personalNumber];
}

class SignOutRequested extends AuthEvent {}
