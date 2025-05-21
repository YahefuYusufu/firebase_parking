import 'package:firebase_parking/domain/entities/parking_entity.dart';
import 'package:firebase_parking/domain/repositories/parking_repository.dart';

class GetParkingUseCase {
  final ParkingRepository repository;

  GetParkingUseCase(this.repository);

  Future<ParkingEntity?> call(String parkingId) async {
    return repository.getParking(parkingId);
  }
}
