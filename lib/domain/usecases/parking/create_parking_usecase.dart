import 'package:firebase_parking/domain/entities/parking_entity.dart';
import 'package:firebase_parking/domain/repositories/parking_repository.dart';

class CreateParkingUseCase {
  final ParkingRepository repository;

  CreateParkingUseCase(this.repository);

  Future<ParkingEntity> call(String vehicleId, String parkingSpaceId) async {
    final parking = ParkingEntity(startedAt: DateTime.now(), vehicleId: vehicleId, parkingSpaceId: parkingSpaceId);

    return repository.createParking(parking, vehicleId, parkingSpaceId);
  }
}
