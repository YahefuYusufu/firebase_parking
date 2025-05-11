import 'package:dartz/dartz.dart';
import 'package:firebase_parking/core/errors/failures.dart';
import 'package:firebase_parking/domain/entities/user_entity.dart';
import 'package:firebase_parking/domain/repositories/auth_repository.dart';

class SignInUseCase {
  final AuthRepository repository;

  SignInUseCase(this.repository);

  // The call method makes the class callable like a function
  Future<Either<Failure, UserEntity>> call(String email, String password) {
    // This is where business logic would go if needed
    return repository.signIn(email, password);
  }
}
