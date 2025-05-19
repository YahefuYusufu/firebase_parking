// lib/domain/usecases/parking_spaces/get_space_by_vehicle_id.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_parking/domain/usecases/vehicles/usecase.dart';
import '../../../core/errors/failures.dart';
import '../../../domain/entities/parking_space_entity.dart';
import '../../../domain/repositories/parking_space_repository.dart';

class GetSpaceByVehicleId implements UseCase<ParkingSpaceEntity?, GetSpaceByVehicleIdParams> {
  final ParkingSpaceRepository repository;

  GetSpaceByVehicleId(this.repository);

  @override
  Future<Either<Failure, ParkingSpaceEntity?>> call(GetSpaceByVehicleIdParams params) async {
    return await repository.getSpaceByVehicleId(params.vehicleId);
  }
}

class GetSpaceByVehicleIdParams extends Equatable {
  final String vehicleId;

  const GetSpaceByVehicleIdParams({required this.vehicleId});

  @override
  List<Object?> get props => [vehicleId];
}
