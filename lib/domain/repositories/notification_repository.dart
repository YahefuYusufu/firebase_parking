import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/notification_entity.dart';
import '../entities/parking_entity.dart';

abstract class NotificationRepository {
  /// Initialize notification system and request permissions
  Future<Either<Failure, bool>> initialize();

  /// Schedule a single notification
  Future<Either<Failure, void>> scheduleNotification(NotificationEntity notification);

  /// Schedule parking reminders (legacy method - for backward compatibility)
  Future<Either<Failure, List<int>>> scheduleParkingReminders({required String parkingId, required String vehicleRegistration, required DateTime parkingStartTime});

  /// NEW: Schedule reminders based on ParkingEntity (recommended)
  Future<Either<Failure, List<int>>> scheduleEntityBasedReminders(ParkingEntity parking);

  /// NEW: Schedule test reminders (for development/testing)
  Future<Either<Failure, List<int>>> scheduleTestReminders({required String parkingId, required String vehicleRegistration, required DateTime parkingStartTime});

  /// NEW: Handle parking extension notifications
  Future<Either<Failure, List<int>>> handleParkingExtension({
    required String parkingId,
    required String vehicleRegistration,
    required Duration additionalTime,
    required DateTime newExpiryTime,
    String? parkingSpaceNumber,
  });

  /// NEW: Send parking started notification
  Future<Either<Failure, void>> notifyParkingStarted(ParkingEntity parking);

  /// NEW: Send parking ended notification
  Future<Either<Failure, void>> notifyParkingEnded(ParkingEntity parking);

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
