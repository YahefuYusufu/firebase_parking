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

// NEW: Create parking with specific duration
class CreateParkingWithDurationEvent extends ParkingEvent {
  final String vehicleId;
  final String parkingSpaceId;
  final Duration duration;
  final String? vehicleRegistration;
  final String? parkingSpaceNumber;
  final double? hourlyRate;

  const CreateParkingWithDurationEvent({
    required this.vehicleId,
    required this.parkingSpaceId,
    required this.duration,
    this.vehicleRegistration,
    this.parkingSpaceNumber,
    this.hourlyRate,
  });

  @override
  List<Object?> get props => [vehicleId, parkingSpaceId, duration, vehicleRegistration, parkingSpaceNumber, hourlyRate];
}

// NEW: Extend parking event
class ExtendParkingEvent extends ParkingEvent {
  final String parkingId;
  final Duration additionalTime;
  final double cost;
  final String? reason;

  const ExtendParkingEvent({required this.parkingId, required this.additionalTime, required this.cost, this.reason});

  @override
  List<Object?> get props => [parkingId, additionalTime, cost, reason];
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
