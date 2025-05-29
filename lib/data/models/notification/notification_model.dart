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

  // Create parking reminder notifications
  static List<NotificationModel> createParkingReminders({required String parkingId, required String vehicleRegistration, required DateTime parkingStartTime}) {
    final List<NotificationModel> notifications = [];
    final baseId = _generateSafeId();

    // Always schedule from current time with bigger buffer
    final now = DateTime.now();
    final scheduleFrom = now.add(const Duration(seconds: 20));

    print("🕐 Current time: ${now.toIso8601String()}");
    print("🕐 Parking start time: ${parkingStartTime.toIso8601String()}");
    print("🕐 Will schedule from: ${scheduleFrom.toIso8601String()}");

    // 30 seconds reminder (was 1 hour)
    final firstNotificationTime = scheduleFrom.add(const Duration(seconds: 30));
    notifications.add(
      NotificationModel(
        id: baseId + 1,
        title: "Parking Reminder",
        body: "You've been parked for 30 seconds with $vehicleRegistration (Test Notification)",
        scheduledTime: firstNotificationTime,
        parkingId: parkingId,
        type: NotificationType.parkingReminder,
      ),
    );
    print("📅 First notification scheduled for: ${firstNotificationTime.toIso8601String()}");

    // 1 minute reminder (was 2 hours)
    final secondNotificationTime = scheduleFrom.add(const Duration(minutes: 1, seconds: 10));
    notifications.add(
      NotificationModel(
        id: baseId + 2,
        title: "Parking Reminder",
        body: "You've been parked for 1 minute with $vehicleRegistration (Test Notification)",
        scheduledTime: secondNotificationTime,
        parkingId: parkingId,
        type: NotificationType.parkingReminder,
      ),
    );
    print("📅 Second notification scheduled for: ${secondNotificationTime.toIso8601String()}");

    // 2 minute reminder (was 4 hours)
    final thirdNotificationTime = scheduleFrom.add(const Duration(minutes: 2, seconds: 10));
    notifications.add(
      NotificationModel(
        id: baseId + 3,
        title: "Long Parking Alert",
        body: "You've been parked for 2 minutes with $vehicleRegistration. Test notification working! (Test Notification)",
        scheduledTime: thirdNotificationTime,
        parkingId: parkingId,
        type: NotificationType.parkingReminder,
      ),
    );
    print("📅 Third notification scheduled for: ${thirdNotificationTime.toIso8601String()}");

    // 3 minute reminder (was 8 hours)
    final fourthNotificationTime = scheduleFrom.add(const Duration(minutes: 3, seconds: 10));
    notifications.add(
      NotificationModel(
        id: baseId + 4,
        title: "Daily Parking Reminder",
        body: "You've been parked for 3 minutes with $vehicleRegistration. All notifications working! (Test Notification)",
        scheduledTime: fourthNotificationTime,
        parkingId: parkingId,
        type: NotificationType.parkingReminder,
      ),
    );
    print("📅 Fourth notification scheduled for: ${fourthNotificationTime.toIso8601String()}");

    return notifications;
  }

  // Create parking started notification
  static NotificationModel createParkingStarted({required String parkingId, required String vehicleRegistration, required String parkingSpaceNumber}) {
    return NotificationModel(
      id: _generateSafeId(),
      title: "Parking Started",
      body: "$vehicleRegistration is now parked in space $parkingSpaceNumber",
      scheduledTime: DateTime.now(),
      parkingId: parkingId,
      type: NotificationType.parkingStarted,
    );
  }

  // Create parking ended notification
  static NotificationModel createParkingEnded({required String parkingId, required String vehicleRegistration, required Duration duration, required double cost}) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final durationText = hours > 0 ? "${hours}h ${minutes}m" : "${minutes}m";

    return NotificationModel(
      id: _generateSafeId(),
      title: "Parking Ended",
      body: "$vehicleRegistration parked for $durationText. Total cost: ${cost.toStringAsFixed(2)} kr",
      scheduledTime: DateTime.now(),
      parkingId: parkingId,
      type: NotificationType.parkingEnded,
    );
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
