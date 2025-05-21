import 'package:firebase_parking/domain/entities/parking_entity.dart';
import 'package:firebase_parking/domain/repositories/parking_repository.dart';

class EndParkingUseCase {
  final ParkingRepository repository;

  EndParkingUseCase(this.repository);

  Future<ParkingEntity> call(String parkingId) async {
    return repository.endParking(parkingId);
  }
}
