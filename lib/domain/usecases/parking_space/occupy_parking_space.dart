import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_parking/core/usecase/usecase.dart';
import '../../../core/errors/failures.dart';
import '../../../domain/entities/parking_space_entity.dart';
import '../../../domain/repositories/parking_space_repository.dart';

class OccupyParkingSpace implements UseCase<ParkingSpaceEntity, OccupyParkingSpaceParams> {
  final ParkingSpaceRepository repository;

  OccupyParkingSpace(this.repository);

  @override
  Future<Either<Failure, ParkingSpaceEntity>> call(OccupyParkingSpaceParams params) async {
    return await repository.occupyParkingSpace(params.spaceId, params.vehicleId);
  }
}

class OccupyParkingSpaceParams extends Equatable {
  final String spaceId;
  final String vehicleId;

  const OccupyParkingSpaceParams({required this.spaceId, required this.vehicleId});

  @override
  List<Object?> get props => [spaceId, vehicleId];
}
