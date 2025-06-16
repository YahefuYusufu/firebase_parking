import 'package:firebase_parking/domain/entities/parking_entity.dart';
import 'package:firebase_parking/domain/repositories/parking_repository.dart';

class CreateParkingUseCase {
  final ParkingRepository repository;

  CreateParkingUseCase(this.repository);

  Future<ParkingEntity> call({
    required String vehicleId,
    required String parkingSpaceId,
    required Duration timeLimit, // Now required
    String? vehicleRegistration,
    String? parkingSpaceNumber,
    double? hourlyRate,
  }) async {
    final parking = ParkingEntity(
      startedAt: DateTime.now(),
      vehicleId: vehicleId,
      parkingSpaceId: parkingSpaceId,
      originalTimeLimit: timeLimit, // Set the time limit
      vehicleRegistration: vehicleRegistration,
      parkingSpaceNumber: parkingSpaceNumber,
      hourlyRate: hourlyRate,
    );

    return repository.createParking(parking, vehicleId, parkingSpaceId);
  }

  // Convenience methods for common durations
  Future<ParkingEntity> createOneHour({required String vehicleId, required String parkingSpaceId, String? vehicleRegistration, String? parkingSpaceNumber, double? hourlyRate}) {
    return call(
      vehicleId: vehicleId,
      parkingSpaceId: parkingSpaceId,
      timeLimit: const Duration(hours: 1),
      vehicleRegistration: vehicleRegistration,
      parkingSpaceNumber: parkingSpaceNumber,
      hourlyRate: hourlyRate,
    );
  }

  Future<ParkingEntity> createTwoHours({required String vehicleId, required String parkingSpaceId, String? vehicleRegistration, String? parkingSpaceNumber, double? hourlyRate}) {
    return call(
      vehicleId: vehicleId,
      parkingSpaceId: parkingSpaceId,
      timeLimit: const Duration(hours: 2),
      vehicleRegistration: vehicleRegistration,
      parkingSpaceNumber: parkingSpaceNumber,
      hourlyRate: hourlyRate,
    );
  }

  Future<ParkingEntity> createFourHours({required String vehicleId, required String parkingSpaceId, String? vehicleRegistration, String? parkingSpaceNumber, double? hourlyRate}) {
    return call(
      vehicleId: vehicleId,
      parkingSpaceId: parkingSpaceId,
      timeLimit: const Duration(hours: 4),
      vehicleRegistration: vehicleRegistration,
      parkingSpaceNumber: parkingSpaceNumber,
      hourlyRate: hourlyRate,
    );
  }

  Future<ParkingEntity> createCustomDuration({
    required String vehicleId,
    required String parkingSpaceId,
    required int hours,
    int minutes = 0,
    String? vehicleRegistration,
    String? parkingSpaceNumber,
    double? hourlyRate,
  }) {
    return call(
      vehicleId: vehicleId,
      parkingSpaceId: parkingSpaceId,
      timeLimit: Duration(hours: hours, minutes: minutes),
      vehicleRegistration: vehicleRegistration,
      parkingSpaceNumber: parkingSpaceNumber,
      hourlyRate: hourlyRate,
    );
  }
}
