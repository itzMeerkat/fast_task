// // Notification service for scheduling daily progress reminders

// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/data/latest_all.dart' as tz;
// import 'package:timezone/timezone.dart' as tz;
// import 'package:shared_preferences/shared_preferences.dart';

// /// Service for managing local notifications
// class NotificationService {
//   static NotificationService? _instance;
//   final FlutterLocalNotificationsPlugin _notifications;

//   NotificationService._()
//       : _notifications = FlutterLocalNotificationsPlugin();

//   /// Get singleton instance
//   static NotificationService get instance {
//     _instance ??= NotificationService._();
//     return _instance!;
//   }

//   /// Initialize notification plugin and timezone
//   Future<void> initialize() async {
//     tz.initializeTimeZones();

//     const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
//     const iosSettings = DarwinInitializationSettings(
//       requestAlertPermission: true,
//       requestBadgePermission: true,
//       requestSoundPermission: true,
//     );

//     const initSettings = InitializationSettings(
//       android: androidSettings,
//       iOS: iosSettings,
//     );

//     await _notifications.initialize(initSettings);

//     // Request permissions for iOS
//     await _notifications
//         .resolvePlatformSpecificImplementation<
//             IOSFlutterLocalNotificationsPlugin>()
//         ?.requestPermissions(
//           alert: true,
//           badge: true,
//           sound: true,
//         );

//     // Request permissions for Android 13+
//     await _notifications
//         .resolvePlatformSpecificImplementation<
//             AndroidFlutterLocalNotificationsPlugin>()
//         ?.requestNotificationsPermission();
//   }

//   /// Schedule daily progress reminder at 10 PM
//   Future<void> scheduleProgressReminder() async {
//     final prefs = await SharedPreferences.getInstance();
//     final now = DateTime.now();
//     final today = DateTime(now.year, now.month, now.day);
//     final tomorrow = today.add(const Duration(days: 1));

//     // Check if notification already scheduled for today
//     final todayKey = 'notification_${today.millisecondsSinceEpoch}';
//     final tomorrowKey = 'notification_${tomorrow.millisecondsSinceEpoch}';

//     final todayScheduled = prefs.getBool(todayKey) ?? false;
//     final tomorrowScheduled = prefs.getBool(tomorrowKey) ?? false;

//     // Schedule for today at 10 PM if not already scheduled and time hasn't passed
//     if (!todayScheduled) {
//       final todayAt10PM = DateTime(now.year, now.month, now.day, 22, 0);
//       if (todayAt10PM.isAfter(now)) {
//         await _scheduleNotification(
//           0,
//           todayAt10PM,
//           'Time to record your progress!',
//           'Don\'t forget to log your work for today.',
//         );
//         await prefs.setBool(todayKey, true);
//       }
//     }

//     // Schedule for tomorrow at 10 PM if not already scheduled
//     if (!tomorrowScheduled) {
//       final tomorrowAt10PM = DateTime(
//         tomorrow.year,
//         tomorrow.month,
//         tomorrow.day,
//         22,
//         0,
//       );
//       await _scheduleNotification(
//         1,
//         tomorrowAt10PM,
//         'Time to record your progress!',
//         'Don\'t forget to log your work for today.',
//       );
//       await prefs.setBool(tomorrowKey, true);
//     }
//   }

//   /// Schedule a notification at specific time
//   Future<void> _scheduleNotification(
//     int id,
//     DateTime scheduledTime,
//     String title,
//     String body,
//   ) async {
//     final scheduledDate = tz.TZDateTime.from(scheduledTime, tz.local);

//     const androidDetails = AndroidNotificationDetails(
//       'task_tracker_reminders',
//       'Progress Reminders',
//       channelDescription: 'Daily reminders to record task progress',
//       importance: Importance.high,
//       priority: Priority.high,
//     );

//     const iosDetails = DarwinNotificationDetails();

//     const details = NotificationDetails(
//       android: androidDetails,
//       iOS: iosDetails,
//     );

//     await _notifications.zonedSchedule(
//       id,
//       title,
//       body,
//       scheduledDate,
//       details,
//       androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
//     );
//   }

//   /// Cancel all scheduled notifications
//   Future<void> cancelAllNotifications() async {
//     await _notifications.cancelAll();
//   }
// }
