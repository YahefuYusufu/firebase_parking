import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_parking/domain/usecases/vehicles/usecase.dart';
import '../../../core/errors/failures.dart';
import '../../entities/vehicle_entity.dart';
import '../../repositories/vehicle_repository.dart';

class UpdateVehicle extends UseCase<VehicleEntity, UpdateVehicleParams> {
  final VehicleRepository repository;

  UpdateVehicle(this.repository);

  @override
  Future<Either<Failure, VehicleEntity>> call(UpdateVehicleParams params) async {
    return await repository.updateVehicle(params.vehicle);
  }
}

class UpdateVehicleParams extends Equatable {
  final VehicleEntity vehicle;

  const UpdateVehicleParams({required this.vehicle});

  @override
  List<Object?> get props => [vehicle];
}
