// lib/presentation/blocs/notification/notification_bloc.dart

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
    on<ScheduleEntityBasedReminders>(_onScheduleEntityBasedReminders);
    on<ScheduleTestReminders>(_onScheduleTestReminders);
    on<HandleParkingExtension>(_onHandleParkingExtension);
    on<ShowParkingStartedNotification>(_onShowParkingStartedNotification);
    on<ShowParkingEndedNotification>(_onShowParkingEndedNotification);
    on<CancelParkingNotifications>(_onCancelParkingNotifications);
    on<CancelAllNotifications>(_onCancelAllNotifications);
    on<CheckNotificationPermissions>(_onCheckNotificationPermissions);
    on<ClearAllPendingNotifications>(_onClearAllPendingNotifications);
  }

  Future<void> _onInitializeNotifications(InitializeNotifications event, Emitter<NotificationState> emit) async {
    emit(NotificationLoading());

    // NEW: Clear old notifications first to prevent LED crash
    final clearResult = await notificationRepository.clearAllPendingNotifications();
    clearResult.fold((failure) => print("⚠️ Warning: Could not clear old notifications: ${failure.message}"), (_) => print("🧹 Successfully cleared old notifications"));

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

  // NEW: Handle clear all pending notifications
  Future<void> _onClearAllPendingNotifications(ClearAllPendingNotifications event, Emitter<NotificationState> emit) async {
    final result = await notificationRepository.clearAllPendingNotifications();

    result.fold((failure) => emit(NotificationError(failure.message)), (_) {
      emit(AllNotificationsCancelled());
      print("🧹 All pending notifications cleared");
    });
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

  // Legacy method for backward compatibility
  Future<void> _onScheduleParkingReminders(ScheduleParkingReminders event, Emitter<NotificationState> emit) async {
    final result = await notificationRepository.scheduleParkingReminders(
      parkingId: event.parkingId,
      vehicleRegistration: event.vehicleRegistration,
      parkingStartTime: event.parkingStartTime,
    );

    result.fold((failure) => emit(NotificationError(failure.message)), (notificationIds) {
      emit(ParkingRemindersScheduled(parkingId: event.parkingId, notificationIds: notificationIds));
      print("🎯 Scheduled ${notificationIds.length} reminders for ${event.vehicleRegistration} (legacy method)");
    });
  }

  // NEW: Schedule reminders based on ParkingEntity
  Future<void> _onScheduleEntityBasedReminders(ScheduleEntityBasedReminders event, Emitter<NotificationState> emit) async {
    final result = await notificationRepository.scheduleEntityBasedReminders(event.parking);

    result.fold((failure) => emit(NotificationError(failure.message)), (notificationIds) {
      emit(ParkingRemindersScheduled(parkingId: event.parking.id!, notificationIds: notificationIds));
      print("🎯 Scheduled ${notificationIds.length} entity-based reminders for ${event.parking.vehicleRegistration}");
      print("⏰ Time limit: ${event.parking.formattedTotalTimeLimit}");
    });
  }

  // NEW: Schedule test reminders
  Future<void> _onScheduleTestReminders(ScheduleTestReminders event, Emitter<NotificationState> emit) async {
    final result = await notificationRepository.scheduleTestReminders(
      parkingId: event.parkingId,
      vehicleRegistration: event.vehicleRegistration,
      parkingStartTime: event.parkingStartTime,
    );

    result.fold((failure) => emit(NotificationError(failure.message)), (notificationIds) {
      emit(ParkingRemindersScheduled(parkingId: event.parkingId, notificationIds: notificationIds));
      print("🧪 Scheduled ${notificationIds.length} TEST reminders for ${event.vehicleRegistration}");
    });
  }

  // NEW: Handle parking extension
  Future<void> _onHandleParkingExtension(HandleParkingExtension event, Emitter<NotificationState> emit) async {
    final result = await notificationRepository.handleParkingExtension(
      parkingId: event.parkingId,
      vehicleRegistration: event.vehicleRegistration,
      additionalTime: event.additionalTime,
      newExpiryTime: event.newExpiryTime,
      parkingSpaceNumber: event.parkingSpaceNumber,
    );

    result.fold((failure) => emit(NotificationError(failure.message)), (notificationIds) {
      emit(ParkingExtensionHandled(parkingId: event.parkingId, additionalTime: event.additionalTime, notificationIds: notificationIds));
      print("🔄 Handled parking extension for ${event.vehicleRegistration}");
      print("➕ Added ${event.additionalTime.inHours}h ${event.additionalTime.inMinutes % 60}m");
    });
  }

  Future<void> _onShowParkingStartedNotification(ShowParkingStartedNotification event, Emitter<NotificationState> emit) async {
    // Use the new repository method for parking started notifications
    final result = await notificationRepository.notifyParkingStarted(event.parking);

    result.fold((failure) => emit(NotificationError(failure.message)), (_) => emit(ParkingNotificationShown('Parking started notification shown')));
  }

  Future<void> _onShowParkingEndedNotification(ShowParkingEndedNotification event, Emitter<NotificationState> emit) async {
    // Use the new repository method for parking ended notifications
    final result = await notificationRepository.notifyParkingEnded(event.parking);

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
