import 'package:firebase_parking/domain/entities/parking_entity.dart';
import 'package:firebase_parking/domain/repositories/parking_repository.dart';

class GetActiveParkingUseCase {
  final ParkingRepository repository;

  GetActiveParkingUseCase(this.repository);

  Future<List<ParkingEntity>> call() async {
    return repository.getActiveParking();
  }
}
