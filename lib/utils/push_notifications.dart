import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pantry/screens/login_screen.dart';
import 'package:pantry/data/globals.dart' as globals;

class LocalNotificationWidget extends StatefulWidget {
  @override
  _LocalNotificationWidgetState createState() =>
      _LocalNotificationWidgetState();
}

class _LocalNotificationWidgetState extends State<LocalNotificationWidget> {
  final notifications = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    final settingsAndroid = AndroidInitializationSettings('fresh.jpg');
    final settingsIos = IOSInitializationSettings();
    var initSettings = InitializationSettings(settingsAndroid, settingsIos);
    notifications.initialize(initSettings);
  }

  Future onSelectNotification(String payload) async {
    var androidChannel = AndroidNotificationDetails(
        'channel-id', 'channel-name', 'channel-description',
        importance: Importance.Max, priority: Priority.Max);
    var iosChannel = IOSNotificationDetails();
    var platformChannel = NotificationDetails(androidChannel, iosChannel);
    await Navigator.push(
        context, MaterialPageRoute(builder: (context) => LoginScreen()));
  }

  Future<void> _cancelAllNotifications() async {
    await notifications.cancelAll();
  }

  Future<void> _showDailyAtTime() async {
    var time = Time(10, 0, 0);
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
  }

  @override
  Widget build(BuildContext context) => Container(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          new FloatingActionButton(
              child: Icon(Icons.notifications),
              onPressed: () async {
                onSelectNotification(
                    'You have items expiring within the next 7 days!');
              }),
        ],
      ));
}
