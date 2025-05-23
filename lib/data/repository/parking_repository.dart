// lib/domain/repositories/parking_repository.dart
import 'package:dartz/dartz.dart';
import 'package:firebase_parking/core/errors/failures.dart';
import 'package:firebase_parking/domain/entities/parking_entity.dart';

abstract class ParkingRepository {
  Future<Either<Failure, ParkingEntity>> createParking(ParkingEntity parking, String vehicleId, String parkingSpaceId);
  Future<Either<Failure, ParkingEntity?>> getParking(String parkingId);
  Future<Either<Failure, List<ParkingEntity>>> getActiveParking();
  Future<Either<Failure, List<ParkingEntity>>> getUserParking(String userId);
  Future<Either<Failure, ParkingEntity>> endParking(String parkingId);
}
