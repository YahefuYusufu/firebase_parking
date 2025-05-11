// lib/domain/repositories/auth_repository.dart
import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> signIn(String email, String password);
  Future<Either<Failure, UserEntity>> signUp(String email, String password);
  Future<Either<Failure, void>> signOut();
  Stream<UserEntity?> authStateChanges();
  UserEntity? getCurrentUser();
  Future<Either<Failure, UserEntity>> updateUserProfile({required String userId, String? name, String? personalNumber, List<String>? vehicleIds});
}
