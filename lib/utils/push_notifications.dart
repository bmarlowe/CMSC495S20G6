import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pantry/data/globals.dart' as globals;

final notifications = new FlutterLocalNotificationsPlugin();

void initNotifications() {
  final settingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
  final settingsIos = IOSInitializationSettings();
  var initSettings = InitializationSettings(settingsAndroid, settingsIos);
  notifications.initialize(initSettings);
  notification();
}

Future notification() async {
  var time = Time(18, 45, 0);
  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'repeatDailyAtTime channel id',
      'repeatDailyAtTime channel name',
      'repeatDailyAtTime description');
  var iOSPlatformChannelSpecifics = IOSNotificationDetails();
  var platformChannelSpecifics = NotificationDetails(
      androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
  await notifications.showDailyAtTime(
      0,
      'You have items expiring within the next 7 days: ',
      '${globals.nearestExpiration.toString}',
      time,
      platformChannelSpecifics);
  print('notification payload: ${globals.nearestExpiration}');
} //notification()
