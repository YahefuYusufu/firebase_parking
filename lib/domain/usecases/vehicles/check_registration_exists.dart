import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_parking/domain/usecases/vehicles/usecase.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/vehicle_repository.dart';

class CheckRegistrationExists extends UseCase<bool, CheckRegistrationExistsParams> {
  final VehicleRepository repository;

  CheckRegistrationExists(this.repository);

  @override
  Future<Either<Failure, bool>> call(CheckRegistrationExistsParams params) async {
    return await repository.checkRegistrationExists(params.registrationNumber);
  }
}

class CheckRegistrationExistsParams extends Equatable {
  final String registrationNumber;

  const CheckRegistrationExistsParams({required this.registrationNumber});

  @override
  List<Object?> get props => [registrationNumber];
}
