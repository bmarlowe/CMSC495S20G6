import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pantry/screens/home_screen.dart';
import 'package:pantry/models/item.dart';

final notifications = new FlutterLocalNotificationsPlugin();

void initNotifications(List<Item> list) {
  final settingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
  final settingsIos = IOSInitializationSettings();
  var initSettings = InitializationSettings(settingsAndroid, settingsIos);
  notifications.initialize(initSettings);
  notification(list);
}

Future notification(List<Item> list) async {
  BuildContext context;
  var time = Time(10, 0, 0);
  Item sortItem = sortInventory(context, list)[0];

  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'repeatDailyAtTime channel id',
      'repeatDailyAtTime channel name',
      'repeatDailyAtTime description');
  var iOSPlatformChannelSpecifics = IOSNotificationDetails();
  var platformChannelSpecifics = NotificationDetails(
      androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
  Color color = colorCode(sortItem.expiration_date);
  if (color == Color(0xBBFF2222) || color == Color(0xFFFFFF33)) {
    await notifications.showDailyAtTime(
        0,
        'You have items expiring within the next 7 days: ',
        '${sortItem.toString()}',
        time,
        platformChannelSpecifics);
  }
  print('notification payload: ${sortItem.toString()}');
} //notification()
