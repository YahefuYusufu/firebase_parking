import 'package:firebase_parking/domain/entities/user_entity.dart';
import 'package:firebase_parking/domain/repositories/auth_repository.dart';

class GetCurrentUserUseCase {
  final AuthRepository repository;

  GetCurrentUserUseCase(this.repository);

  // This one returns directly, not a Future
  UserEntity? call() {
    return repository.getCurrentUser();
  }
}
