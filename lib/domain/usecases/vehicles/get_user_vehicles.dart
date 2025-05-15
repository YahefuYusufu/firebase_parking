import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_parking/domain/usecases/vehicles/usecase.dart';
import '../../../core/errors/failures.dart';
import '../../entities/vehicle_entity.dart';
import '../../repositories/vehicle_repository.dart';

class GetUserVehicles extends UseCase<List<VehicleEntity>, GetUserVehiclesParams> {
  final VehicleRepository repository;

  GetUserVehicles(this.repository);

  @override
  Future<Either<Failure, List<VehicleEntity>>> call(GetUserVehiclesParams params) async {
    return await repository.getUserVehicles(params.userId);
  }
}

class GetUserVehiclesParams extends Equatable {
  final String userId;

  const GetUserVehiclesParams({required this.userId});

  @override
  List<Object?> get props => [userId];
}
