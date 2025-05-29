import 'package:dartz/dartz.dart';
import 'package:firebase_parking/data/models/notification/notification_model.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/notification_entity.dart';
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

  @override
  Future<Either<Failure, List<int>>> scheduleParkingReminders({required String parkingId, required String vehicleRegistration, required DateTime parkingStartTime}) async {
    try {
      // Create parking reminder notifications
      final notifications = NotificationModel.createParkingReminders(parkingId: parkingId, vehicleRegistration: vehicleRegistration, parkingStartTime: parkingStartTime);

      final List<int> notificationIds = [];

      // Schedule each notification
      for (final notification in notifications) {
        await localDataSource.scheduleNotification(notification);
        notificationIds.add(notification.id);
        print("⏰ Scheduled parking reminder for ${notification.scheduledTime}");
      }

      // Store the IDs for this parking session
      _parkingNotificationIds[parkingId] = notificationIds;

      print("🎯 Scheduled ${notificationIds.length} parking reminders for $vehicleRegistration");
      return Right(notificationIds);
    } catch (e) {
      print("❌ Error scheduling parking reminders: $e");
      return Left(NotificationFailure('Failed to schedule parking reminders: ${e.toString()}'));
    }
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
}

// Notification-specific failure class
class NotificationFailure extends Failure {
  const NotificationFailure(String message) : super(message);
}
