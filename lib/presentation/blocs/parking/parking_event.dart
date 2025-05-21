part of 'parking_bloc.dart';

abstract class ParkingEvent extends Equatable {
  const ParkingEvent();

  @override
  List<Object?> get props => [];
}

class CreateParkingEvent extends ParkingEvent {
  final String vehicleId;
  final String parkingSpaceId;

  const CreateParkingEvent({required this.vehicleId, required this.parkingSpaceId});

  @override
  List<Object?> get props => [vehicleId, parkingSpaceId];
}

class GetParkingEvent extends ParkingEvent {
  final String parkingId;

  const GetParkingEvent(this.parkingId);

  @override
  List<Object?> get props => [parkingId];
}

class GetActiveParkingEvent extends ParkingEvent {}

class GetUserParkingEvent extends ParkingEvent {
  final String userId;

  const GetUserParkingEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

class EndParkingEvent extends ParkingEvent {
  final String parkingId;

  const EndParkingEvent(this.parkingId);

  @override
  List<Object?> get props => [parkingId];
}
