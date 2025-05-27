import 'package:equatable/equatable.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationInitialized extends NotificationState {
  final bool permissionsGranted;

  const NotificationInitialized({required this.permissionsGranted});

  @override
  List<Object?> get props => [permissionsGranted];
}

class NotificationPermissionGranted extends NotificationState {}

class NotificationPermissionDenied extends NotificationState {
  final String message;

  const NotificationPermissionDenied(this.message);

  @override
  List<Object?> get props => [message];
}

class ParkingRemindersScheduled extends NotificationState {
  final String parkingId;
  final List<int> notificationIds;

  const ParkingRemindersScheduled({required this.parkingId, required this.notificationIds});

  @override
  List<Object?> get props => [parkingId, notificationIds];
}

class ParkingNotificationShown extends NotificationState {
  final String message;

  const ParkingNotificationShown(this.message);

  @override
  List<Object?> get props => [message];
}

class ParkingNotificationsCancelled extends NotificationState {
  final String parkingId;

  const ParkingNotificationsCancelled(this.parkingId);

  @override
  List<Object?> get props => [parkingId];
}

class AllNotificationsCancelled extends NotificationState {}

class NotificationError extends NotificationState {
  final String message;

  const NotificationError(this.message);

  @override
  List<Object?> get props => [message];
}
