import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_parking/core/usecase/usecase.dart';
import '../../../core/errors/failures.dart';
import '../../../domain/entities/parking_space_entity.dart';
import '../../../domain/repositories/parking_space_repository.dart';

class GetParkingSpaceById implements UseCase<ParkingSpaceEntity, GetParkingSpaceByIdParams> {
  final ParkingSpaceRepository repository;

  GetParkingSpaceById(this.repository);

  @override
  Future<Either<Failure, ParkingSpaceEntity>> call(GetParkingSpaceByIdParams params) async {
    return await repository.getParkingSpaceById(params.spaceId);
  }
}

class GetParkingSpaceByIdParams extends Equatable {
  final String spaceId;

  const GetParkingSpaceByIdParams({required this.spaceId});

  @override
  List<Object?> get props => [spaceId];
}
