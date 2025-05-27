import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/notification_entity.dart';

abstract class NotificationRepository {
  /// Initialize notification system and request permissions
  Future<Either<Failure, bool>> initialize();

  /// Schedule a single notification
  Future<Either<Failure, void>> scheduleNotification(NotificationEntity notification);

  /// Schedule parking reminders (multiple notifications for one parking session)
  Future<Either<Failure, List<int>>> scheduleParkingReminders({required String parkingId, required String vehicleRegistration, required DateTime parkingStartTime});

  /// Cancel a specific notification by ID
  Future<Either<Failure, void>> cancelNotification(int notificationId);

  /// Cancel all notifications for a specific parking session
  Future<Either<Failure, void>> cancelParkingNotifications(String parkingId);

  /// Cancel all scheduled notifications
  Future<Either<Failure, void>> cancelAllNotifications();

  /// Check if notifications are enabled/permitted
  Future<Either<Failure, bool>> areNotificationsEnabled();

  /// Request notification permissions
  Future<Either<Failure, bool>> requestPermissions();
}
