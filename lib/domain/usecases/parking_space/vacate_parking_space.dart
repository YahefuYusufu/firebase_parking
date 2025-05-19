import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_parking/core/usecase/usecase.dart';
import '../../../core/errors/failures.dart';
import '../../../domain/entities/parking_space_entity.dart';
import '../../../domain/repositories/parking_space_repository.dart';

class VacateParkingSpace implements UseCase<ParkingSpaceEntity, VacateParkingSpaceParams> {
  final ParkingSpaceRepository repository;

  VacateParkingSpace(this.repository);

  @override
  Future<Either<Failure, ParkingSpaceEntity>> call(VacateParkingSpaceParams params) async {
    return await repository.vacateParkingSpace(params.spaceId);
  }
}

class VacateParkingSpaceParams extends Equatable {
  final String spaceId;

  const VacateParkingSpaceParams({required this.spaceId});

  @override
  List<Object?> get props => [spaceId];
}
