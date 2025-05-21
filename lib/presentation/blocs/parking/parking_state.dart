part of 'parking_bloc.dart';

abstract class ParkingState extends Equatable {
  const ParkingState();

  @override
  List<Object?> get props => [];
}

class ParkingInitial extends ParkingState {}

class ParkingLoading extends ParkingState {}

class ParkingLoaded extends ParkingState {
  final ParkingEntity parking;

  const ParkingLoaded(this.parking);

  @override
  List<Object?> get props => [parking];
}

class ParkingListLoaded extends ParkingState {
  final List<ParkingEntity> parkingList;

  const ParkingListLoaded(this.parkingList);

  @override
  List<Object?> get props => [parkingList];
}

class ParkingCreated extends ParkingState {
  final ParkingEntity parking;

  const ParkingCreated(this.parking);

  @override
  List<Object?> get props => [parking];
}

class ParkingEnded extends ParkingState {
  final ParkingEntity parking;

  const ParkingEnded(this.parking);

  @override
  List<Object?> get props => [parking];
}

class ParkingError extends ParkingState {
  final String message;

  const ParkingError(this.message);

  @override
  List<Object?> get props => [message];
}
