import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_parking/core/usecase/usecase.dart';
import '../../../core/errors/failures.dart';
import '../../../domain/entities/parking_space_entity.dart';
import '../../../domain/repositories/parking_space_repository.dart';

class GetParkingSpacesByStatus implements UseCase<List<ParkingSpaceEntity>, GetParkingSpacesByStatusParams> {
  final ParkingSpaceRepository repository;

  GetParkingSpacesByStatus(this.repository);

  @override
  Future<Either<Failure, List<ParkingSpaceEntity>>> call(GetParkingSpacesByStatusParams params) async {
    return await repository.getParkingSpacesByStatus(params.status);
  }
}

class GetParkingSpacesByStatusParams extends Equatable {
  final ParkingSpaceStatus status;

  const GetParkingSpacesByStatusParams({required this.status});

  @override
  List<Object?> get props => [status];
}
