import 'package:firebase_parking/data/models/notification/notification_model.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

abstract class NotificationLocalDataSource {
  Future<FlutterLocalNotificationsPlugin> initialize();
  Future<void> scheduleNotification(NotificationModel notification);
  Future<void> cancelNotification(int id);
  Future<void> cancelAllNotifications();
  Future<bool> requestPermissions();
  Future<bool> areNotificationsEnabled();
}

class NotificationLocalDataSourceImpl implements NotificationLocalDataSource {
  late FlutterLocalNotificationsPlugin _plugin;
  bool _isInitialized = false;

  @override
  Future<FlutterLocalNotificationsPlugin> initialize() async {
    if (_isInitialized) return _plugin;

    await _configureLocalTimeZone();

    _plugin = FlutterLocalNotificationsPlugin();

    const initializationSettingsIOS = DarwinInitializationSettings(requestAlertPermission: true, requestBadgePermission: true, requestSoundPermission: true);

    const initializationSettings = InitializationSettings(iOS: initializationSettingsIOS);

    await _plugin.initialize(initializationSettings, onDidReceiveNotificationResponse: _onNotificationTapped);

    _isInitialized = true;
    print("📱 Notification system initialized for iOS");
    return _plugin;
  }

  void _onNotificationTapped(NotificationResponse response) {
    print("🔔 Notification tapped: ${response.payload}");
    // TO2DO: Handle notification tap - navigate to parking details
  }

  Future<void> _configureLocalTimeZone() async {
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
    print("🌍 Timezone configured: $timeZoneName");
  }

  @override
  Future<void> scheduleNotification(NotificationModel notification) async {
    await initialize();
    await requestPermissions();

    const notificationDetails = NotificationDetails(
      iOS: DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true, sound: 'default', threadIdentifier: 'parking_notifications'),
    );

    final scheduledDate = tz.TZDateTime.from(notification.scheduledTime, tz.local);

    print("⏰ Scheduling notification ID: ${notification.id}");
    print("📅 Scheduled for: ${scheduledDate.toIso8601String()}");
    print("📝 Title: ${notification.title}");

    await _plugin.zonedSchedule(
      notification.id,
      notification.title,
      notification.body,
      scheduledDate,
      notificationDetails,
      payload: notification.parkingId,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  @override
  Future<void> cancelNotification(int id) async {
    await initialize();
    await _plugin.cancel(id);
    print("❌ Cancelled notification ID: $id");
  }

  @override
  Future<void> cancelAllNotifications() async {
    await initialize();
    await _plugin.cancelAll();
    print("🗑️ Cancelled all notifications");
  }

  @override
  Future<bool> requestPermissions() async {
    await initialize();

    final impl = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();

    final result = await impl?.requestPermissions(alert: true, badge: true, sound: true);

    print("🔐 iOS notification permissions result: $result");
    return result ?? false;
  }

  @override
  Future<bool> areNotificationsEnabled() async {
    await initialize();

    final impl = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();

    final result = await impl?.checkPermissions();
    final enabled = result?.isEnabled == true;

    print("✅ Notifications enabled: $enabled");
    return enabled;
  }
}
