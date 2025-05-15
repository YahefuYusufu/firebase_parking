import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_parking/domain/usecases/vehicles/usecase.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/vehicle_repository.dart';

class DeleteVehicle extends UseCase<void, DeleteVehicleParams> {
  final VehicleRepository repository;

  DeleteVehicle(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteVehicleParams params) async {
    return await repository.deleteVehicle(params.vehicleId);
  }
}

class DeleteVehicleParams extends Equatable {
  final String vehicleId;

  const DeleteVehicleParams({required this.vehicleId});

  @override
  List<Object?> get props => [vehicleId];
}
