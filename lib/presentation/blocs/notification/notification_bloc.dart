// lib/presentation/blocs/notification/notification_bloc.dart

import 'package:firebase_parking/data/models/notification/notification_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/notification_repository.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository notificationRepository;

  NotificationBloc({required this.notificationRepository}) : super(NotificationInitial()) {
    on<InitializeNotifications>(_onInitializeNotifications);
    on<RequestNotificationPermissions>(_onRequestNotificationPermissions);
    on<ScheduleParkingReminders>(_onScheduleParkingReminders);
    on<ShowParkingStartedNotification>(_onShowParkingStartedNotification);
    on<ShowParkingEndedNotification>(_onShowParkingEndedNotification);
    on<CancelParkingNotifications>(_onCancelParkingNotifications);
    on<CancelAllNotifications>(_onCancelAllNotifications);
    on<CheckNotificationPermissions>(_onCheckNotificationPermissions);
  }

  Future<void> _onInitializeNotifications(InitializeNotifications event, Emitter<NotificationState> emit) async {
    emit(NotificationLoading());

    final initResult = await notificationRepository.initialize();

    await initResult.fold(
      (failure) async {
        emit(NotificationError(failure.message));
      },
      (success) async {
        // Check if permissions are already granted
        final permissionResult = await notificationRepository.areNotificationsEnabled();

        permissionResult.fold((failure) => emit(NotificationError(failure.message)), (enabled) => emit(NotificationInitialized(permissionsGranted: enabled)));
      },
    );
  }

  Future<void> _onRequestNotificationPermissions(RequestNotificationPermissions event, Emitter<NotificationState> emit) async {
    emit(NotificationLoading());

    final result = await notificationRepository.requestPermissions();

    result.fold((failure) => emit(NotificationError(failure.message)), (granted) {
      if (granted) {
        emit(NotificationPermissionGranted());
      } else {
        emit(const NotificationPermissionDenied('Notification permissions denied'));
      }
    });
  }

  Future<void> _onScheduleParkingReminders(ScheduleParkingReminders event, Emitter<NotificationState> emit) async {
    final result = await notificationRepository.scheduleParkingReminders(
      parkingId: event.parkingId,
      vehicleRegistration: event.vehicleRegistration,
      parkingStartTime: event.parkingStartTime,
    );

    result.fold((failure) => emit(NotificationError(failure.message)), (notificationIds) {
      emit(ParkingRemindersScheduled(parkingId: event.parkingId, notificationIds: notificationIds));
      print("🎯 Scheduled ${notificationIds.length} reminders for ${event.vehicleRegistration}");
    });
  }

  Future<void> _onShowParkingStartedNotification(ShowParkingStartedNotification event, Emitter<NotificationState> emit) async {
    // Create immediate notification for parking started
    final notification = NotificationModel.createParkingStarted(
      parkingId: event.parkingId,
      vehicleRegistration: event.vehicleRegistration,
      parkingSpaceNumber: event.parkingSpaceNumber,
    );

    final result = await notificationRepository.scheduleNotification(notification);

    result.fold((failure) => emit(NotificationError(failure.message)), (_) => emit(ParkingNotificationShown('Parking started notification shown')));
  }

  Future<void> _onShowParkingEndedNotification(ShowParkingEndedNotification event, Emitter<NotificationState> emit) async {
    // Create immediate notification for parking ended
    final notification = NotificationModel.createParkingEnded(
      parkingId: event.parkingId,
      vehicleRegistration: event.vehicleRegistration,
      duration: event.duration,
      cost: event.cost,
    );

    final result = await notificationRepository.scheduleNotification(notification);

    result.fold((failure) => emit(NotificationError(failure.message)), (_) => emit(ParkingNotificationShown('Parking ended notification shown')));
  }

  Future<void> _onCancelParkingNotifications(CancelParkingNotifications event, Emitter<NotificationState> emit) async {
    final result = await notificationRepository.cancelParkingNotifications(event.parkingId);

    result.fold((failure) => emit(NotificationError(failure.message)), (_) {
      emit(ParkingNotificationsCancelled(event.parkingId));
      print("🗑️ Cancelled notifications for parking ${event.parkingId}");
    });
  }

  Future<void> _onCancelAllNotifications(CancelAllNotifications event, Emitter<NotificationState> emit) async {
    final result = await notificationRepository.cancelAllNotifications();

    result.fold((failure) => emit(NotificationError(failure.message)), (_) {
      emit(AllNotificationsCancelled());
      print("🗑️ Cancelled all notifications");
    });
  }

  Future<void> _onCheckNotificationPermissions(CheckNotificationPermissions event, Emitter<NotificationState> emit) async {
    final result = await notificationRepository.areNotificationsEnabled();

    result.fold((failure) => emit(NotificationError(failure.message)), (enabled) => emit(NotificationInitialized(permissionsGranted: enabled)));
  }
}
