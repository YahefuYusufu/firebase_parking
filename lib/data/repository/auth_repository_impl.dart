// lib/data/repository/auth_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, UserEntity>> signIn(String email, String password) async {
    try {
      final userModel = await remoteDataSource.signInWithEmailAndPassword(email, password);
      return Right(userModel.toEntity());
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(e.code, e.message ?? 'Authentication failed'));
    } catch (e) {
      return Left(AuthFailure('unknown', e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signUp(String email, String password) async {
    try {
      final userModel = await remoteDataSource.createUserWithEmailAndPassword(email, password);
      return Right(userModel.toEntity());
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(e.code, e.message ?? 'Registration failed'));
    } catch (e) {
      return Left(AuthFailure('unknown', e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await remoteDataSource.signOut();
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure('sign-out-failed', 'Failed to sign out'));
    }
  }

  @override
  Stream<UserEntity?> authStateChanges() {
    return remoteDataSource.authStateChanges().map((userModel) {
      return userModel?.toEntity();
    });
  }

  @override
  UserEntity? getCurrentUser() {
    final userModel = remoteDataSource.getCurrentUser();
    return userModel?.toEntity();
  }

  @override
  Future<Either<Failure, UserEntity>> updateUserProfile({required String userId, String? name, String? personalNumber, List<String>? vehicleIds}) async {
    try {
      // Get current user model
      final currentUser = remoteDataSource.getCurrentUser();
      if (currentUser == null || currentUser.id != userId) {
        return Left(AuthFailure('not-authenticated', 'User not authenticated'));
      }

      // Update with new data
      final updatedUser = currentUser.copyWith(name: name, personalNumber: personalNumber, vehicleIds: vehicleIds);

      // Save to remote
      final result = await remoteDataSource.updateUserProfile(updatedUser);
      return Right(result.toEntity());
    } catch (e) {
      return Left(AuthFailure('profile-update-failed', e.toString()));
    }
  }
}
