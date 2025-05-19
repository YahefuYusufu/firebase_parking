import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_parking/core/usecase/usecase.dart';

import '../../../core/errors/failures.dart';
import '../../../domain/repositories/parking_space_repository.dart';

class DeleteParkingSpace implements UseCase<void, DeleteParkingSpaceParams> {
  final ParkingSpaceRepository repository;

  DeleteParkingSpace(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteParkingSpaceParams params) async {
    return await repository.deleteParkingSpace(params.spaceId);
  }
}

class DeleteParkingSpaceParams extends Equatable {
  final String spaceId;

  const DeleteParkingSpaceParams({required this.spaceId});

  @override
  List<Object?> get props => [spaceId];
}
