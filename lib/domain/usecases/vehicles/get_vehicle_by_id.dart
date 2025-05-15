import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_parking/domain/usecases/vehicles/usecase.dart';
import '../../../core/errors/failures.dart';
import '../../entities/vehicle_entity.dart';
import '../../repositories/vehicle_repository.dart';

class GetVehicleById extends UseCase<VehicleEntity, GetVehicleByIdParams> {
  final VehicleRepository repository;

  GetVehicleById(this.repository);

  @override
  Future<Either<Failure, VehicleEntity>> call(GetVehicleByIdParams params) async {
    return await repository.getVehicleById(params.vehicleId);
  }
}

class GetVehicleByIdParams extends Equatable {
  final String vehicleId;

  const GetVehicleByIdParams({required this.vehicleId});

  @override
  List<Object?> get props => [vehicleId];
}
