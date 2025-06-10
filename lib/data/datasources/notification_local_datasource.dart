import 'dart:io';
import 'package:firebase_parking/data/models/notification/notification_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

abstract class NotificationLocalDataSource {
  Future<FlutterLocalNotificationsPlugin> initialize();
  Future<void> scheduleNotification(NotificationModel notification);
  Future<void> scheduleNotificationWithActions(NotificationModel notification, {bool includeExtendAction = false});
  Future<void> cancelNotification(int id);
  Future<void> cancelAllNotifications();
  Future<bool> requestPermissions();
  Future<bool> areNotificationsEnabled();
  Future<void> clearAllPendingNotifications(); // ADD THIS
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

    // Platform-specific initialization
    InitializationSettings? initializationSettings;

    if (Platform.isAndroid) {
      // Android initialization settings
      const initializationSettingsAndroid = AndroidInitializationSettings(
        '@mipmap/ic_launcher', // Use app icon instead
      );

      initializationSettings = const InitializationSettings(android: initializationSettingsAndroid);
    } else if (Platform.isIOS) {
      // iOS initialization settings
      const initializationSettingsIOS = DarwinInitializationSettings(requestAlertPermission: true, requestBadgePermission: true, requestSoundPermission: true);

      initializationSettings = const InitializationSettings(iOS: initializationSettingsIOS);
    }

    if (initializationSettings != null) {
      await _plugin.initialize(initializationSettings, onDidReceiveNotificationResponse: _onNotificationTapped);
    }

    _isInitialized = true;

    if (Platform.isAndroid) {
      print("📱 Notification system initialized for Android");
    } else if (Platform.isIOS) {
      print("📱 Notification system initialized for iOS");
    }

