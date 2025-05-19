import 'package:equatable/equatable.dart';
import 'package:firebase_parking/domain/entities/parking_space_entity.dart';

abstract class ParkingSpaceEvent extends Equatable {
  const ParkingSpaceEvent();

  @override
  List<Object?> get props => [];
}

class GetAllParkingSpacesEvent extends ParkingSpaceEvent {}

class GetParkingSpacesByStatusEvent extends ParkingSpaceEvent {
  final ParkingSpaceStatus status;

  const GetParkingSpacesByStatusEvent(this.status);

  @override
  List<Object?> get props => [status];
}

class GetParkingSpacesBySectionEvent extends ParkingSpaceEvent {
  final String section;

  const GetParkingSpacesBySectionEvent(this.section);

  @override
  List<Object?> get props => [section];
}

class GetParkingSpacesByLevelEvent extends ParkingSpaceEvent {
  final String level;

  const GetParkingSpacesByLevelEvent(this.level);

  @override
  List<Object?> get props => [level];
}

class GetParkingSpaceByIdEvent extends ParkingSpaceEvent {
  final String spaceId;

  const GetParkingSpaceByIdEvent(this.spaceId);

  @override
  List<Object?> get props => [spaceId];
}

class GetParkingSpaceByNumberEvent extends ParkingSpaceEvent {
  final String spaceNumber;

  const GetParkingSpaceByNumberEvent(this.spaceNumber);

  @override
  List<Object?> get props => [spaceNumber];
}

class CreateParkingSpaceEvent extends ParkingSpaceEvent {
  final ParkingSpaceEntity space;

  const CreateParkingSpaceEvent(this.space);

  @override
  List<Object?> get props => [space];
}

class UpdateParkingSpaceEvent extends ParkingSpaceEvent {
  final ParkingSpaceEntity space;

  const UpdateParkingSpaceEvent(this.space);

  @override
  List<Object?> get props => [space];
}

class DeleteParkingSpaceEvent extends ParkingSpaceEvent {
  final String spaceId;

  const DeleteParkingSpaceEvent(this.spaceId);

  @override
  List<Object?> get props => [spaceId];
}

class OccupyParkingSpaceEvent extends ParkingSpaceEvent {
  final String spaceId;
  final String vehicleId;

  const OccupyParkingSpaceEvent(this.spaceId, this.vehicleId);

  @override
  List<Object?> get props => [spaceId, vehicleId];
}

class VacateParkingSpaceEvent extends ParkingSpaceEvent {
  final String spaceId;

  const VacateParkingSpaceEvent(this.spaceId);

  @override
  List<Object?> get props => [spaceId];
}

class GetAvailableSpacesCountEvent extends ParkingSpaceEvent {}

class WatchParkingSpacesEvent extends ParkingSpaceEvent {}

class GetSpaceByVehicleIdEvent extends ParkingSpaceEvent {
  final String vehicleId;

  const GetSpaceByVehicleIdEvent(this.vehicleId);

  @override
  List<Object?> get props => [vehicleId];
}
