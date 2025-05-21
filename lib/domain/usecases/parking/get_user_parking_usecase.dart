import 'package:firebase_parking/domain/entities/parking_entity.dart';
import 'package:firebase_parking/domain/repositories/parking_repository.dart';

class GetUserParkingUseCase {
  final ParkingRepository repository;

  GetUserParkingUseCase(this.repository);

  Future<List<ParkingEntity>> call(String userId) async {
    return repository.getUserParking(userId);
  }
}
