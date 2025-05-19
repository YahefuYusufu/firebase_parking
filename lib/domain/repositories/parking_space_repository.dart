import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/parking_space_entity.dart';

abstract class ParkingSpaceRepository {
  // Create a new parking space
  Future<Either<Failure, ParkingSpaceEntity>> createParkingSpace(ParkingSpaceEntity space);

  // Get all parking spaces
  Future<Either<Failure, List<ParkingSpaceEntity>>> getAllParkingSpaces();

  // Get parking spaces by status
  Future<Either<Failure, List<ParkingSpaceEntity>>> getParkingSpacesByStatus(ParkingSpaceStatus status);

  // Get parking spaces by section
  Future<Either<Failure, List<ParkingSpaceEntity>>> getParkingSpacesBySection(String section);

  // Get parking spaces by level
  Future<Either<Failure, List<ParkingSpaceEntity>>> getParkingSpacesByLevel(String level);

  // Get a specific parking space by ID
  Future<Either<Failure, ParkingSpaceEntity>> getParkingSpaceById(String spaceId);

  // Get parking space by space number
  Future<Either<Failure, ParkingSpaceEntity>> getParkingSpaceByNumber(String spaceNumber);

  // Update parking space (for admin)
  Future<Either<Failure, ParkingSpaceEntity>> updateParkingSpace(ParkingSpaceEntity space);

  // Delete a parking space
  Future<Either<Failure, void>> deleteParkingSpace(String spaceId);

  // Occupy a parking space
  Future<Either<Failure, ParkingSpaceEntity>> occupyParkingSpace(String spaceId, String vehicleId);

  // Vacate a parking space
  Future<Either<Failure, ParkingSpaceEntity>> vacateParkingSpace(String spaceId);

  // Stream of parking spaces for real-time updates
  Stream<Either<Failure, List<ParkingSpaceEntity>>> watchParkingSpaces();

  // Get available spaces count
  Future<Either<Failure, int>> getAvailableSpacesCount();

  // Get occupied spaces by vehicle ID
  Future<Either<Failure, ParkingSpaceEntity?>> getSpaceByVehicleId(String vehicleId);
}
