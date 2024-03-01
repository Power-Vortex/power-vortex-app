import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:powervortex/obj/objects.dart';
import 'database/auth.dart';
import 'obj/ui.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:image_picker/image_picker.dart';

late User? currentuser;
late UIComponents uic;
late UserDetails userdetails;
int dayindex = 0;
List schedules = [];
late Image image;
int homeIndex = 0;
late FlutterLocalNotificationsPlugin notifications;
Future<void> showNotification(devicename, roomname, status) async {
  AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
          '123', // Replace with your channel ID
          'Schedule', // Replace with your channel name
          // Replace with your channel description
          importance: Importance.max,
          priority: Priority.high,
          showWhen: false,
          color: uic.yellow);

  NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  await notifications.show(
    0, // Notification ID
    'Schedule', // Notification title
    '$devicename of $roomname has turned $status', // Notification body
    platformChannelSpecifics,
    payload: 'Custom Payload',
  );
}

//fn to find device from room name and device name
Device getDeviceFromName(
    {required String roomname, required String devicename}) {
  for (var room in userdetails.homes[homeIndex].rooms) {
   // print(room.name.toLowerCase() + ' ' + roomname.toLowerCase());
    if (room.name.toLowerCase() == roomname.toLowerCase()) {
      for (var board in room.boards) {
        for (var device in board.devices) {
          if (device.name.toLowerCase() == devicename.toLowerCase()) {
            return device;
          }
        }
      }
    }
  }
  return Device(
      did: '0000',
      name: 'error',
      type: DeviceType.other,
      status: true,
      consumption: 00,
      index: 0,
      bid: '0000');
}
