import 'package:equatable/equatable.dart';
import 'package:firebase_parking/domain/entities/parking_space_entity.dart';

abstract class ParkingSpaceState extends Equatable {
  const ParkingSpaceState();

  @override
  List<Object?> get props => [];
}

// Initial state
class ParkingSpaceInitial extends ParkingSpaceState {
  const ParkingSpaceInitial();
}

// Loading states
class ParkingSpacesLoading extends ParkingSpaceState {
  const ParkingSpacesLoading();
}

class ParkingSpaceCreating extends ParkingSpaceState {
  const ParkingSpaceCreating();
}

class ParkingSpaceUpdating extends ParkingSpaceState {
  const ParkingSpaceUpdating();
}

class ParkingSpaceDeleting extends ParkingSpaceState {
  const ParkingSpaceDeleting();
}

// Success states
class ParkingSpacesLoaded extends ParkingSpaceState {
  final List<ParkingSpaceEntity> spaces;

  const ParkingSpacesLoaded(this.spaces);

  @override
  List<Object?> get props => [spaces];
}

class ParkingSpaceLoaded extends ParkingSpaceState {
  final ParkingSpaceEntity space;

  const ParkingSpaceLoaded(this.space);

  @override
  List<Object?> get props => [space];
}

class ParkingSpaceCreated extends ParkingSpaceState {
  final ParkingSpaceEntity space;

  const ParkingSpaceCreated(this.space);

  @override
  List<Object?> get props => [space];
}

class ParkingSpaceUpdated extends ParkingSpaceState {
  final ParkingSpaceEntity space;

  const ParkingSpaceUpdated(this.space);

  @override
  List<Object?> get props => [space];
}

class ParkingSpaceDeleted extends ParkingSpaceState {
  const ParkingSpaceDeleted();
}

class ParkingSpaceOccupied extends ParkingSpaceState {
  final ParkingSpaceEntity space;

  const ParkingSpaceOccupied(this.space);

  @override
  List<Object?> get props => [space];
}

class ParkingSpaceVacated extends ParkingSpaceState {
  final ParkingSpaceEntity space;

  const ParkingSpaceVacated(this.space);

  @override
  List<Object?> get props => [space];
}

class AvailableSpacesCountLoaded extends ParkingSpaceState {
  final int count;

  const AvailableSpacesCountLoaded(this.count);

  @override
  List<Object?> get props => [count];
}

class ParkingSpaceByVehicleLoaded extends ParkingSpaceState {
  final ParkingSpaceEntity? space;

  const ParkingSpaceByVehicleLoaded(this.space);

  @override
  List<Object?> get props => [space];
}

// Error state
class ParkingSpaceError extends ParkingSpaceState {
  final String message;

  const ParkingSpaceError(this.message);

  @override
  List<Object?> get props => [message];
}
