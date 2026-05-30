import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  late final Future<void> _initialization;

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal() {
    _initialization = _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    // Initialize timezone
    tz_data.initializeTimeZones();

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    // Initialize for Android
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Initialize for iOS
    final DarwinInitializationSettings iOSInitializationSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: androidInitializationSettings,
      iOS: iOSInitializationSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        // Handle notification tap
      },
    );
  }

  /// Schedule a notification at a specific date and time
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDateTime,
  }) async {
    await _initialization;
    try {
      final tz.TZDateTime tzScheduledDateTime =
          tz.TZDateTime.from(scheduledDateTime, tz.local);

      await flutterLocalNotificationsPlugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: tzScheduledDateTime,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'reminder_channel',
            'Reminder Notifications',
            channelDescription: 'Pengingat untuk target dan hutang',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (e) {
      print('Error scheduling notification: $e');
    }
  }

  /// Cancel a scheduled notification
  Future<void> cancelNotification(int id) async {
    await _initialization;
    try {
      await flutterLocalNotificationsPlugin.cancel(id: id);
    } catch (e) {
      print('Error canceling notification: $e');
    }
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _initialization;
    try {
      await flutterLocalNotificationsPlugin.cancelAll();
    } catch (e) {
      print('Error canceling all notifications: $e');
    }
  }

  /// Show an immediate notification (for testing)
  Future<void> showImmediateNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    await _initialization;
    try {
      const AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
        'reminder_channel',
        'Reminder Notifications',
        channelDescription: 'Pengingat untuk target dan hutang',
        importance: Importance.high,
        priority: Priority.high,
      );
      const DarwinNotificationDetails iOSNotificationDetails =
          DarwinNotificationDetails();
      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails,
        iOS: iOSNotificationDetails,
      );

      await flutterLocalNotificationsPlugin.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: notificationDetails,
      );
    } catch (e) {
      print('Error showing immediate notification: $e');
    }
  }
}
