import 'package:dartz/dartz.dart';
import 'package:firebase_parking/core/errors/failures.dart';
import 'package:firebase_parking/domain/entities/user_entity.dart';
import 'package:firebase_parking/domain/repositories/auth_repository.dart';

class UpdateUserProfileUseCase {
  final AuthRepository repository;

  UpdateUserProfileUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call({required String userId, String? name, String? personalNumber, List<String>? vehicleIds}) {
    return repository.updateUserProfile(userId: userId, name: name, personalNumber: personalNumber, vehicleIds: vehicleIds);
  }
}
