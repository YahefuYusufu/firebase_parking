import 'package:dartz/dartz.dart';
import 'package:firebase_parking/data/models/notification/notification_model.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/entities/parking_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_local_datasource.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationLocalDataSource localDataSource;

  // Store notification IDs for each parking session
  final Map<String, List<int>> _parkingNotificationIds = {};

  NotificationRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, bool>> initialize() async {
    try {
      await localDataSource.initialize();
      return const Right(true);
    } catch (e) {
      print("❌ Error initializing notifications: $e");
      return Left(NotificationFailure('Failed to initialize notifications: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> scheduleNotification(NotificationEntity notification) async {
    try {
      final model = NotificationModel.fromEntity(notification);
      await localDataSource.scheduleNotification(model);
      print("✅ Scheduled notification: ${notification.title}");
      return const Right(null);
    } catch (e) {
      print("❌ Error scheduling notification: $e");
      return Left(NotificationFailure('Failed to schedule notification: ${e.toString()}'));
    }
  }

  // Updated to work with ParkingEntity
  @override
  Future<Either<Failure, List<int>>> scheduleParkingReminders({required String parkingId, required String vehicleRegistration, required DateTime parkingStartTime}) async {
    try {
      // This method is kept for backward compatibility but should use the new method
      print("⚠️ Using deprecated scheduleParkingReminders method. Consider using scheduleEntityBasedReminders.");

      // Default to 2 hours if no time limit provided
      final notifications = NotificationModel.createParkingReminders(
        parkingId: parkingId,
        vehicleRegistration: vehicleRegistration,
        parkingStartTime: parkingStartTime,
        totalTimeLimit: const Duration(hours: 2), // Default
      );

      return await _scheduleNotificationList(parkingId, notifications);
    } catch (e) {
      print("❌ Error scheduling parking reminders: $e");
      return Left(NotificationFailure('Failed to schedule parking reminders: ${e.toString()}'));
    }
  }

  // NEW: Schedule reminders based on ParkingEntity with interactive expiry notifications
  @override
  Future<Either<Failure, List<int>>> scheduleEntityBasedReminders(ParkingEntity parking) async {
    try {
      if (parking.id == null) {
        return Left(NotificationFailure('Parking ID is required'));
      }

      // Create notifications based on the actual parking entity
      final notifications = NotificationModel.createParkingReminders(
        parkingId: parking.id!,
        vehicleRegistration: parking.vehicleRegistration ?? 'Unknown Vehicle',
        parkingStartTime: parking.startedAt,
        totalTimeLimit: parking.totalTimeLimit,
        parkingSpaceNumber: parking.parkingSpaceNumber,
      );

      final List<int> notificationIds = [];

      for (final notification in notifications) {
        // Check if this is an expiry notification
        final isExpiryNotification = notification.type == NotificationType.parkingExpiry;

        if (isExpiryNotification) {
          // Use the new method with action buttons for expiry notifications
          await localDataSource.scheduleNotificationWithActions(notification, includeExtendAction: true);
        } else {
          // Use regular notification for reminders
          await localDataSource.scheduleNotification(notification);
        }

        notificationIds.add(notification.id);
        print("⏰ Scheduled ${isExpiryNotification ? 'interactive' : 'regular'} notification for ${notification.scheduledTime}");
      }

      // Store the IDs for this parking session
      _parkingNotificationIds[parking.id!] = notificationIds;

      print("🎯 Scheduled ${notificationIds.length} notifications (with actions) for parking ${parking.id}");
      return Right(notificationIds);
    } catch (e) {
      print("❌ Error scheduling entity-based reminders: $e");
      return Left(NotificationFailure('Failed to schedule entity-based reminders: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<int>>> scheduleTestReminders({required String parkingId, required String vehicleRegistration, required DateTime parkingStartTime}) async {
    try {
      final notifications = NotificationModel.createTestParkingReminders(parkingId: parkingId, vehicleRegistration: vehicleRegistration, parkingStartTime: parkingStartTime);

      return await _scheduleNotificationList(parkingId, notifications);
    } catch (e) {
      print("❌ Error scheduling test reminders: $e");
      return Left(NotificationFailure('Failed to schedule test reminders: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<int>>> handleParkingExtension({
    required String parkingId,
    required String vehicleRegistration,
    required Duration additionalTime,
    required DateTime newExpiryTime,
    String? parkingSpaceNumber,
  }) async {
    try {
      // First, cancel existing reminders for this parking
      await cancelParkingNotifications(parkingId);

      // Send extension confirmation notification
      final extensionNotification = NotificationModel.createParkingExtended(
        parkingId: parkingId,
        vehicleRegistration: vehicleRegistration,
        additionalTime: additionalTime,
        newExpiryTime: newExpiryTime,
        parkingSpaceNumber: parkingSpaceNumber,
      );

      await localDataSource.scheduleNotification(extensionNotification);
      print("✅ Scheduled extension notification");

      // Schedule new reminders based on extended time
      final newReminders = NotificationModel.createUpdatedReminders(
        parkingId: parkingId,
        vehicleRegistration: vehicleRegistration,
        newExpiryTime: newExpiryTime,
        parkingSpaceNumber: parkingSpaceNumber,
      );

      final result = await _scheduleNotificationList(parkingId, newReminders);

      // Add the extension notification ID to the result
      return result.fold((failure) => Left(failure), (ids) => Right([extensionNotification.id, ...ids]));
    } catch (e) {
      print("❌ Error handling parking extension: $e");
      return Left(NotificationFailure('Failed to handle parking extension: ${e.toString()}'));
    }
  }

  // NEW: Send parking started notification
  @override
  Future<Either<Failure, void>> notifyParkingStarted(ParkingEntity parking) async {
    try {
      if (parking.id == null) {
        return Left(NotificationFailure('Parking ID is required'));
      }

      final notification = NotificationModel.createParkingStarted(
        parkingId: parking.id!,
        vehicleRegistration: parking.vehicleRegistration ?? 'Unknown Vehicle',
        parkingSpaceNumber: parking.parkingSpaceNumber ?? 'Unknown Space',
        timeLimit: parking.originalTimeLimit,
      );

      await localDataSource.scheduleNotification(notification);
      print("✅ Scheduled parking started notification");
      return const Right(null);
    } catch (e) {
      print("❌ Error notifying parking started: $e");
      return Left(NotificationFailure('Failed to notify parking started: ${e.toString()}'));
    }
  }

  // NEW: Send parking ended notification
  @override
  Future<Either<Failure, void>> notifyParkingEnded(ParkingEntity parking) async {
    try {
      if (parking.id == null) {
        return Left(NotificationFailure('Parking ID is required'));
      }

      final notification = NotificationModel.createParkingEnded(
        parkingId: parking.id!,
        vehicleRegistration: parking.vehicleRegistration ?? 'Unknown Vehicle',
        actualDuration: parking.duration,
        totalCost: parking.totalFee,
        extensionCount: parking.extensionCount,
      );

      await localDataSource.scheduleNotification(notification);
      print("✅ Scheduled parking ended notification");
      return const Right(null);
    } catch (e) {
      print("❌ Error notifying parking ended: $e");
      return Left(NotificationFailure('Failed to notify parking ended: ${e.toString()}'));
    }
  }

  // Helper method to schedule a list of notifications
  Future<Either<Failure, List<int>>> _scheduleNotificationList(String parkingId, List<NotificationModel> notifications) async {
    final List<int> notificationIds = [];

    for (final notification in notifications) {
      await localDataSource.scheduleNotification(notification);
      notificationIds.add(notification.id);
      print("⏰ Scheduled notification for ${notification.scheduledTime}");
    }

    // Store the IDs for this parking session
    _parkingNotificationIds[parkingId] = notificationIds;

    print("🎯 Scheduled ${notificationIds.length} notifications for parking $parkingId");
    return Right(notificationIds);
  }

  @override
  Future<Either<Failure, void>> cancelNotification(int notificationId) async {
    try {
      await localDataSource.cancelNotification(notificationId);
      print("❌ Cancelled notification ID: $notificationId");
      return const Right(null);
    } catch (e) {
      print("❌ Error cancelling notification: $e");
      return Left(NotificationFailure('Failed to cancel notification: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> cancelParkingNotifications(String parkingId) async {
    try {
      final notificationIds = _parkingNotificationIds[parkingId];

      if (notificationIds != null) {
        for (final id in notificationIds) {
          await localDataSource.cancelNotification(id);
        }
        _parkingNotificationIds.remove(parkingId);
        print("🗑️ Cancelled ${notificationIds.length} notifications for parking $parkingId");
      } else {
        print("⚠️ No notifications found for parking $parkingId");
      }

      return const Right(null);
    } catch (e) {
      print("❌ Error cancelling parking notifications: $e");
      return Left(NotificationFailure('Failed to cancel parking notifications: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> cancelAllNotifications() async {
    try {
      await localDataSource.cancelAllNotifications();
      _parkingNotificationIds.clear();
      print("🗑️ Cancelled all notifications");
      return const Right(null);
    } catch (e) {
      print("❌ Error cancelling all notifications: $e");
      return Left(NotificationFailure('Failed to cancel all notifications: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> areNotificationsEnabled() async {
    try {
      final enabled = await localDataSource.areNotificationsEnabled();
      return Right(enabled);
    } catch (e) {
      print("❌ Error checking notification permissions: $e");
      return Left(NotificationFailure('Failed to check notification permissions: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> requestPermissions() async {
    try {
      final granted = await localDataSource.requestPermissions();
      print("🔐 Notification permissions granted: $granted");
      return Right(granted);
    } catch (e) {
      print("❌ Error requesting notification permissions: $e");
      return Left(NotificationFailure('Failed to request notification permissions: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> clearAllPendingNotifications() async {
    try {
      await localDataSource.clearAllPendingNotifications();
      _parkingNotificationIds.clear(); // Also clear our tracking
      print("🧹 Cleared all pending notifications from repository");
      return const Right(null);
    } catch (e) {
      print("❌ Error clearing pending notifications: $e");
      return Left(NotificationFailure('Failed to clear pending notifications: ${e.toString()}'));
    }
  }
}

// Notification-specific failure class
class NotificationFailure extends Failure {
  const NotificationFailure(String message) : super(message);
}
