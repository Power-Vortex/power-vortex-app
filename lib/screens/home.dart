import 'dart:async';

import 'package:flutter/material.dart';
import 'package:powervortex/database/collections.dart';
import 'package:powervortex/global.dart';
import '../obj/ui.dart';
import '../obj/objects.dart';
import 'room.dart';

class Home extends StatefulWidget {
  UIComponents ui;
  Home({super.key, required this.ui});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
    if (currentHome != null) {
      rooms = userdetails.homes[homeIndex].rooms;
      activeDevices = currentHome!.activeDevices;
    } else {
      rooms =
          userdetails.homes.isEmpty ? [] : userdetails.homes[homeIndex].rooms;
      activeDevices = userdetails.homes.isEmpty
          ? []
          : userdetails.homes[homeIndex].activeDevices;
    }
    statechange();
  }

  _HomeState() {}

  HomeDetails? currentHome = null;
  List<Device> activeDevices = userdetails.homes.isEmpty
      ? []
      : userdetails.homes[homeIndex].activeDevices;
  void statechange() {
    Timer.periodic(Duration(seconds: 4), (timer) {
      if (!mounted) setState(() {});
    });
  }

  List<Room> rooms = [];
  List<AssetImage> lightimages = [
    AssetImage('assets/room1.png'),
    AssetImage('assets/room2.png')
  ];
  List<AssetImage> darkimages = [
    AssetImage('assets/room1_dark.png'),
    AssetImage('assets/room2_dark.png')
  ];
  void removeDuplicate() {
    for (int i = 0; i < activeDevices.length; i++) {
      for (int j = i + 1; j < activeDevices.length; j++) {
        if (activeDevices[i].did == activeDevices[j].did) {
          activeDevices.removeAt(j);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    removeDuplicate();
    return Container(
      width: double.infinity,
      child: RefreshIndicator(
        backgroundColor: uic.primarySwatch,
        color: uic.yellow,
        onRefresh: () async {
          if (currentHome != null) {
            rooms = userdetails.homes[homeIndex].rooms;
            activeDevices = currentHome!.activeDevices;
          } else {
            rooms = userdetails.homes.isEmpty
                ? []
                : userdetails.homes[homeIndex].rooms;
            activeDevices = userdetails.homes.isEmpty
                ? []
                : userdetails.homes[homeIndex].activeDevices;
          }
          setState(() {});
        },
        child: ListView(
          children: <Widget>[
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Active Devices',
                style: TextStyle(
                  color: uic.textcolor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.all(8),
              height: 240,
              child: activeDevices.isEmpty
                  ? GestureDetector(
                      onHorizontalDragEnd: (details) {
                        //print('ouch');
                        setState(() {});
                      },
                      child: Center(
                          child: Text(
                        'no active devices',
                        style: TextStyle(
                          color: uic.textcolor,
                          fontSize: 18,
                        ),
                      )),
                    )
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: activeDevices.length,
                      itemBuilder: (context, index) {
                        return Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 15, bottom: 20, top: 10),
                              child: Container(
                                // duration: Duration(milliseconds: 500),

                                width: 175,
                                height: 200,
                                alignment: Alignment.center,
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: uic.primarySwatch,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.5),
                                      blurRadius: 10,
                                      offset: Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(
                                      activeDevices[index].name,
                                      style: TextStyle(
                                        color: uic.textcolor,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Container(
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 10),
                                        child: GestureDetector(
                                          //alignment: Alignment.centerLeft,
                                          child: Icon(
                                            Icons.power_settings_new,
                                            size: 100,
                                            color: activeDevices[index].status
                                                ? uic.switchon
                                                : uic.switchoff,
                                          ),
                                          onTap: () {
                                            activeDevices[index].status =
                                                !activeDevices[index].status;
                                            //remove duplicates from active devices
                                            changeStatus(activeDevices[index]);
                                            setState(() {});
                                            Future.delayed(Duration(seconds: 3),
                                                () {
                                              setState(() {
                                                if (!activeDevices[index]
                                                    .status) {
                                                  activeDevices.removeAt(index);
                                                }
                                              });
                                            });
                                            print(activeDevices);
                                          },
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      getRoomFromDeviceID(
                                              activeDevices[index].did)
                                          .name,
                                      style: TextStyle(
                                        color: uic.textcolor,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                          ],
                        );
                      },
                    ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                userdetails.homes.isEmpty
                    ? 'Home'
                    : userdetails.homes[homeIndex].name,
                style: TextStyle(
                  color: uic.textcolor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.all(8),
              child: (userdetails.homes.isEmpty || rooms.isEmpty)
                  ? Center(
                      child: Text(
                      'no rooms found. kindly setup your home',
                      style: TextStyle(
                        color: uic.textcolor,
                        fontSize: 18,
                      ),
                    ))
                  : ListView.builder(
                      itemCount: rooms.length,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, _index) {
                        return Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: uic.primarySwatch,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.5),
                                    blurRadius: 10,
                                    offset: Offset(0, 10),
                                  ),
                                ],
                              ),
                              //color: ui.primarySwatch,
                              height: 200,
                              width: MediaQuery.of(context).size.width - 30,
                              //padding: EdgeInsets.all(8),
                              child: GestureDetector(
                                onTap: () {
                                  //print('tap');
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => RoomPage(
                                                room: rooms[_index],
                                              ))).then((value) => {
                                        setState(() {
                                          activeDevices = userdetails
                                              .homes[homeIndex].activeDevices;
                                        })
                                      });
                                },
                                child: Stack(
                                  children: [
                                    Column(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(10),
                                          alignment: Alignment.topLeft,
                                          height: 140,
                                          child: Text(
                                            rooms[_index].name,
                                            style: TextStyle(
                                              color: uic.textcolor,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: uic.secondary,
                                            borderRadius: BorderRadius.only(
                                              bottomLeft: Radius.circular(20),
                                              bottomRight: Radius.circular(20),
                                            ),
                                          ),
                                          height: 60,
                                          width: double.infinity,
                                          padding: EdgeInsets.only(left: 10),
                                          alignment: Alignment.centerLeft,
                                          child: Container(
                                            height: 40,
                                            width: 100,
                                            decoration: BoxDecoration(
                                                color: uic.primarySwatch,
                                                borderRadius:
                                                    BorderRadius.circular(20)),
                                            child: Center(
                                              child: Text(
                                                'Open',
                                                style: TextStyle(
                                                  color: uic.textcolor,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Container(
                                        height: 200,
                                        width: 250,
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: !uic.isDark
                                                ? rooms[_index].lightimage
                                                : rooms[_index].darkimage,
                                            fit: BoxFit.cover,
                                          ),
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(20),
                                            bottomRight: Radius.circular(20),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 30),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
