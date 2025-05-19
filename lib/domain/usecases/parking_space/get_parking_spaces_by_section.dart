import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_parking/core/usecase/usecase.dart';
import '../../../core/errors/failures.dart';
import '../../../domain/entities/parking_space_entity.dart';
import '../../../domain/repositories/parking_space_repository.dart';

class GetParkingSpacesBySection implements UseCase<List<ParkingSpaceEntity>, GetParkingSpacesBySectionParams> {
  final ParkingSpaceRepository repository;

  GetParkingSpacesBySection(this.repository);

  @override
  Future<Either<Failure, List<ParkingSpaceEntity>>> call(GetParkingSpacesBySectionParams params) async {
    return await repository.getParkingSpacesBySection(params.section);
  }
}

class GetParkingSpacesBySectionParams extends Equatable {
  final String section;

  const GetParkingSpacesBySectionParams({required this.section});

  @override
  List<Object?> get props => [section];
}
