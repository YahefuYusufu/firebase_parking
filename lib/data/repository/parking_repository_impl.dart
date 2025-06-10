// lib/data/repositories/parking_repository_impl.dart
import 'package:firebase_parking/data/datasources/parking_data_source.dart';
import 'package:firebase_parking/data/datasources/parking_space_remote_datasource.dart';
import 'package:firebase_parking/data/datasources/vehicle_remote_datasource.dart';
import 'package:firebase_parking/data/models/parking/parking_model.dart';
import 'package:firebase_parking/domain/entities/parking_entity.dart';
import 'package:firebase_parking/domain/repositories/parking_repository.dart';

class ParkingRepositoryImpl implements ParkingRepository {
  final ParkingDataSource parkingDataSource;
  final VehicleRemoteDataSource vehicleDataSource;
  final ParkingSpaceRemoteDataSource parkingSpaceDataSource;

  ParkingRepositoryImpl({required this.parkingDataSource, required this.vehicleDataSource, required this.parkingSpaceDataSource});

  @override
  Future<ParkingEntity> createParking(ParkingEntity parking, String vehicleId, String parkingSpaceId) async {
    try {
      // Fetch the vehicle
      final vehicle = await vehicleDataSource.getVehicleById(vehicleId);

      // Fetch the parking space
      final parkingSpace = await parkingSpaceDataSource.getParkingSpaceById(parkingSpaceId);

      // Check if the parking space is vacant
      if (parkingSpace.status.toLowerCase() != 'vacant') {
        throw Exception('Parking space is not available');
      }

      // Create a parking model from the entity with all required fields
      final parkingModel = ParkingModel(
        vehicle: vehicle,
        parkingSpace: parkingSpace,
        startedAt: parking.startedAt,
        finishedAt: parking.finishedAt,
        originalTimeLimit: parking.originalTimeLimit, // NEW: Required field
        extensions: parking.extensions.map((e) => ParkingExtensionModel.fromEntity(e)).toList(), // NEW: Extensions
      );

      // Create the parking record
      final createdParking = await parkingDataSource.createParking(parkingModel);

      // Return the entity
      return createdParking.toEntity();
    } catch (e) {
      throw Exception('Failed to create parking: ${e.toString()}');
    }
  }

  @override
  Future<ParkingEntity?> getParking(String parkingId) async {
    try {
      final parkingModel = await parkingDataSource.getParking(parkingId);
      return parkingModel?.toEntity();
    } catch (e) {
      throw Exception('Failed to get parking: ${e.toString()}');
    }
  }

  @override
  Future<List<ParkingEntity>> getActiveParking() async {
    try {
      final parkingModels = await parkingDataSource.getActiveParking();
      return parkingModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to get active parking: ${e.toString()}');
    }
  }

  @override
  Future<List<ParkingEntity>> getUserParking(String userId) async {
    try {
      final parkingModels = await parkingDataSource.getUserParking(userId);
      return parkingModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to get user parking: ${e.toString()}');
    }
  }

  @override
  Future<ParkingEntity> endParking(String parkingId) async {
    try {
      final parkingModel = await parkingDataSource.endParking(parkingId);
      return parkingModel.toEntity();
    } catch (e) {
      throw Exception('Failed to end parking: ${e.toString()}');
    }
  }

  // NEW: Method to extend parking
  @override
  Future<ParkingEntity> extendParking(String parkingId, Duration additionalTime, double cost, {String? reason}) async {
    try {
      // Get current parking
      final currentParking = await parkingDataSource.getParking(parkingId);
      if (currentParking == null) {
        throw Exception('Parking not found');
      }

      // Check if parking can be extended
      final entity = currentParking.toEntity();
      if (!entity.canExtend) {
        throw Exception('Cannot extend parking: session has expired beyond grace period');
      }

      // Create extended parking model
      final extendedModel = currentParking.extend(additionalTime: additionalTime, cost: cost, reason: reason);

      // Update in database
      final updatedParking = await parkingDataSource.updateParking(extendedModel);

      return updatedParking.toEntity();
    } catch (e) {
      throw Exception('Failed to extend parking: ${e.toString()}');
    }
  }

  // NEW: Method to get parking extensions
  @override
  Future<List<ParkingExtension>> getParkingExtensions(String parkingId) async {
    try {
      final parkingModel = await parkingDataSource.getParking(parkingId);
      if (parkingModel == null) {
        throw Exception('Parking not found');
      }

      return parkingModel.extensions.map((e) => e.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to get parking extensions: ${e.toString()}');
    }
  }

  // NEW: Method to check if parking can be extended
  @override
  Future<bool> canExtendParking(String parkingId) async {
    try {
      final parkingModel = await parkingDataSource.getParking(parkingId);
      if (parkingModel == null) {
        return false;
      }

      return parkingModel.toEntity().canExtend;
    } catch (e) {
      return false;
    }
  }

  // NEW: Method to get parking time remaining
  @override
  Future<Duration> getParkingTimeRemaining(String parkingId) async {
    try {
      final parkingModel = await parkingDataSource.getParking(parkingId);
      if (parkingModel == null) {
        throw Exception('Parking not found');
      }

      return parkingModel.toEntity().timeRemaining;
    } catch (e) {
      throw Exception('Failed to get parking time remaining: ${e.toString()}');
    }
  }
}
