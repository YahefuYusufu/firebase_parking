// lib/data/repositories/parking_space_repository_impl.dart
// ignore_for_file: avoid_print
import 'package:dartz/dartz.dart';
import 'package:firebase_parking/data/models/parking_space/parking_space_model.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/parking_space_entity.dart';
import '../../domain/repositories/parking_space_repository.dart';
import '../datasources/parking_space_remote_datasource.dart';

class ParkingSpaceRepositoryImpl implements ParkingSpaceRepository {
  final ParkingSpaceRemoteDataSource remoteDataSource;

  ParkingSpaceRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<ParkingSpaceEntity>>> getAllParkingSpaces() async {
    try {
      final spaceModels = await remoteDataSource.getAllParkingSpaces();
      final spaceEntities = spaceModels.map((model) => model.toEntity()).toList();
      return Right(spaceEntities);
    } catch (e) {
      print("ParkingSpaceRepository: Error getting all spaces: $e");
      return Left(ParkingSpaceFailure('get-all-failed', 'Failed to fetch parking spaces: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<ParkingSpaceEntity>>> getParkingSpacesByStatus(ParkingSpaceStatus status) async {
    try {
      final spaceModels = await remoteDataSource.getParkingSpacesByStatus(status.name);
      final spaceEntities = spaceModels.map((model) => model.toEntity()).toList();
      return Right(spaceEntities);
    } catch (e) {
      print("ParkingSpaceRepository: Error getting spaces by status: $e");
      return Left(ParkingSpaceFailure('get-by-status-failed', 'Failed to fetch spaces by status: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<ParkingSpaceEntity>>> getParkingSpacesBySection(String section) async {
    try {
      final spaceModels = await remoteDataSource.getParkingSpacesBySection(section);
      final spaceEntities = spaceModels.map((model) => model.toEntity()).toList();
      return Right(spaceEntities);
    } catch (e) {
      print("ParkingSpaceRepository: Error getting spaces by section: $e");
      return Left(ParkingSpaceFailure('get-by-section-failed', 'Failed to fetch spaces by section: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<ParkingSpaceEntity>>> getParkingSpacesByLevel(String level) async {
    try {
      final spaceModels = await remoteDataSource.getParkingSpacesByLevel(level);
      final spaceEntities = spaceModels.map((model) => model.toEntity()).toList();
      return Right(spaceEntities);
    } catch (e) {
      print("ParkingSpaceRepository: Error getting spaces by level: $e");
      return Left(ParkingSpaceFailure('get-by-level-failed', 'Failed to fetch spaces by level: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, ParkingSpaceEntity>> getParkingSpaceById(String spaceId) async {
    try {
      final spaceModel = await remoteDataSource.getParkingSpaceById(spaceId);
      return Right(spaceModel.toEntity());
    } catch (e) {
      print("ParkingSpaceRepository: Error getting space by ID: $e");
      return Left(ParkingSpaceFailure('get-by-id-failed', 'Failed to fetch parking space: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, ParkingSpaceEntity>> getParkingSpaceByNumber(String spaceNumber) async {
    try {
      final spaceModel = await remoteDataSource.getParkingSpaceByNumber(spaceNumber);
      return Right(spaceModel.toEntity());
    } catch (e) {
      print("ParkingSpaceRepository: Error getting space by number: $e");
      return Left(ParkingSpaceFailure('get-by-number-failed', 'Failed to fetch parking space: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, ParkingSpaceEntity>> updateParkingSpace(ParkingSpaceEntity space) async {
    try {
      // Convert entity to model
      final spaceModel = ParkingSpaceModel.fromEntity(space);

      // Update space
      final result = await remoteDataSource.updateParkingSpace(spaceModel);

      // Convert back to entity
      return Right(result.toEntity());
    } catch (e) {
      print("ParkingSpaceRepository: Error updating space: $e");
      return Left(ParkingSpaceFailure('update-failed', 'Failed to update parking space: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, ParkingSpaceEntity>> occupyParkingSpace(String spaceId, String vehicleId) async {
    try {
      final result = await remoteDataSource.occupyParkingSpace(spaceId, vehicleId);
      return Right(result.toEntity());
    } catch (e) {
      print("ParkingSpaceRepository: Error occupying space: $e");
      return Left(ParkingSpaceFailure('occupy-failed', 'Failed to occupy parking space: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, ParkingSpaceEntity>> vacateParkingSpace(String spaceId) async {
    try {
      final result = await remoteDataSource.vacateParkingSpace(spaceId);
      return Right(result.toEntity());
    } catch (e) {
      print("ParkingSpaceRepository: Error vacating space: $e");
      return Left(ParkingSpaceFailure('vacate-failed', 'Failed to vacate parking space: ${e.toString()}'));
    }
  }

  @override
  Stream<Either<Failure, List<ParkingSpaceEntity>>> watchParkingSpaces() {
    try {
      return remoteDataSource
          .watchParkingSpaces()
          .map<Either<Failure, List<ParkingSpaceEntity>>>((spaceModels) {
            final spaceEntities = spaceModels.map((model) => model.toEntity()).toList();
            return Right(spaceEntities);
          })
          .handleError((error) {
            print("ParkingSpaceRepository: Error in spaces stream: $error");
            return Left(ParkingSpaceFailure('stream-failed', 'Failed to watch parking spaces: ${error.toString()}'));
          });
    } catch (e) {
      print("ParkingSpaceRepository: Error setting up spaces stream: $e");
      return Stream.value(Left(ParkingSpaceFailure('stream-failed', 'Failed to watch parking spaces: ${e.toString()}')));
    }
  }

  @override
  Future<Either<Failure, int>> getAvailableSpacesCount() async {
    try {
      final count = await remoteDataSource.getAvailableSpacesCount();
      return Right(count);
    } catch (e) {
      print("ParkingSpaceRepository: Error getting available count: $e");
      return Left(ParkingSpaceFailure('count-failed', 'Failed to get available spaces count: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, ParkingSpaceEntity?>> getSpaceByVehicleId(String vehicleId) async {
    try {
      final spaceModel = await remoteDataSource.getSpaceByVehicleId(vehicleId);
      if (spaceModel == null) {
        return const Right(null);
      }
      return Right(spaceModel.toEntity());
    } catch (e) {
      print("ParkingSpaceRepository: Error getting space by vehicle: $e");
      return Left(ParkingSpaceFailure('get-by-vehicle-failed', 'Failed to find parking space: ${e.toString()}'));
    }
  }
}

// Parking Space specific failure class
class ParkingSpaceFailure extends Failure {
  final String code;

  const ParkingSpaceFailure(this.code, String message) : super(message);
}
