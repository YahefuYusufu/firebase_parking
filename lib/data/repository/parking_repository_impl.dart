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

      // Create a parking model from the entity
      final parkingModel = ParkingModel(vehicle: vehicle, parkingSpace: parkingSpace, startedAt: parking.startedAt, finishedAt: parking.finishedAt);

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
    final parkingModel = await parkingDataSource.getParking(parkingId);
    return parkingModel?.toEntity();
  }

  @override
  Future<List<ParkingEntity>> getActiveParking() async {
    final parkingModels = await parkingDataSource.getActiveParking();
    return parkingModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<ParkingEntity>> getUserParking(String userId) async {
    final parkingModels = await parkingDataSource.getUserParking(userId);
    return parkingModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<ParkingEntity> endParking(String parkingId) async {
    final parkingModel = await parkingDataSource.endParking(parkingId);
    return parkingModel.toEntity();
  }
}
