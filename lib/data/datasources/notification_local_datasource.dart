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
  int _currentBadgeCount = 0; // Track badge count

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
    // TOD2O: Handle notification tap - navigate to parking details
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

    // Validation: Check if scheduled time is in the future
    final now = DateTime.now();
    final scheduledTime = notification.scheduledTime;

    print("🕐 Current time: ${now.toIso8601String()}");
    print("🕐 Scheduled time: ${scheduledTime.toIso8601String()}");
    print("🕐 Time difference: ${scheduledTime.difference(now).inSeconds} seconds");

    if (scheduledTime.isBefore(now) || scheduledTime.isAtSameMomentAs(now)) {
      print("❌ ERROR: Scheduled time is not in the future!");
      print("❌ Current: $now");
      print("❌ Scheduled: $scheduledTime");

      // Auto-fix: Schedule 5 seconds from now
      final correctedTime = now.add(const Duration(seconds: 5));
      print("🔧 Auto-correcting to: $correctedTime");

      final correctedNotification = NotificationModel(
        id: notification.id,
        title: notification.title,
        body: "${notification.body} [Auto-corrected]",
        scheduledTime: correctedTime,
        parkingId: notification.parkingId,
        type: notification.type,
      );

      // Recursively call with corrected time
      return await scheduleNotification(correctedNotification);
    }

    // Increment badge count for each notification
    _currentBadgeCount++;

    final notificationDetails = NotificationDetails(
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'default',
        badgeNumber: _currentBadgeCount, // Use incrementing badge number
        threadIdentifier: 'parking_notifications',
      ),
    );

    final scheduledDate = tz.TZDateTime.from(notification.scheduledTime, tz.local);

    print("⏰ Scheduling notification ID: ${notification.id}");
    print("📅 Scheduled for: ${scheduledDate.toIso8601String()}");
    print("📝 Title: ${notification.title}");
    print("🔢 Badge number: $_currentBadgeCount");

    await _plugin.zonedSchedule(
      notification.id,
      notification.title,
      notification.body,
      scheduledDate,
      notificationDetails,
      payload: notification.parkingId,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  @override
  Future<void> cancelNotification(int id) async {
    await initialize();
    await _plugin.cancel(id);

    // Decrease badge count when cancelling
    if (_currentBadgeCount > 0) {
      _currentBadgeCount--;
    }

    print("❌ Cancelled notification ID: $id");
    print("🔢 Badge count after cancel: $_currentBadgeCount");
  }

  @override
  Future<void> cancelAllNotifications() async {
    await initialize();
    await _plugin.cancelAll();

    // Reset badge count
    _currentBadgeCount = 0;

    print("🗑️ Cancelled all notifications");
    print("🔢 Badge count reset to: $_currentBadgeCount");
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
