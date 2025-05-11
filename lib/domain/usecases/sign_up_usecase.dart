import 'package:dartz/dartz.dart';
import 'package:firebase_parking/core/errors/failures.dart';
import 'package:firebase_parking/domain/entities/user_entity.dart';
import 'package:firebase_parking/domain/repositories/auth_repository.dart';

class SignUpUseCase {
  final AuthRepository repository;

  SignUpUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call(String email, String password) {
    return repository.signUp(email, password);
  }
}
