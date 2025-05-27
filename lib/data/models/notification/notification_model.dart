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

  // Create parking reminder notifications
  static List<NotificationModel> createParkingReminders({required String parkingId, required String vehicleRegistration, required DateTime parkingStartTime}) {
    final List<NotificationModel> notifications = [];
    final baseId = DateTime.now().millisecondsSinceEpoch % 2147483647;
    // 1 hour reminder
    notifications.add(
      NotificationModel(
        id: baseId + 1,
        title: "Parking Reminder",
        body: "You've been parked for 1 hour with $vehicleRegistration",
        scheduledTime: parkingStartTime.add(const Duration(hours: 1)),
        parkingId: parkingId,
        type: NotificationType.parkingReminder,
      ),
    );

    // 2 hour reminder
    notifications.add(
      NotificationModel(
        id: baseId + 2,
        title: "Parking Reminder",
        body: "You've been parked for 2 hours with $vehicleRegistration",
        scheduledTime: parkingStartTime.add(const Duration(hours: 2)),
        parkingId: parkingId,
        type: NotificationType.parkingReminder,
      ),
    );

    // 4 hour reminder
    notifications.add(
      NotificationModel(
        id: baseId + 3,
        title: "Long Parking Alert",
        body: "You've been parked for 4 hours with $vehicleRegistration. Don't forget to check your parking!",
        scheduledTime: parkingStartTime.add(const Duration(hours: 4)),
        parkingId: parkingId,
        type: NotificationType.parkingReminder,
      ),
    );

    // 8 hour reminder (daily reminder)
    notifications.add(
      NotificationModel(
        id: baseId + 4,
        title: "Daily Parking Reminder",
        body: "You've been parked all day with $vehicleRegistration. Current cost may be significant.",
        scheduledTime: parkingStartTime.add(const Duration(hours: 8)),
        parkingId: parkingId,
        type: NotificationType.parkingReminder,
      ),
    );

    return notifications;
  }

  // Create parking started notification
  static NotificationModel createParkingStarted({required String parkingId, required String vehicleRegistration, required String parkingSpaceNumber}) {
    return NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch,
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
      id: DateTime.now().millisecondsSinceEpoch,
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
