import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_parking/core/usecase/usecase.dart';
import '../../../core/errors/failures.dart';
import '../../../domain/entities/parking_space_entity.dart';
import '../../../domain/repositories/parking_space_repository.dart';

class GetParkingSpacesByLevel implements UseCase<List<ParkingSpaceEntity>, GetParkingSpacesByLevelParams> {
  final ParkingSpaceRepository repository;

  GetParkingSpacesByLevel(this.repository);

  @override
  Future<Either<Failure, List<ParkingSpaceEntity>>> call(GetParkingSpacesByLevelParams params) async {
    return await repository.getParkingSpacesByLevel(params.level);
  }
}

class GetParkingSpacesByLevelParams extends Equatable {
  final String level;

  const GetParkingSpacesByLevelParams({required this.level});

  @override
  List<Object?> get props => [level];
}
