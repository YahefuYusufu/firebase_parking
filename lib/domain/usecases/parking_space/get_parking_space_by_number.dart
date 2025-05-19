import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_parking/core/usecase/usecase.dart';
import '../../../core/errors/failures.dart';
import '../../../domain/entities/parking_space_entity.dart';
import '../../../domain/repositories/parking_space_repository.dart';

class GetParkingSpaceByNumber implements UseCase<ParkingSpaceEntity, GetParkingSpaceByNumberParams> {
  final ParkingSpaceRepository repository;

  GetParkingSpaceByNumber(this.repository);

  @override
  Future<Either<Failure, ParkingSpaceEntity>> call(GetParkingSpaceByNumberParams params) async {
    return await repository.getParkingSpaceByNumber(params.spaceNumber);
  }
}

class GetParkingSpaceByNumberParams extends Equatable {
  final String spaceNumber;

  const GetParkingSpaceByNumberParams({required this.spaceNumber});

  @override
  List<Object?> get props => [spaceNumber];
}
