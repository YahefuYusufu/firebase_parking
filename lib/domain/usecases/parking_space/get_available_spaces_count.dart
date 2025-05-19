import 'package:dartz/dartz.dart';
import 'package:firebase_parking/core/usecase/usecase.dart';
import '../../../core/errors/failures.dart';
import '../../../domain/repositories/parking_space_repository.dart';

class GetAvailableSpacesCount implements UseCase<int, NoParams> {
  final ParkingSpaceRepository repository;

  GetAvailableSpacesCount(this.repository);

  @override
  Future<Either<Failure, int>> call(NoParams params) async {
    return await repository.getAvailableSpacesCount();
  }
}
