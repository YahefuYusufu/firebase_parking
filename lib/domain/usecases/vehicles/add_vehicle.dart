import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_parking/domain/usecases/vehicles/usecase.dart';
import '../../../core/errors/failures.dart';
import '../../entities/vehicle_entity.dart';
import '../../repositories/vehicle_repository.dart';

class AddVehicle extends UseCase<VehicleEntity, AddVehicleParams> {
  final VehicleRepository repository;

  AddVehicle(this.repository);

  @override
  Future<Either<Failure, VehicleEntity>> call(AddVehicleParams params) async {
    return await repository.addVehicle(params.vehicle);
  }
}

class AddVehicleParams extends Equatable {
  final VehicleEntity vehicle;

  const AddVehicleParams({required this.vehicle});

  @override
  List<Object?> get props => [vehicle];
}
