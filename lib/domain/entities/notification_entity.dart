import 'package:equatable/equatable.dart';

class NotificationEntity extends Equatable {
  final int id;
  final String title;
  final String body;
  final DateTime scheduledTime;
  final String? parkingId;
  final NotificationType type;

  const NotificationEntity({required this.id, required this.title, required this.body, required this.scheduledTime, this.parkingId, required this.type});

  @override
  List<Object?> get props => [id, title, body, scheduledTime, parkingId, type];

  NotificationEntity copyWith({int? id, String? title, String? body, DateTime? scheduledTime, String? parkingId, NotificationType? type}) {
    return NotificationEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      parkingId: parkingId ?? this.parkingId,
      type: type ?? this.type,
    );
  }
}

enum NotificationType { parkingReminder, parkingExpiry, parkingStarted, parkingEnded }
