import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../../domain/entities/parking_space_entity.dart';
import '../../../domain/repositories/parking_space_repository.dart';

// Define a specific params class just for this use case
class WatchParkingSpacesParams extends Equatable {
  const WatchParkingSpacesParams();

  @override
  List<Object?> get props => [];
}

// Don't implement any interface, just make a simple class
class WatchParkingSpaces {
  final ParkingSpaceRepository repository;

  WatchParkingSpaces(this.repository);

  // Just define the method directly
  Stream<Either<Failure, List<ParkingSpaceEntity>>> call(WatchParkingSpacesParams params) {
    return repository.watchParkingSpaces();
  }
}
