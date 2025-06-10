import 'package:firebase_parking/domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({required super.id, required super.title, required super.body, required super.scheduledTime, super.parkingId, required super.type});

  // Convert from entity
  factory NotificationModel.fromEntity(NotificationEntity entity) {
    return NotificationModel(id: entity.id, title: entity.title, body: entity.body, scheduledTime: entity.scheduledTime, parkingId: entity.parkingId, type: entity.type);
  }

  // Convert to entity
  NotificationEntity toEntity() {
    return NotificationEntity(id: id, title: title, body: body, scheduledTime: scheduledTime, parkingId: parkingId, type: type);
  }

  // Generate 32-bit safe notification IDs
  static int _generateSafeId() {
    // 2147483647 is 2^31-1 (max positive 32-bit integer)
    return (DateTime.now().millisecondsSinceEpoch % 2147483647).toInt();
  }

  // Create parking reminder notifications based on actual parking duration
  static List<NotificationModel> createParkingReminders({
    required String parkingId,
    required String vehicleRegistration,
    required DateTime parkingStartTime,
    required Duration totalTimeLimit, // NEW: Use actual time limit
    String? parkingSpaceNumber,
  }) {
    final List<NotificationModel> notifications = [];
    final baseId = _generateSafeId();

    final now = DateTime.now();
    final expectedEndTime = parkingStartTime.add(totalTimeLimit);

    print("🕐 Current time: ${now.toIso8601String()}");
    print("🕐 Parking start time: ${parkingStartTime.toIso8601String()}");
    print("🕐 Expected end time: ${expectedEndTime.toIso8601String()}");
    print("🕐 Total time limit: ${_formatDuration(totalTimeLimit)}");

    // Only schedule notifications if parking hasn't expired yet
    if (expectedEndTime.isBefore(now)) {
      print("⚠️ Parking has already expired, not scheduling reminders");
      return notifications;
    }

    final space = parkingSpaceNumber != null ? " in space $parkingSpaceNumber" : "";

    // Schedule reminders based on parking duration
    if (totalTimeLimit.inMinutes >= 30) {
      // 15 minutes before expiry (for 30+ minute parking)
      final reminder15Min = expectedEndTime.subtract(const Duration(minutes: 15));
      if (reminder15Min.isAfter(now)) {
        notifications.add(
          NotificationModel(
            id: baseId + 1,
            title: "Parking Expires Soon",
            body: "$vehicleRegistration$space expires in 15 minutes. Consider extending or moving your vehicle.",
            scheduledTime: reminder15Min,
            parkingId: parkingId,
            type: NotificationType.parkingReminder,
          ),
        );
        print("📅 15-minute reminder scheduled for: ${reminder15Min.toIso8601String()}");
      }
    }

    if (totalTimeLimit.inMinutes >= 10) {
      // 5 minutes before expiry (for 10+ minute parking)
      final reminder5Min = expectedEndTime.subtract(const Duration(minutes: 5));
      if (reminder5Min.isAfter(now)) {
        notifications.add(
          NotificationModel(
            id: baseId + 2,
            title: "Parking Expires Very Soon",
            body: "$vehicleRegistration$space expires in 5 minutes! Time to extend or move.",
            scheduledTime: reminder5Min,
            parkingId: parkingId,
            type: NotificationType.parkingReminder,
          ),
        );
        print("📅 5-minute reminder scheduled for: ${reminder5Min.toIso8601String()}");
      }
    }

    // Expiry notification (always schedule if not expired)
    if (expectedEndTime.isAfter(now)) {
      notifications.add(
        NotificationModel(
          id: baseId + 3,
          title: "Parking Expired",
          body: "$vehicleRegistration$space has expired! Move your vehicle to avoid penalties.",
          scheduledTime: expectedEndTime,
          parkingId: parkingId,
          type: NotificationType.parkingExpiry,
        ),
      );
      print("📅 Expiry notification scheduled for: ${expectedEndTime.toIso8601String()}");
    }

    // 5 minutes after expiry (grace period warning)
    final gracePeriodWarning = expectedEndTime.add(const Duration(minutes: 5));
    if (gracePeriodWarning.isAfter(now)) {
      notifications.add(
        NotificationModel(
          id: baseId + 4,
          title: "Grace Period Ending",
          body: "$vehicleRegistration$space is 5 minutes overdue. Please move immediately!",
          scheduledTime: gracePeriodWarning,
          parkingId: parkingId,
          type: NotificationType.parkingExpiry,
        ),
      );
      print("📅 Grace period warning scheduled for: ${gracePeriodWarning.toIso8601String()}");
    }

    return notifications;
  }

  // Create test notifications (keep your existing test functionality)
  static List<NotificationModel> createTestParkingReminders({required String parkingId, required String vehicleRegistration, required DateTime parkingStartTime}) {
    final List<NotificationModel> notifications = [];
    final baseId = _generateSafeId();

    // Always schedule from current time with bigger buffer
    final now = DateTime.now();
    final scheduleFrom = now.add(const Duration(seconds: 20));

    print("🧪 TEST MODE - Current time: ${now.toIso8601String()}");
    print("🧪 TEST MODE - Will schedule from: ${scheduleFrom.toIso8601String()}");

    // 30 seconds reminder
    final firstNotificationTime = scheduleFrom.add(const Duration(seconds: 30));
    notifications.add(
      NotificationModel(
        id: baseId + 1,
        title: "Test Parking Reminder",
        body: "You've been parked for 30 seconds with $vehicleRegistration (Test Notification)",
        scheduledTime: firstNotificationTime,
        parkingId: parkingId,
        type: NotificationType.parkingReminder,
      ),
    );

    // 1 minute reminder
    final secondNotificationTime = scheduleFrom.add(const Duration(minutes: 1, seconds: 10));
    notifications.add(
      NotificationModel(
        id: baseId + 2,
        title: "Test Parking Reminder",
        body: "You've been parked for 1 minute with $vehicleRegistration (Test Notification)",
        scheduledTime: secondNotificationTime,
        parkingId: parkingId,
        type: NotificationType.parkingReminder,
      ),
    );

    return notifications;
  }

  // Create parking extension notification with action buttons
  static NotificationModel createParkingExtended({
    required String parkingId,
    required String vehicleRegistration,
    required Duration additionalTime,
    required DateTime newExpiryTime,
    String? parkingSpaceNumber,
  }) {
    final space = parkingSpaceNumber != null ? " in space $parkingSpaceNumber" : "";
    final additionalTimeStr = _formatDuration(additionalTime);
    final expiryTimeStr = "${newExpiryTime.hour.toString().padLeft(2, '0')}:${newExpiryTime.minute.toString().padLeft(2, '0')}";

    return NotificationModel(
      id: _generateSafeId(),
      title: "Parking Extended",
      body: "$vehicleRegistration$space extended by $additionalTimeStr. New expiry: $expiryTimeStr",
      scheduledTime: DateTime.now(),
      parkingId: parkingId,
      type: NotificationType.parkingReminder,
    );
  }

  // NEW: Create parking expiry notification with extend action
  static NotificationModel createExpiryWithExtendAction({
    required String parkingId,
    required String vehicleRegistration,
    required DateTime expiryTime,
    String? parkingSpaceNumber,
  }) {
    final space = parkingSpaceNumber != null ? " in space $parkingSpaceNumber" : "";
    final expiryTimeStr = "${expiryTime.hour.toString().padLeft(2, '0')}:${expiryTime.minute.toString().padLeft(2, '0')}";

    return NotificationModel(
      id: _generateSafeId(),
      title: "Parking Expired!",
      body: "$vehicleRegistration$space expired at $expiryTimeStr. Extend now to avoid penalties!",
      scheduledTime: expiryTime,
      parkingId: parkingId,
      type: NotificationType.parkingExpiry,
    );
  }

  // Update reminders after parking extension
  static List<NotificationModel> createUpdatedReminders({
    required String parkingId,
    required String vehicleRegistration,
    required DateTime newExpiryTime,
    String? parkingSpaceNumber,
  }) {
    final List<NotificationModel> notifications = [];
    final baseId = _generateSafeId();
    final now = DateTime.now();

    if (newExpiryTime.isBefore(now)) {
      print("⚠️ New expiry time is in the past, not scheduling updated reminders");
      return notifications;
    }

    final space = parkingSpaceNumber != null ? " in space $parkingSpaceNumber" : "";

    // 15 minutes before new expiry
    final reminder15Min = newExpiryTime.subtract(const Duration(minutes: 15));
    if (reminder15Min.isAfter(now)) {
      notifications.add(
        NotificationModel(
          id: baseId + 1,
          title: "Extended Parking Expires Soon",
          body: "$vehicleRegistration$space expires in 15 minutes (extended session).",
          scheduledTime: reminder15Min,
          parkingId: parkingId,
          type: NotificationType.parkingReminder,
        ),
      );
    }

    // 5 minutes before new expiry
    final reminder5Min = newExpiryTime.subtract(const Duration(minutes: 5));
    if (reminder5Min.isAfter(now)) {
      notifications.add(
        NotificationModel(
          id: baseId + 2,
          title: "Extended Parking Expires Very Soon",
          body: "$vehicleRegistration$space expires in 5 minutes! (extended session)",
          scheduledTime: reminder5Min,
          parkingId: parkingId,
          type: NotificationType.parkingReminder,
        ),
      );
    }

    // New expiry notification
    notifications.add(
      NotificationModel(
        id: baseId + 3,
        title: "Extended Parking Expired",
        body: "$vehicleRegistration$space has expired! (extended session ended)",
        scheduledTime: newExpiryTime,
        parkingId: parkingId,
        type: NotificationType.parkingExpiry,
      ),
    );

    return notifications;
  }

  // Create parking started notification
  static NotificationModel createParkingStarted({required String parkingId, required String vehicleRegistration, required String parkingSpaceNumber, required Duration timeLimit}) {
    final timeLimitStr = _formatDuration(timeLimit);
    final expectedEndTime = DateTime.now().add(timeLimit);
    final endTimeStr = "${expectedEndTime.hour.toString().padLeft(2, '0')}:${expectedEndTime.minute.toString().padLeft(2, '0')}";

    return NotificationModel(
      id: _generateSafeId(),
      title: "Parking Started",
      body: "$vehicleRegistration is now parked in space $parkingSpaceNumber for $timeLimitStr (expires at $endTimeStr)",
      scheduledTime: DateTime.now(),
      parkingId: parkingId,
      type: NotificationType.parkingStarted,
    );
  }

  // Create parking ended notification
  static NotificationModel createParkingEnded({
    required String parkingId,
    required String vehicleRegistration,
    required Duration actualDuration,
    required double totalCost,
    int extensionCount = 0,
  }) {
    final durationText = _formatDuration(actualDuration);
    final extensionText = extensionCount > 0 ? " (with $extensionCount extension${extensionCount > 1 ? 's' : ''})" : "";

    return NotificationModel(
      id: _generateSafeId(),
      title: "Parking Ended",
      body: "$vehicleRegistration parked for $durationText$extensionText. Total cost: ${totalCost.toStringAsFixed(2)} kr",
      scheduledTime: DateTime.now(),
      parkingId: parkingId,
      type: NotificationType.parkingEnded,
    );
  }

  // Helper method to format duration
  static String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${minutes}m';
    }
  }

  @override
  NotificationModel copyWith({int? id, String? title, String? body, DateTime? scheduledTime, String? parkingId, NotificationType? type}) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      parkingId: parkingId ?? this.parkingId,
      type: type ?? this.type,
    );
  }
}
