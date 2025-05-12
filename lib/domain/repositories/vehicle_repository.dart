import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/vehicle_entity.dart';

abstract class VehicleRepository {
  // Create a new vehicle
  Future<Either<Failure, VehicleEntity>> addVehicle(VehicleEntity vehicle);

  // Get all vehicles for a specific user
  Future<Either<Failure, List<VehicleEntity>>> getUserVehicles(String userId);

  // Get a specific vehicle by ID
  Future<Either<Failure, VehicleEntity>> getVehicleById(String vehicleId);

  // Update an existing vehicle
  Future<Either<Failure, VehicleEntity>> updateVehicle(VehicleEntity vehicle);

  // Delete a vehicle
  Future<Either<Failure, void>> deleteVehicle(String vehicleId);

  // Check if a registration number already exists
  Future<Either<Failure, bool>> checkRegistrationExists(String registrationNumber);

  // Get vehicles by registration number (search functionality)
  Future<Either<Failure, List<VehicleEntity>>> searchVehiclesByRegistration(String query);

  // Stream of user's vehicles for real-time updates
  Stream<Either<Failure, List<VehicleEntity>>> watchUserVehicles(String userId);
}