    return _plugin;
  }

  void _onNotificationTapped(NotificationResponse response) {
    print("🔔 Notification tapped: ${response.payload}");
    print("🔔 Action ID: ${response.actionId}");

    // Handle different actions
    if (response.actionId != null) {
      _handleNotificationAction(response.actionId!, response.payload);
    } else {
      // Regular notification tap - navigate to parking details
      _handleNotificationTap(response.payload);
    }
  }

  // NEW: Handle notification actions
  void _handleNotificationAction(String actionId, String? parkingId) {
    print("🎬 Handling action: $actionId for parking: $parkingId");

    switch (actionId) {
      case 'extend_30':
        _handleExtendParking(parkingId, const Duration(minutes: 30));
        break;
      case 'extend_60':
        _handleExtendParking(parkingId, const Duration(hours: 1));
        break;
      case 'view_parking':
        _handleViewParkingDetails(parkingId);
        break;
      default:
        print("❓ Unknown action: $actionId");
    }
  }

  // NEW: Handle extend parking action
  void _handleExtendParking(String? parkingId, Duration extension) {
    if (parkingId == null) {
      print("❌ Cannot extend parking: parkingId is null");
      return;
    }

    print("⏰ Extending parking $parkingId by ${extension.inMinutes} minutes");

    // TO2DO: You'll need to emit this to your BLoC or use a callback
    // For now, we'll just log it and show confirmation
    print("🚀 Would extend parking $parkingId by $extension");

    // Show confirmation notification
    _showExtensionConfirmation(extension);
  }

  // NEW: Handle view parking details action
  void _handleViewParkingDetails(String? parkingId) {
    if (parkingId == null) {
      print("❌ Cannot view parking: parkingId is null");
      return;
    }

    print("👁️ Opening parking details for: $parkingId");
    // TOD2O: Navigate to parking details screen
  }

  // NEW: Handle regular notification tap
  void _handleNotificationTap(String? parkingId) {
    if (parkingId == null) {
      print("❌ Cannot handle tap: parkingId is null");
      return;
    }

    print("📱 Opening parking details for: $parkingId");
    // TO2DO: Navigate to parking details screen
  }

  // NEW: Show extension confirmation
  Future<void> _showExtensionConfirmation(Duration extension) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'extension_channel',
        'Extension Confirmations',
        channelDescription: 'Confirmations for parking extensions',
        importance: Importance.high,
        priority: Priority.high,
        autoCancel: true,
      );

      const notificationDetails = NotificationDetails(android: androidDetails);

      await _plugin.show(
        999999, // Use a unique ID for confirmations
        '✅ Extension Requested',
        'Parking extended by ${extension.inMinutes} minutes. Please confirm in the app.',
        notificationDetails,
      );

      print("✅ Extension confirmation notification sent");
    } catch (e) {
      print("❌ Failed to send extension confirmation: $e");
    }
  }

  Future<void> _configureLocalTimeZone() async {
    if (kIsWeb || Platform.isLinux) {
      return;
    }

    tz.initializeTimeZones();

    if (Platform.isWindows) {
      return;
    }

    try {
      final String timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
      print("🌍 Timezone configured: $timeZoneName");
    } catch (e) {
      print("⚠️ Failed to get timezone, using UTC: $e");
      tz.setLocalLocation(tz.getLocation('UTC'));
    }
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

    // Create platform-specific notification details
    NotificationDetails notificationDetails;

    if (Platform.isAndroid) {
      // Android notification details
      const androidDetails = AndroidNotificationDetails(
        'parking_channel', // Channel ID
        'Parking Reminders', // Channel name
        channelDescription: 'Notifications for parking reminders and alerts',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'Parking Reminder',
        showWhen: true,
        icon: '@mipmap/ic_launcher',
        largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        styleInformation: BigTextStyleInformation(''),
        category: AndroidNotificationCategory.alarm,
        fullScreenIntent: true,
        visibility: NotificationVisibility.public,
        enableVibration: true,
        playSound: true,
        autoCancel: true,
      );

      notificationDetails = const NotificationDetails(android: androidDetails);
    } else if (Platform.isIOS) {
      // iOS notification details
      final iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'default',
        badgeNumber: _currentBadgeCount,
        threadIdentifier: 'parking_notifications',
      );

      notificationDetails = NotificationDetails(iOS: iosDetails);
    } else {
      // Fallback for other platforms
      notificationDetails = const NotificationDetails();
    }

    final scheduledDate = tz.TZDateTime.from(notification.scheduledTime, tz.local);

    print("⏰ Scheduling notification ID: ${notification.id}");
    print("📅 Scheduled for: ${scheduledDate.toIso8601String()}");
    print("📝 Title: ${notification.title}");
    print("🔢 Badge number: $_currentBadgeCount");
    print(
      "📱 Platform: ${Platform.isAndroid
          ? 'Android'
          : Platform.isIOS
          ? 'iOS'
          : 'Other'}",
    );

    try {
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

      print("✅ Notification scheduled successfully");
    } catch (e) {
      print("❌ Failed to schedule notification: $e");
      rethrow;
    }
  }

  // NEW: Schedule notification with action buttons
  @override
  Future<void> scheduleNotificationWithActions(NotificationModel notification, {bool includeExtendAction = false}) async {
    await initialize();
    await requestPermissions();

    // Validation: Check if scheduled time is in the future
    final now = DateTime.now();
    final scheduledTime = notification.scheduledTime;

    print("🕐 Current time: ${now.toIso8601String()}");
    print("🕐 Scheduled time: ${scheduledTime.toIso8601String()}");

    if (scheduledTime.isBefore(now) || scheduledTime.isAtSameMomentAs(now)) {
      print("❌ ERROR: Scheduled time is not in the future!");
      return;
    }

    _currentBadgeCount++;

    // Create platform-specific notification details with actions
    NotificationDetails notificationDetails;

    if (Platform.isAndroid) {
      // Create action buttons
      List<AndroidNotificationAction> actions = [];

      if (includeExtendAction) {
        actions.addAll([
          const AndroidNotificationAction(
            'extend_30',
            'Extend 30min',
            // REMOVED: icon (causing visibility issues)
            contextual: false, // Changed to false
            showsUserInterface: true, // NEW: Force show UI
          ),
          const AndroidNotificationAction(
            'extend_60',
            'Extend 1h',
            // REMOVED: icon (causing visibility issues)
            contextual: false, // Changed to false
            showsUserInterface: true, // NEW: Force show UI
          ),
          const AndroidNotificationAction(
            'view_parking',
            'View Details',
            // REMOVED: icon (causing visibility issues)
            contextual: false, // Changed to false
            showsUserInterface: true, // NEW: Force show UI
          ),
        ]);
      }

      // Android notification details with actions
      final androidDetails = AndroidNotificationDetails(
        'parking_channel',
        'Parking Reminders',
        channelDescription: 'Notifications for parking reminders and alerts',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'Parking Reminder',
        showWhen: true,
        icon: '@mipmap/ic_launcher',
        largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        styleInformation: const BigTextStyleInformation(''),
        category: AndroidNotificationCategory.alarm,
        fullScreenIntent: true,
        visibility: NotificationVisibility.public,
        enableVibration: true,
        // REMOVED: enableLights, ledOnMs, ledOffMs (causing crash)
        playSound: true,
        autoCancel: true,
        actions: actions, // Add action buttons
      );

      notificationDetails = NotificationDetails(android: androidDetails);
    } else if (Platform.isIOS) {
      // iOS notification details (iOS also supports actions)
      final iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'default',
        badgeNumber: _currentBadgeCount,
        threadIdentifier: 'parking_notifications',
        categoryIdentifier: includeExtendAction ? 'PARKING_EXTEND' : 'PARKING_DEFAULT',
      );

      notificationDetails = NotificationDetails(iOS: iosDetails);
    } else {
      notificationDetails = const NotificationDetails();
    }

    final scheduledDate = tz.TZDateTime.from(notification.scheduledTime, tz.local);

    print("⏰ Scheduling notification with actions: ${notification.id}");
    print("📅 Scheduled for: ${scheduledDate.toIso8601String()}");
    print("🔘 Include extend action: $includeExtendAction");

    try {
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

      print("✅ Notification with actions scheduled successfully");
    } catch (e) {
      print("❌ Failed to schedule notification with actions: $e");
      rethrow;
    }
  }

  @override
  Future<void> cancelNotification(int id) async {
    await initialize();

    try {
      await _plugin.cancel(id);

      // Decrease badge count when cancelling
      if (_currentBadgeCount > 0) {
        _currentBadgeCount--;
      }

      print("❌ Cancelled notification ID: $id");
      print("🔢 Badge count after cancel: $_currentBadgeCount");
    } catch (e) {
      print("❌ Failed to cancel notification: $e");
      rethrow;
    }
  }

  @override
  Future<void> cancelAllNotifications() async {
    await initialize();

    try {
      await _plugin.cancelAll();

      // Reset badge count
      _currentBadgeCount = 0;

      print("🗑️ Cancelled all notifications");
      print("🔢 Badge count reset to: $_currentBadgeCount");
    } catch (e) {
      print("❌ Failed to cancel all notifications: $e");
      rethrow;
    }
  }

  @override
  Future<bool> requestPermissions() async {
    await initialize();

    try {
      if (Platform.isIOS) {
        final impl = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
        final result = await impl?.requestPermissions(alert: true, badge: true, sound: true);
        print("🔐 iOS notification permissions result: $result");
        return result ?? false;
      } else if (Platform.isAndroid) {
        final impl = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
        final result = await impl?.requestNotificationsPermission();
        print("🔐 Android notification permissions result: $result");
        return result ?? false;
      } else {
        print("🔐 Platform not supported for permission requests");
        return true; // Assume granted for other platforms
      }
    } catch (e) {
      print("❌ Error requesting permissions: $e");
      return false;
    }
  }

  @override
  Future<bool> areNotificationsEnabled() async {
    await initialize();

    try {
      if (Platform.isIOS) {
        final impl = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
        final result = await impl?.checkPermissions();
        final enabled = result?.isEnabled == true;
        print("✅ iOS notifications enabled: $enabled");
        return enabled;
      } else if (Platform.isAndroid) {
        final impl = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
        final result = await impl?.areNotificationsEnabled();
        print("✅ Android notifications enabled: $result");
        return result ?? false;
      } else {
        print("✅ Platform not supported for checking notifications");
        return true; // Assume enabled for other platforms
      }
    } catch (e) {
      print("❌ Error checking notification status: $e");
      return false;
    }
  }

  // NEW: Clear all pending notifications to fix LED crash
  @override
  Future<void> clearAllPendingNotifications() async {
    await initialize();

    try {
      await _plugin.cancelAll();
      print("🗑️ Cleared all pending notifications to fix LED issue");
    } catch (e) {
      print("❌ Failed to clear notifications: $e");
    }
  }
}
