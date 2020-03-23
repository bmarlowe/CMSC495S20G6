import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pantry/data/connect_repository.dart';
import 'package:pantry/screens/home_screen.dart';
import 'package:pantry/models/item.dart';
import 'package:shared_preferences/shared_preferences.dart';

final notifications = new FlutterLocalNotificationsPlugin();

void initNotifications() {
  final settingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
  final settingsIos = IOSInitializationSettings();
  var initSettings = InitializationSettings(settingsAndroid, settingsIos);
  notifications.initialize(initSettings);
  notification();
}

Future notification() async {
  BuildContext context;
  var time = Time(20, 15, 0);
  SharedPreferences sp = await SharedPreferences.getInstance();
  var response;
  final String inventoryList = 'inventoryList';
  response = sp.getString(inventoryList);
  List<Item> unsorted = parseItems(response);
  Item sortItem = sortInventory(context, unsorted)[0];

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
      '${sortItem.toString()}',
      time,
      platformChannelSpecifics);
  print('notification payload: ${sortItem.toString()}');
} //notification()
