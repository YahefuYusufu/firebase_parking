// lib/domain/repositories/parking_repository.dart
import 'package:firebase_parking/domain/entities/parking_entity.dart';

abstract class ParkingRepository {
  // Existing methods
  Future<ParkingEntity> createParking(ParkingEntity parking, String vehicleId, String parkingSpaceId);
  Future<ParkingEntity?> getParking(String parkingId);
  Future<List<ParkingEntity>> getActiveParking();
  Future<List<ParkingEntity>> getUserParking(String userId);
  Future<ParkingEntity> endParking(String parkingId);

  // NEW: Extension-related methods
  Future<ParkingEntity> extendParking(String parkingId, Duration additionalTime, double cost, {String? reason});

  Future<List<ParkingExtension>> getParkingExtensions(String parkingId);
  Future<bool> canExtendParking(String parkingId);
  Future<Duration> getParkingTimeRemaining(String parkingId);
}
