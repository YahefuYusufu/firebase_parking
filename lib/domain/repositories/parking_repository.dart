import 'package:firebase_parking/domain/entities/parking_entity.dart';

abstract class ParkingRepository {
  Future<ParkingEntity> createParking(ParkingEntity parking, String vehicleId, String parkingSpaceId);
  Future<ParkingEntity?> getParking(String parkingId);
  Future<List<ParkingEntity>> getActiveParking();
  Future<List<ParkingEntity>> getUserParking(String userId);
  Future<ParkingEntity> endParking(String parkingId);
}
