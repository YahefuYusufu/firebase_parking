// lib/data/repositories/auth_repository_impl.dart
// ignore_for_file: avoid_print

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
      print("AuthRepositoryImpl: Signing in with email: $email");
      final userModel = await remoteDataSource.signInWithEmailAndPassword(email, password);
      print("AuthRepositoryImpl: Sign in successful, user: $userModel");
      return Right(userModel.toEntity());
    } on FirebaseAuthException catch (e) {
      print("AuthRepositoryImpl: Firebase Auth exception during sign in: ${e.code} - ${e.message}");
      return Left(AuthFailure(e.code, e.message ?? 'Authentication failed'));
    } catch (e) {
      print("AuthRepositoryImpl: Unknown exception during sign in: $e");
      return Left(AuthFailure('unknown', e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signUp(String email, String password) async {
    try {
      print("AuthRepositoryImpl: Creating account with email: $email");
      final userModel = await remoteDataSource.createUserWithEmailAndPassword(email, password);
      print("AuthRepositoryImpl: Account creation successful, user: $userModel");
      return Right(userModel.toEntity());
    } on FirebaseAuthException catch (e) {
      print("AuthRepositoryImpl: Firebase Auth exception during sign up: ${e.code} - ${e.message}");
      return Left(AuthFailure(e.code, e.message ?? 'Registration failed'));
    } catch (e) {
      print("AuthRepositoryImpl: Unknown exception during sign up: $e");
      return Left(AuthFailure('unknown', e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      print("AuthRepositoryImpl: Signing out");
      await remoteDataSource.signOut();
      print("AuthRepositoryImpl: Sign out successful");
      return const Right(null);
    } catch (e) {
      print("AuthRepositoryImpl: Error during sign out: $e");
      return Left(AuthFailure('sign-out-failed', 'Failed to sign out'));
    }
  }

  @override
  Stream<UserEntity?> authStateChanges() {
    print("AuthRepositoryImpl: Setting up auth state changes stream");
    return remoteDataSource.authStateChanges().map((userModel) {
      print("AuthRepositoryImpl: Auth state changed, user: $userModel");
      return userModel?.toEntity();
    });
  }

  @override
  UserEntity? getCurrentUser() {
    try {
      print("AuthRepositoryImpl: Getting current user (sync)");
      final userModel = remoteDataSource.getCurrentUser();

      print("AuthRepositoryImpl: Current user: $userModel");
      if (userModel != null) {
        print("AuthRepositoryImpl: User details - name: ${userModel.name}, personNumber: ${userModel.personalNumber}");

        // Try to determine if profile is complete
        final hasName = userModel.name != null && userModel.name!.isNotEmpty;
        final hasPersonalNumber = userModel.personalNumber != null && userModel.personalNumber!.isNotEmpty;
        print("AuthRepositoryImpl: Profile complete check - hasName: $hasName, hasPersonalNumber: $hasPersonalNumber");
      }

      return userModel?.toEntity();
    } catch (e) {
      print("AuthRepositoryImpl: Error getting current user: $e");
      return null;
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getUserProfile(String userId) async {
    try {
      print("AuthRepositoryImpl: Getting full user profile for ID: $userId");

      // Use the data source to get full profile including Firestore data
      final userModel = await remoteDataSource.getUserProfile(userId);

      print("AuthRepositoryImpl: Retrieved full profile: $userModel");
      return Right(userModel.toEntity());
    } catch (e) {
      print("AuthRepositoryImpl: Error getting user profile: $e");
      return Left(AuthFailure('profile-fetch-failed', e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateUserProfile({required String userId, String? name, String? personalNumber, List<String>? vehicleIds}) async {
    try {
      print("AuthRepositoryImpl: Updating profile for user: $userId");
      print("AuthRepositoryImpl: New data - name: $name, personalNumber: $personalNumber");

      // Get current user model
      final currentUser = remoteDataSource.getCurrentUser();
      if (currentUser == null || currentUser.id != userId) {
        print("AuthRepositoryImpl: User not authenticated for profile update");
        return Left(AuthFailure('not-authenticated', 'User not authenticated'));
      }

      // Update with new data
      final updatedUser = currentUser.copyWith(name: name, personalNumber: personalNumber, vehicleIds: vehicleIds);
      print("AuthRepositoryImpl: Prepared updated user: $updatedUser");

      // Save to remote
      final result = await remoteDataSource.updateUserProfile(updatedUser);
      print("AuthRepositoryImpl: Profile updated successfully: $result");

      return Right(result.toEntity());
    } catch (e) {
      print("AuthRepositoryImpl: Error updating profile: $e");
      return Left(AuthFailure('profile-update-failed', e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateProfilePicture({required String userId, required String filePath}) async {
    try {
      print("AuthRepositoryImpl: Updating profile picture for user: $userId");
      print("AuthRepositoryImpl: Using file at path: $filePath");

      // Get the current user data
      final currentUser = remoteDataSource.getCurrentUser();
      if (currentUser == null || currentUser.id != userId) {
        print("AuthRepositoryImpl: User not authenticated for profile picture update");
        return Left(AuthFailure('not-authenticated', 'User not authenticated'));
      }

      // Call data source to upload image and update profile
      final result = await remoteDataSource.updateProfilePicture(userId, filePath);
      print("AuthRepositoryImpl: Profile picture updated successfully: $result");

      return Right(result.toEntity());
    } catch (e) {
      print("AuthRepositoryImpl: Error updating profile picture: $e");
      return Left(AuthFailure('profile-picture-update-failed', e.toString()));
    }
  }

  @override
  bool hasCompleteProfile() {
    final user = getCurrentUser();
    if (user == null) return false;

    final hasName = user.name != null && user.name!.isNotEmpty;
    final hasPersonalNumber = user.personalNumber != null && user.personalNumber!.isNotEmpty;

    print("hasCompleteProfile check - hasName: $hasName, hasPersonalNumber: $hasPersonalNumber");
    return hasName && hasPersonalNumber;
  }

  @override
  Future<Either<Failure, UserEntity>> refreshUserProfile() async {
    try {
      final currentUser = remoteDataSource.getCurrentUser();
      if (currentUser == null) {
        print("refreshUserProfile: No current user found");
        return Left(AuthFailure('not-authenticated', 'User not authenticated'));
      }

      print("refreshUserProfile: Refreshing profile for user ID: ${currentUser.id}");
      final fullProfile = await remoteDataSource.getUserProfile(currentUser.id!);
      print("refreshUserProfile: Retrieved full profile: $fullProfile");

      return Right(fullProfile.toEntity());
    } catch (e) {
      print("refreshUserProfile: Error refreshing user profile: $e");
      return Left(AuthFailure('profile-refresh-failed', e.toString()));
    }
  }
}
