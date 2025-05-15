import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_parking/domain/usecases/vehicles/usecase.dart';
import '../../../core/errors/failures.dart';
import '../../entities/vehicle_entity.dart';
import '../../repositories/vehicle_repository.dart';

class SearchVehiclesByRegistration extends UseCase<List<VehicleEntity>, SearchVehiclesByRegistrationParams> {
  final VehicleRepository repository;

  SearchVehiclesByRegistration(this.repository);

  @override
  Future<Either<Failure, List<VehicleEntity>>> call(SearchVehiclesByRegistrationParams params) async {
    return await repository.searchVehiclesByRegistration(params.query);
  }
}

class SearchVehiclesByRegistrationParams extends Equatable {
  final String query;

  const SearchVehiclesByRegistrationParams({required this.query});

  @override
  List<Object?> get props => [query];
}
