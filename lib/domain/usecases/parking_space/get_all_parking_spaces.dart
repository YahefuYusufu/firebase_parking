import 'package:dartz/dartz.dart';
import 'package:firebase_parking/domain/usecases/vehicles/usecase.dart';
import '../../../core/errors/failures.dart';
import '../../entities/parking_space_entity.dart';
import '../../repositories/parking_space_repository.dart';

class GetAllParkingSpaces extends UseCase<List<ParkingSpaceEntity>, NoParams> {
  final ParkingSpaceRepository repository;

  GetAllParkingSpaces(this.repository);

  @override
  Future<Either<Failure, List<ParkingSpaceEntity>>> call(NoParams params) async {
    return await repository.getAllParkingSpaces();
  }
}
