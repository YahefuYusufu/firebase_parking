import 'dart:io';
import 'dart:math';
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
  Future<void> cancelNotificationsForParking(String parkingId); // NEW: Cancel specific parking notifications
  Future<bool> requestPermissions();
  Future<bool> areNotificationsEnabled();
  Future<void> clearAllPendingNotifications();
}

class NotificationLocalDataSourceImpl implements NotificationLocalDataSource {
  late FlutterLocalNotificationsPlugin _plugin;
  bool _isInitialized = false;
  int _currentBadgeCount = 0;

  // NEW: Track active notifications to prevent conflicts
  final Map<String, List<int>> _activeNotificationsByParking = {};
  final Set<int> _usedNotificationIds = {};

  @override
  Future<FlutterLocalNotificationsPlugin> initialize() async {
    if (_isInitialized) return _plugin;

    await _configureLocalTimeZone();

    _plugin = FlutterLocalNotificationsPlugin();

    // Platform-specific initialization
    InitializationSettings? initializationSettings;

    if (Platform.isAndroid) {
      const initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
      initializationSettings = const InitializationSettings(android: initializationSettingsAndroid);
    } else if (Platform.isIOS) {
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

  // NEW: Generate truly unique notification IDs
  int _generateUniqueNotificationId() {
    int id;
    int attempts = 0;

    do {
      // Combine timestamp, random number, and attempt counter for uniqueness
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final random = Random().nextInt(10000);
      id = ((timestamp + random + attempts) % 2147483647).toInt();
      attempts++;

      if (attempts > 100) {
        // Fallback: use timestamp + large random
        id = ((timestamp + Random().nextInt(1000000)) % 2147483647).toInt();
        break;
      }
    } while (_usedNotificationIds.contains(id));

    _usedNotificationIds.add(id);
    print("🆔 Generated unique notification ID: $id (attempts: $attempts)");

    return id;
  }

  // NEW: Cancel all notifications for a specific parking session
  @override
  Future<void> cancelNotificationsForParking(String parkingId) async {
    await initialize();

    final notificationIds = _activeNotificationsByParking[parkingId];
    if (notificationIds != null && notificationIds.isNotEmpty) {
      print("🗑️ Cancelling ${notificationIds.length} notifications for parking: $parkingId");

      for (final id in notificationIds) {
        try {
          await _plugin.cancel(id);
          _usedNotificationIds.remove(id);
          print("❌ Cancelled notification ID: $id");
        } catch (e) {
          print("❌ Failed to cancel notification $id: $e");
        }
      }

      // Clear tracking for this parking
      _activeNotificationsByParking.remove(parkingId);
      print("🧹 Cleared tracking for parking: $parkingId");
    } else {
      print("ℹ️ No active notifications found for parking: $parkingId");
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    print("🔔 Notification tapped: ${response.payload}");
    print("🔔 Action ID: ${response.actionId}");

    if (response.actionId != null) {
      _handleNotificationAction(response.actionId!, response.payload);
    } else {
      _handleNotificationTap(response.payload);
    }
  }

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

  void _handleExtendParking(String? parkingId, Duration extension) {
    if (parkingId == null) {
      print("❌ Cannot extend parking: parkingId is null");
      return;
    }

    print("⏰ Extending parking $parkingId by ${extension.inMinutes} minutes");
    print("🚀 Would extend parking $parkingId by $extension");

    _showExtensionConfirmation(extension);
  }

  void _handleViewParkingDetails(String? parkingId) {
    if (parkingId == null) return;
    print("👁️ Opening parking details for: $parkingId");
  }

  void _handleNotificationTap(String? parkingId) {
    if (parkingId == null) return;
    print("📱 Opening parking details for: $parkingId");
  }

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
        _generateUniqueNotificationId(), // Use unique ID
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
    if (kIsWeb || Platform.isLinux) return;

    tz.initializeTimeZones();

    if (Platform.isWindows) return;

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

    // NEW: Cancel previous notifications for this parking session
    if (notification.parkingId != null) {
      await cancelNotificationsForParking(notification.parkingId!);
    }

    final now = DateTime.now();
    final scheduledTime = notification.scheduledTime;

    print("🕐 Current time: ${now.toIso8601String()}");
    print("🕐 Scheduled time: ${scheduledTime.toIso8601String()}");
    print("🕐 Time difference: ${scheduledTime.difference(now).inSeconds} seconds");

    if (scheduledTime.isBefore(now) || scheduledTime.isAtSameMomentAs(now)) {
      print("❌ ERROR: Scheduled time is not in the future!");

      final correctedTime = now.add(const Duration(seconds: 5));
      print("🔧 Auto-correcting to: $correctedTime");

      final correctedNotification = NotificationModel(
        id: _generateUniqueNotificationId(), // Generate new unique ID
        title: notification.title,
        body: "${notification.body} [Auto-corrected]",
        scheduledTime: correctedTime,
        parkingId: notification.parkingId,
        type: notification.type,
      );

      return await scheduleNotification(correctedNotification);
    }

    // Generate unique ID for this notification
    final uniqueId = _generateUniqueNotificationId();

    // Track this notification
    if (notification.parkingId != null) {
      _activeNotificationsByParking[notification.parkingId!] = (_activeNotificationsByParking[notification.parkingId!] ?? [])..add(uniqueId);
    }

    // Increment badge count
    _currentBadgeCount++;

    // Create platform-specific notification details
    NotificationDetails notificationDetails;

    if (Platform.isAndroid) {
      final androidDetails = AndroidNotificationDetails(
        'parking_channel_${uniqueId % 10}', // Keep braces for expressions
        'Parking Reminders',
        channelDescription: 'Notifications for parking reminders and alerts',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'Parking Reminder ${DateTime.now().millisecondsSinceEpoch}', // Keep braces for expressions
        showWhen: true,
        when: scheduledTime.millisecondsSinceEpoch, // NEW: Explicit timestamp
        icon: '@mipmap/ic_launcher',
        largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        styleInformation: BigTextStyleInformation(
          notification.body,
          contentTitle: notification.title,
          summaryText: 'Parking Alert $uniqueId', // Removed unnecessary braces
        ),
        category: AndroidNotificationCategory.alarm,
        fullScreenIntent: true,
        visibility: NotificationVisibility.public,
        enableVibration: true,
        playSound: true,
        autoCancel: true,
        ongoing: false, // NEW: Ensure notifications can be dismissed
        onlyAlertOnce: false, // NEW: Always alert
        tag: 'parking_${notification.parkingId}_$uniqueId', // Mixed: keep braces for complex, remove for simple
      );

      notificationDetails = NotificationDetails(android: androidDetails);
    } else if (Platform.isIOS) {
      final iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'default',
        badgeNumber: _currentBadgeCount,
        threadIdentifier: 'parking_${notification.parkingId}_$uniqueId', // Mixed interpolation
        subtitle: 'Parking Alert $uniqueId', // Removed unnecessary braces
        attachments: [], // NEW: Empty attachments to prevent grouping issues
      );

      notificationDetails = NotificationDetails(iOS: iosDetails);
    } else {
      notificationDetails = const NotificationDetails();
    }

    final scheduledDate = tz.TZDateTime.from(notification.scheduledTime, tz.local);

    print("⏰ Scheduling notification ID: $uniqueId (original: ${notification.id})");
    print("📅 Scheduled for: ${scheduledDate.toIso8601String()}");
    print("📝 Title: ${notification.title}");
    print("🔢 Badge number: $_currentBadgeCount");
    print("🏷️ Parking ID: ${notification.parkingId}");

    try {
      await _plugin.zonedSchedule(
        uniqueId, // Use the unique ID we generated
        notification.title,
        notification.body,
        scheduledDate,
        notificationDetails,
        payload: notification.parkingId,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );

      print("✅ Notification scheduled successfully with unique ID: $uniqueId");
    } catch (e) {
      print("❌ Failed to schedule notification: $e");

      // Remove from tracking if failed
      if (notification.parkingId != null) {
        _activeNotificationsByParking[notification.parkingId!]?.remove(uniqueId);
      }
      _usedNotificationIds.remove(uniqueId);

      rethrow;
    }
  }

  @override
  Future<void> scheduleNotificationWithActions(NotificationModel notification, {bool includeExtendAction = false}) async {
    await initialize();
    await requestPermissions();

    // Cancel previous notifications for this parking session
    if (notification.parkingId != null) {
      await cancelNotificationsForParking(notification.parkingId!);
    }

    final now = DateTime.now();
    final scheduledTime = notification.scheduledTime;

    print("🕐 Current time: ${now.toIso8601String()}");
    print("🕐 Scheduled time: ${scheduledTime.toIso8601String()}");

    if (scheduledTime.isBefore(now) || scheduledTime.isAtSameMomentAs(now)) {
      print("❌ ERROR: Scheduled time is not in the future!");
      return;
    }

    final uniqueId = _generateUniqueNotificationId();

    // Track this notification
    if (notification.parkingId != null) {
      _activeNotificationsByParking[notification.parkingId!] = (_activeNotificationsByParking[notification.parkingId!] ?? [])..add(uniqueId);
    }

    _currentBadgeCount++;

    NotificationDetails notificationDetails;

    if (Platform.isAndroid) {
      List<AndroidNotificationAction> actions = [];

      if (includeExtendAction) {
        actions.addAll([
          const AndroidNotificationAction('extend_30', 'Extend 30min', contextual: false, showsUserInterface: true),
          const AndroidNotificationAction('extend_60', 'Extend 1h', contextual: false, showsUserInterface: true),
          const AndroidNotificationAction('view_parking', 'View Details', contextual: false, showsUserInterface: true),
        ]);
      }

      final androidDetails = AndroidNotificationDetails(
        'parking_actions_${uniqueId % 10}', // Keep braces for expressions
        'Parking Reminders with Actions',
        channelDescription: 'Interactive parking notifications',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'Parking Action ${DateTime.now().millisecondsSinceEpoch}',
        showWhen: true,
        when: scheduledTime.millisecondsSinceEpoch,
        icon: '@mipmap/ic_launcher',
        largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        styleInformation: BigTextStyleInformation(notification.body, contentTitle: notification.title, summaryText: 'Interactive Alert $uniqueId'),
        category: AndroidNotificationCategory.alarm,
        fullScreenIntent: true,
        visibility: NotificationVisibility.public,
        enableVibration: true,
        playSound: true,
        autoCancel: true,
        actions: actions,
        tag: 'parking_action_${notification.parkingId}_$uniqueId',
      );

      notificationDetails = NotificationDetails(android: androidDetails);
    } else if (Platform.isIOS) {
      final iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'default',
        badgeNumber: _currentBadgeCount,
        threadIdentifier: 'parking_action_${notification.parkingId}_$uniqueId',
        categoryIdentifier: includeExtendAction ? 'PARKING_EXTEND' : 'PARKING_DEFAULT',
        subtitle: 'Interactive Alert $uniqueId',
      );

      notificationDetails = NotificationDetails(iOS: iosDetails);
    } else {
      notificationDetails = const NotificationDetails();
    }

    final scheduledDate = tz.TZDateTime.from(notification.scheduledTime, tz.local);

    print("⏰ Scheduling interactive notification: $uniqueId");
    print("🔘 Include extend action: $includeExtendAction");

    try {
      await _plugin.zonedSchedule(
        uniqueId,
        notification.title,
        notification.body,
        scheduledDate,
        notificationDetails,
        payload: notification.parkingId,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );

      print("✅ Interactive notification scheduled successfully");
    } catch (e) {
      print("❌ Failed to schedule interactive notification: $e");

      // Remove from tracking if failed
      if (notification.parkingId != null) {
        _activeNotificationsByParking[notification.parkingId!]?.remove(uniqueId);
      }
      _usedNotificationIds.remove(uniqueId);

      rethrow;
    }
  }

  @override
  Future<void> cancelNotification(int id) async {
    await initialize();

    try {
      await _plugin.cancel(id);
      _usedNotificationIds.remove(id);

      if (_currentBadgeCount > 0) {
        _currentBadgeCount--;
      }

      print("❌ Cancelled notification ID: $id");
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

      // Clear all tracking
      _activeNotificationsByParking.clear();
      _usedNotificationIds.clear();
      _currentBadgeCount = 0;

      print("🗑️ Cancelled all notifications and cleared tracking");
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
        return true;
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
        return true;
      }
    } catch (e) {
      print("❌ Error checking notification status: $e");
      return false;
    }
  }

  @override
  Future<void> clearAllPendingNotifications() async {
    await initialize();

    try {
      await _plugin.cancelAll();
      _activeNotificationsByParking.clear();
      _usedNotificationIds.clear();
      print("🗑️ Cleared all pending notifications");
    } catch (e) {
      print("❌ Failed to clear notifications: $e");
    }
  }
}
