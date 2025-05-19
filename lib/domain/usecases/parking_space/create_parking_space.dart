import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_parking/domain/usecases/vehicles/usecase.dart';
import '../../../core/errors/failures.dart';
import '../../../domain/entities/parking_space_entity.dart';
import '../../../domain/repositories/parking_space_repository.dart';

class CreateParkingSpace implements UseCase<ParkingSpaceEntity, CreateParkingSpaceParams> {
  final ParkingSpaceRepository repository;

  CreateParkingSpace(this.repository);

  @override
  Future<Either<Failure, ParkingSpaceEntity>> call(CreateParkingSpaceParams params) async {
    return await repository.createParkingSpace(params.space);
  }
}

class CreateParkingSpaceParams extends Equatable {
  final ParkingSpaceEntity space;

  const CreateParkingSpaceParams({required this.space});

  @override
  List<Object?> get props => [space];
}
