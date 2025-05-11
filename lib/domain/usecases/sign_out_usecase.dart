import 'package:dartz/dartz.dart';
import 'package:firebase_parking/core/errors/failures.dart';
import 'package:firebase_parking/domain/repositories/auth_repository.dart';

class SignOutUseCase {
  final AuthRepository repository;

  SignOutUseCase(this.repository);

  Future<Either<Failure, void>> call() {
    return repository.signOut();
  }
}
