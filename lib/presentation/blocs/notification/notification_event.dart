import 'package:equatable/equatable.dart';

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

class ShowParkingStartedNotification extends NotificationEvent {
  final String parkingId;
  final String vehicleRegistration;
  final String parkingSpaceNumber;

  const ShowParkingStartedNotification({required this.parkingId, required this.vehicleRegistration, required this.parkingSpaceNumber});

  @override
  List<Object?> get props => [parkingId, vehicleRegistration, parkingSpaceNumber];
}

class ShowParkingEndedNotification extends NotificationEvent {
  final String parkingId;
  final String vehicleRegistration;
  final Duration duration;
  final double cost;

  const ShowParkingEndedNotification({required this.parkingId, required this.vehicleRegistration, required this.duration, required this.cost});

  @override
  List<Object?> get props => [parkingId, vehicleRegistration, duration, cost];
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
