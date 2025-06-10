import 'package:equatable/equatable.dart';
import 'package:firebase_parking/domain/entities/parking_entity.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

class InitializeNotifications extends NotificationEvent {
  const InitializeNotifications();
}

class RequestNotificationPermissions extends NotificationEvent {
  const RequestNotificationPermissions();
}

class ScheduleParkingReminders extends NotificationEvent {
  final String parkingId;
  final String vehicleRegistration;
  final DateTime parkingStartTime;

  const ScheduleParkingReminders({required this.parkingId, required this.vehicleRegistration, required this.parkingStartTime});

  @override
  List<Object?> get props => [parkingId, vehicleRegistration, parkingStartTime];
}

// NEW: Schedule reminders based on ParkingEntity (recommended)
class ScheduleEntityBasedReminders extends NotificationEvent {
  final ParkingEntity parking;

  const ScheduleEntityBasedReminders({required this.parking});

  @override
  List<Object> get props => [parking];
}

// NEW: Schedule test reminders for development
class ScheduleTestReminders extends NotificationEvent {
  final String parkingId;
  final String vehicleRegistration;
  final DateTime parkingStartTime;

  const ScheduleTestReminders({required this.parkingId, required this.vehicleRegistration, required this.parkingStartTime});

  @override
  List<Object> get props => [parkingId, vehicleRegistration, parkingStartTime];
}

// NEW: Handle parking extension
class HandleParkingExtension extends NotificationEvent {
  final String parkingId;
  final String vehicleRegistration;
  final Duration additionalTime;
  final DateTime newExpiryTime;
  final String? parkingSpaceNumber;

  const HandleParkingExtension({required this.parkingId, required this.vehicleRegistration, required this.additionalTime, required this.newExpiryTime, this.parkingSpaceNumber});

  @override
  List<Object?> get props => [parkingId, vehicleRegistration, additionalTime, newExpiryTime, parkingSpaceNumber];
}

// Updated to use ParkingEntity
class ShowParkingStartedNotification extends NotificationEvent {
  final ParkingEntity parking;

  const ShowParkingStartedNotification({required this.parking});

  @override
  List<Object> get props => [parking];
}

// Updated to use ParkingEntity
class ShowParkingEndedNotification extends NotificationEvent {
  final ParkingEntity parking;

  const ShowParkingEndedNotification({required this.parking});

  @override
  List<Object> get props => [parking];
}

class CancelParkingNotifications extends NotificationEvent {
  final String parkingId;

  const CancelParkingNotifications(this.parkingId);

  @override
  List<Object?> get props => [parkingId];
}

class CancelAllNotifications extends NotificationEvent {
  const CancelAllNotifications();
}

class CheckNotificationPermissions extends NotificationEvent {
  const CheckNotificationPermissions();
}
