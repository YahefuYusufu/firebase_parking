// lib/data/repositories/parking_repository_impl.dart
import 'package:firebase_parking/data/datasources/parking_data_source.dart';
import 'package:firebase_parking/domain/entities/parking_entity.dart';
import 'package:firebase_parking/domain/repositories/parking_repository.dart';

class ParkingRepositoryImpl implements ParkingRepository {
  final ParkingDataSource dataSource;

  ParkingRepositoryImpl({required this.dataSource});

  @override
  Future<ParkingEntity> createParking(ParkingEntity parking, String vehicleId, String parkingSpaceId) async {
    // This implementation requires that we already have the Vehicle and ParkingSpace objects
    // In a real implementation, you'd need to fetch these first
    throw UnimplementedError('This method needs to be implemented with actual vehicle and space fetching');
  }

  @override
  Future<ParkingEntity?> getParking(String parkingId) async {
    final parkingModel = await dataSource.getParking(parkingId);
    return parkingModel?.toEntity();
  }

  @override
  Future<List<ParkingEntity>> getActiveParking() async {
    final parkingModels = await dataSource.getActiveParking();
    return parkingModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<ParkingEntity>> getUserParking(String userId) async {
    final parkingModels = await dataSource.getUserParking(userId);
    return parkingModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<ParkingEntity> endParking(String parkingId) async {
    final parkingModel = await dataSource.endParking(parkingId);
    return parkingModel.toEntity();
  }
}
