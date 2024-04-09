import 'dart:async';

import 'package:flutter/material.dart';
import 'package:powervortex/database/collections.dart';
import '../obj/ui.dart';
import '../obj/objects.dart';
import '../global.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class ScheduleData {
  TimeOfDay time;
  Room room;
  Device device;
  bool switchval;
  ScheduleData(this.time, this.room, this.device, this.switchval) {
    Timer.periodic(Duration(seconds: 5), (timer) {
      if (time.hour == TimeOfDay.now().hour &&
          time.minute == TimeOfDay.now().minute) {
        device.status = switchval;
        changeStatus(device);
        showNotification(device.name, room.name, switchval ? 'on' : 'off');

        timer.cancel();
      }
    });
  }
}

class Schedule extends StatefulWidget {
  UIComponents ui;
  Schedule({super.key, required this.ui});

  @override
  State<Schedule> createState() => _ScheduleState(ui);
}

class _ScheduleState extends State<Schedule> {
  TimeOfDay time = TimeOfDay.now();
  UIComponents ui = UIComponents();
  String switchval = 'Switch';
  String roomval = 'Room';
  String deviceval = 'Device';
  _ScheduleState(this.ui);
  List<DropdownMenuItem> roomList = [];
  List<DropdownMenuItem> deviceList = [];

  late Device selectedDevice;
  late Room selectedRoom;
  late bool selectedSwitch;
  List<ScheduleData> schedules = userdetails.homes[homeIndex].schedules;
  void init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings(
      'logotransparent',
    );
    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        print(details.payload);
      },
    );
  }

  @override
  void initState() {
    notifications = FlutterLocalNotificationsPlugin();

    notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()!
        .requestPermission();
    init();
    super.initState();
    if (userdetails.homes.isNotEmpty)
      userdetails.homes[homeIndex].rooms.forEach((element) {
        roomList
            .add(DropdownMenuItem(child: Text(element.name), value: element));
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Container(
        alignment: Alignment.bottomLeft,
        padding: EdgeInsets.only(bottom: 20,left: 40),
        child: FloatingActionButton(
          
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Icon(Icons.add, color: uic.background),
            backgroundColor: uic.secondary,
            onPressed: () {
              showSheet();
            }),
      ),
      backgroundColor: ui.background,
      body: Center(
          child: schedules.isEmpty
              ? Text('No Schedules',
                  style: TextStyle(
                    color: ui.textcolor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ))
              : Column(
                  children: [
                    Container(
                      padding: EdgeInsets.only(left: 20, top: 20, bottom: 30),
                      alignment: Alignment.centerLeft,
                      child: Text("Schedules",
                          style: TextStyle(
                            color: uic.textcolor,
                            fontSize: 38,
                            fontWeight: FontWeight.bold,
                          )),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: schedules.length,
                        itemBuilder: (context, index) {
                          return Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: uic.background),
                            padding:
                                EdgeInsets.only(left: 10, right: 10, top: 10),
                            child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    color: uic.background),
                                height: 120,
                                child: Card(
                                  color: uic.secondary,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16)),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.only(
                                            left: 20, right: 10),
                                        child: Text(
                                            schedules[index]
                                                    .time
                                                    .hour
                                                    .toString() +
                                                ":" +
                                                schedules[index]
                                                    .time
                                                    .minute
                                                    .toString() +
                                                " ",
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 65,
                                              fontWeight: FontWeight.bold,
                                            )),
                                      ),
                                      Container(
                                        padding: EdgeInsets.only(
                                            left: 10, right: 10),
                                        child: Text(schedules[index].room.name,
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            )),
                                      ),
                                      Container(
                                        padding: EdgeInsets.only(
                                            left: 10, right: 10),
                                        child:
                                            Text(schedules[index].device.name,
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                )),
                                      ),
                                      Container(
                                        padding: EdgeInsets.only(
                                            left: 20, right: 20),
                                        child: Text(
                                            schedules[index].switchval
                                                ? 'on'
                                                : 'off',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            )),
                                      ),
                                    ],
                                  ),
                                )),
                          );
                        },
                      ),
                    ),
                  ],
                )),
    );
  }

  void showSheet() {
    showModalBottomSheet(
        backgroundColor: uic.secondary,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        )),
        context: context,
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext ctx, StateSetter setState) {
            return Container(
              height: 500,
              child: Scaffold(
                backgroundColor: Colors.transparent,
                body: ListView(
                  children: [
                    SizedBox(height: 40),
                    Container(
                      padding: EdgeInsets.only(left: 20, top: 20, bottom: 30),
                      alignment: Alignment.centerLeft,
                      child: Text("Schedule Device",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 38,
                            fontWeight: FontWeight.bold,
                          )),
                    ),
                    SizedBox(height: 5),
                    Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.only(left: 20, top: 20, bottom: 5),
                      child: TextButton(
                        onPressed: () async {
                          time = (await showTimePicker(
                            context: context,
                            initialTime: time,
                          ))!;
                          setState(() {});
                        },
                        child: Text(
                            time.hour.toString() +
                                ":" +
                                time.minute.toString() +
                                " ",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 65,
                              fontWeight: FontWeight.bold,
                            )),
                      ),
                    ),

                    Container(
                      padding: EdgeInsets.only(left: 20, right: 20),
                    ),
                    //add a dropdown for device type
                    SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          padding: EdgeInsets.only(left: 20, right: 20),
                          child: DropdownButton(
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            hint: Text(roomval),
                            value: null,
                            onChanged: (value) {
                              deviceList = [];
                              deviceval = 'Device';
                              switchval = 'Switch';
                              value.boards[0].devices.forEach((element) {
                                deviceList.add(DropdownMenuItem(
                                    child: Text(element.name), value: element));
                              });
                              selectedRoom = value;
                              setState(() {
                                roomval = value.name;
                              });
                            },
                            items: roomList,
                          ),
                        ),
                        //add number selecter for device index position in board
                        Container(
                          padding: EdgeInsets.only(left: 20, right: 20),
                          child: DropdownButton(
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            hint: Text(deviceval),
                            value: null,
                            onChanged: (value) {
                              selectedDevice = value;
                              setState(() {
                                deviceval = value.name;
                              });
                            },
                            items: deviceList,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 20, right: 20),
                          child: DropdownButton(
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            hint: Text(switchval),
                            value: null,
                            onChanged: (value) {
                              selectedSwitch = value ?? false;
                              setState(() {
                                value! ? switchval = 'on' : switchval = 'off';
                              });
                            },
                            items: [
                              DropdownMenuItem(
                                child: Text("on"),
                                value: true,
                              ),
                              DropdownMenuItem(
                                child: Text("off"),
                                value: false,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 50),
                    Container(
                      padding: EdgeInsets.only(left: 20, right: 20),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                           backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () async {
                          // await FlutterLocalNotificationsPlugin()
                          //     .resolvePlatformSpecificImplementation<
                          //         AndroidFlutterLocalNotificationsPlugin>()
                          //     ?.createNotificationChannel(
                          //         const AndroidNotificationChannel(
                          //       'your_channel_id',
                          //       'Your Channel Name',
                          //       importance: Importance.max,
                          //     ));

                          //add schedule to list
                          schedules.add(ScheduleData(time, selectedRoom,
                              selectedDevice, selectedSwitch));
                          Navigator.pop(context);
                        },
                        child: Text("Confirm"),
                      ),
                    ),
                  ],
                ),
              ),
            );
          });
        }).then((value) => setState(() {}));
  }
}
