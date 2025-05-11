// lib/domain/repositories/auth_repository.dart
import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/user_entity.dart';

/// Repository interface for authentication operations
abstract class AuthRepository {
  /// Sign in with email and password
  ///
  /// Returns a UserEntity on success or Failure on error
  Future<Either<Failure, UserEntity>> signIn(String email, String password);

  /// Sign up with email and password
  ///
  /// Returns a UserEntity representing the newly created user or Failure on error
  Future<Either<Failure, UserEntity>> signUp(String email, String password);

  /// Sign out the current user
  ///
  /// Returns void on success or Failure on error
  Future<Either<Failure, void>> signOut();

  /// Get a stream of authentication state changes
  ///
  /// Emits UserEntity when user signs in/out or profile changes
  /// Emits null when the user is signed out
  Stream<UserEntity?> authStateChanges();

  /// Get the current signed-in user synchronously
  ///
  /// Returns UserEntity if a user is signed in, null otherwise
  /// Note: This may not include all Firestore profile data
  UserEntity? getCurrentUser();

  /// Get complete user profile data asynchronously
  ///
  /// Fetches the full user profile including all Firestore data
  /// Returns UserEntity on success or Failure on error
  Future<Either<Failure, UserEntity>> getUserProfile(String userId);

  /// Update the user's profile information
  ///
  /// Parameters:
  /// - userId: The ID of the user to update
  /// - name: Optional new name
  /// - personalNumber: Optional new personal number
  /// - vehicleIds: Optional list of vehicle IDs
  ///
  /// Returns updated UserEntity on success or Failure on error
  Future<Either<Failure, UserEntity>> updateUserProfile({required String userId, String? name, String? personalNumber, List<String>? vehicleIds});

  /// Update user's profile picture by uploading a file
  ///
  /// Parameters:
  /// - userId: The ID of the user to update
  /// - filePath: Local path to the image file
  ///
  /// Returns updated UserEntity on success or Failure on error
  Future<Either<Failure, UserEntity>> updateProfilePicture({required String userId, required String filePath});

  /// Check if the current user has a complete profile
  ///
  /// Returns true if the user is logged in and has all required profile fields
  /// Returns false otherwise
  bool hasCompleteProfile();

  /// Force refresh the user profile data from remote sources
  ///
  /// Useful when you suspect local cache might be out of sync
  /// Returns updated UserEntity on success or Failure on error
  Future<Either<Failure, UserEntity>> refreshUserProfile();
}
