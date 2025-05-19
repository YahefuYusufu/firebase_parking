import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_parking/core/usecase/usecase.dart';
import '../../../core/errors/failures.dart';
import '../../../domain/entities/parking_space_entity.dart';
import '../../../domain/repositories/parking_space_repository.dart';

class UpdateParkingSpace implements UseCase<ParkingSpaceEntity, UpdateParkingSpaceParams> {
  final ParkingSpaceRepository repository;

  UpdateParkingSpace(this.repository);

  @override
  Future<Either<Failure, ParkingSpaceEntity>> call(UpdateParkingSpaceParams params) async {
    return await repository.updateParkingSpace(params.space);
  }
}

class UpdateParkingSpaceParams extends Equatable {
  final ParkingSpaceEntity space;

  const UpdateParkingSpaceParams({required this.space});

  @override
  List<Object?> get props => [space];
}
