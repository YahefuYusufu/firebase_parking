// lib/data/repositories/vehicle_repository_impl.dart
// ignore_for_file: avoid_print

import 'package:dartz/dartz.dart';
import 'package:firebase_parking/data/models/vehicles/vehicle_model.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/vehicle_entity.dart';
import '../../domain/repositories/vehicle_repository.dart';
import '../datasources/vehicle_remote_datasource.dart';

class VehicleRepositoryImpl implements VehicleRepository {
  final VehicleRemoteDataSource remoteDataSource;

  VehicleRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, VehicleEntity>> addVehicle(VehicleEntity vehicle) async {
    try {
      // Convert entity to model
      final vehicleModel = VehicleModel.fromEntity(vehicle);

      // Check if registration already exists
      final exists = await remoteDataSource.checkRegistrationExists(vehicle.registrationNumber);
      if (exists) {
        return Left(VehicleFailure('registration-exists', 'A vehicle with this registration number already exists'));
      }

      // Add vehicle
      final result = await remoteDataSource.addVehicle(vehicleModel);

      // Convert back to entity
      return Right(result.toEntity());
    } catch (e) {
      print("VehicleRepository: Error adding vehicle: $e");
      return Left(VehicleFailure('add-failed', 'Failed to add vehicle: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<VehicleEntity>>> getUserVehicles(String userId) async {
    try {
      final vehicleModels = await remoteDataSource.getUserVehicles(userId);
      final vehicleEntities = vehicleModels.map((model) => model.toEntity()).toList();
      return Right(vehicleEntities);
    } catch (e) {
      print("VehicleRepository: Error fetching user vehicles: $e");
      return Left(VehicleFailure('fetch-failed', 'Failed to fetch vehicles: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, VehicleEntity>> getVehicleById(String vehicleId) async {
    try {
      final vehicleModel = await remoteDataSource.getVehicleById(vehicleId);
      return Right(vehicleModel.toEntity());
    } catch (e) {
      print("VehicleRepository: Error fetching vehicle: $e");
      return Left(VehicleFailure('fetch-failed', 'Failed to fetch vehicle: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, VehicleEntity>> updateVehicle(VehicleEntity vehicle) async {
    try {
      if (vehicle.id == null) {
        return Left(VehicleFailure('invalid-id', 'Vehicle ID is required for update'));
      }

      // Check if changing registration number
      final existingVehicle = await remoteDataSource.getVehicleById(vehicle.id!);
      if (existingVehicle.registrationNumber != vehicle.registrationNumber) {
        // Check if new registration already exists
        final exists = await remoteDataSource.checkRegistrationExists(vehicle.registrationNumber);
        if (exists) {
          return Left(VehicleFailure('registration-exists', 'A vehicle with this registration number already exists'));
        }
      }

      // Convert entity to model
      final vehicleModel = VehicleModel.fromEntity(vehicle);

      // Update vehicle
      final result = await remoteDataSource.updateVehicle(vehicleModel);

      // Convert back to entity
      return Right(result.toEntity());
    } catch (e) {
      print("VehicleRepository: Error updating vehicle: $e");
      return Left(VehicleFailure('update-failed', 'Failed to update vehicle: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteVehicle(String vehicleId) async {
    try {
      await remoteDataSource.deleteVehicle(vehicleId);
      return const Right(null);
    } catch (e) {
      print("VehicleRepository: Error deleting vehicle: $e");
      return Left(VehicleFailure('delete-failed', 'Failed to delete vehicle: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> checkRegistrationExists(String registrationNumber) async {
    try {
      final exists = await remoteDataSource.checkRegistrationExists(registrationNumber);
      return Right(exists);
    } catch (e) {
      print("VehicleRepository: Error checking registration: $e");
      return Left(VehicleFailure('check-failed', 'Failed to check registration: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<VehicleEntity>>> searchVehiclesByRegistration(String query) async {
    try {
      final vehicleModels = await remoteDataSource.searchVehiclesByRegistration(query);
      final vehicleEntities = vehicleModels.map((model) => model.toEntity()).toList();
      return Right(vehicleEntities);
    } catch (e) {
      print("VehicleRepository: Error searching vehicles: $e");
      return Left(VehicleFailure('search-failed', 'Failed to search vehicles: ${e.toString()}'));
    }
  }

  @override
  Stream<Either<Failure, List<VehicleEntity>>> watchUserVehicles(String userId) {
    try {
      return remoteDataSource
          .watchUserVehicles(userId)
          .map<Either<Failure, List<VehicleEntity>>>((vehicleModels) {
            final vehicleEntities = vehicleModels.map((model) => model.toEntity()).toList();
            return Right(vehicleEntities);
          })
          .handleError((error) {
            print("VehicleRepository: Error in vehicle stream: $error");
            return Left<Failure, List<VehicleEntity>>(VehicleFailure('stream-failed', 'Failed to watch vehicles: ${error.toString()}'));
          });
    } catch (e) {
      print("VehicleRepository: Error setting up vehicle stream: $e");
      return Stream.value(Left<Failure, List<VehicleEntity>>(VehicleFailure('stream-failed', 'Failed to watch vehicles: ${e.toString()}')));
    }
  }
}

// Vehicle-specific failure class
class VehicleFailure extends Failure {
  final String code;

  const VehicleFailure(this.code, String message) : super(message);
}
