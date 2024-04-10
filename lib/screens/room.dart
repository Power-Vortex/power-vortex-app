import 'package:flutter/material.dart';
import 'package:powervortex/global.dart';
import 'package:powervortex/database/collections.dart';
import '../obj/objects.dart';
import 'dart:async';

class RoomPage extends StatefulWidget {
  final Room room;
  const RoomPage({super.key, required this.room});

  @override
  State<RoomPage> createState() => _RoomPageState(room);
}
//

class _RoomPageState extends State<RoomPage> {
  // Future runTimer() async {
  //   Timer.periodic(Duration(seconds: 1), (timer) async {
  //     if (userdetails.homes.length > 0) {
  //       for (HomeDetails home in userdetails.homes) {
  //         for (Device device in home.activeDevices) {
  //           if (device.status) {
  //             device.consumption += 0.1;
  //             home.totalconsumption += 0.1;
  //             await changeConsumption(device);
  //           }
  //         }
  //       }
  //     }
  //     setState(() {});
  //   });
  // }

  TextEditingController _devicename = TextEditingController();
  late DeviceType _deviceType;
  String devicename = 'Select type';
  String deviceIndex = '0';
  Room room;
  _RoomPageState(this.room);
  void timedChecker() {
    
    var c = 0.0;
    Timer.periodic(Duration(seconds: 2), (timer) {
      if (mounted)
        setState(() {});
      c = userdetails.homes[homeIndex].totalconsumption;
      if (!mounted) timer.cancel();
      //print(c);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    // getDevices(room).then((value) => setState(() {}));
    //runTimer();
    timedChecker();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
          color: uic.secondary,
        ),
        actions: [
          IconButton(onPressed: (){
          // show bottom sheet
          showModalBottomSheet(
              backgroundColor: uic.secondary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              )),
              context: context,
              builder: (context) {
                return modelSheet(context);
              }).then((value) => setState(() {}));
        }, icon: Icon(Icons.add), color: uic.secondary,)
        ],
        title: Text(room.name,
            style: TextStyle(
              color: uic.secondary,
              fontSize: 23,
              fontWeight: FontWeight.bold,
            )),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      // floatingActionButton: FloatingActionButton(
      //   shape: RoundedRectangleBorder(
      //       borderRadius: BorderRadius.all(Radius.circular(16))),
      //   onPressed: () {},
      //   child: const Icon(Icons.add),
      //   backgroundColor: uic.secondary,
      // ),
      backgroundColor: uic.background,
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.only(left: 20, top: 20, bottom: 30),
            alignment: Alignment.centerLeft,
            child: Text('Connected Devices',
                style: TextStyle(
                  color: uic.textcolor,
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                )),
          ),
          Container(
              height: 600,
              child:
                  //show devices
                  room.boards[0].devices.length == 0
                      ? Center(
                          child: Text("No devices in this room",
                              style: TextStyle(
                                color: uic.textcolor,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              )),
                        )
                      : Container(
                          padding: EdgeInsets.all(20),
                          height: double.infinity,
                          child: ListView.builder(
                            itemCount: room.boards[0].devices.length,
                            itemBuilder: (context, index) {
                              return Column(
                                children: [
                                  Container(
                                    height: 100,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      color: uic.primarySwatch,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.5),
                                          blurRadius: 10,
                                          offset: Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Container(
                                              alignment: Alignment.centerLeft,
                                              padding:
                                                  EdgeInsets.only(right: 20),
                                              child: Text(
                                                  room.boards[0].devices[index]
                                                      .name,
                                                  style: TextStyle(
                                                    color: uic.textcolor,
                                                    fontSize: 32,
                                                    fontWeight: FontWeight.bold,
                                                  )),
                                            ),
                                            Container(
                                              padding: EdgeInsets.only(
                                                  left: 20, right: 20),
                                              child: Text(
                                                  'Consumption : ${room.boards[0].devices[index].consumption} kWh',
                                                  style: TextStyle(
                                                    color: uic.textcolor,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                  )),
                                            )
                                          ],
                                        ),
                                        Container(
                                          alignment: Alignment.center,
                                          height: 100,
                                          width: 100,
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.only(
                                                topRight: Radius.circular(16),
                                                bottomRight:
                                                    Radius.circular(16),
                                              ),
                                              color: uic.secondary),
                                          padding: EdgeInsets.only(
                                              left: 20, right: 20),
                                          child: GestureDetector(
                                            //alignment: Alignment.centerLeft,
                                            child: Icon(
                                              Icons.power_settings_new,
                                              size: 60,
                                              color: !room.boards[0]
                                                      .devices[index].status
                                                  ? Color(0x552B2930)
                                                  : Color(0xff2B2930),
                                            ),
                                            onTap: () {
                                              setState(() {
                                                // print(room.boards[0]
                                                //   .devices[index].status);
                                                room.boards[0].devices[index]
                                                        .status =
                                                    !room.boards[0]
                                                        .devices[index].status;
                                              });
                                              
                                              changeStatus(room
                                                  .boards[0].devices[index]);
                                              userdetails.homes[homeIndex].activeDevices
                                                  .add(room.boards[0].devices[index]);
                                              print(userdetails.homes[homeIndex]
                                                  .activeDevices.length);
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 20)
                                ],
                              );
                            },
                          ),
                        )),
        ],
      ),
    );
  }

  StatefulBuilder modelSheet(BuildContext context) {
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
                          padding:
                              EdgeInsets.only(left: 20, top: 20, bottom: 30),
                          alignment: Alignment.centerLeft,
                          child: Text("Setup Device",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 38,
                                fontWeight: FontWeight.bold,
                              )),
                        ),

                        Container(
                          padding: EdgeInsets.only(left: 20, right: 20),
                          child: TextField(
                            controller: _devicename,
                            decoration: InputDecoration(
                              hintText: "Device Name",
                              hintStyle: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              border: UnderlineInputBorder(

                                  // borderRadius: BorderRadius.circular(16),
                                  ),
                            ),
                          ),
                        ),
                        //add a dropdown for device type
                        SizedBox(height: 20),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.only(left: 20, right: 20),
                              child: DropdownButton(
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                hint: Text(devicename),
                                value: null,
                                onChanged: (value) {
                                  setState(() {
                                    _deviceType = value as DeviceType;
                                    devicename = _deviceType
                                        .toString()
                                        .replaceAll('.', ' : ');
                                  });
                                },
                                items: const[
                                  DropdownMenuItem(
                                    child: Text("Light"),
                                    value: DeviceType.light,
                                  ),
                                  DropdownMenuItem(
                                    child: Text("Fan"),
                                    value: DeviceType.fan,
                                  ),
                                  DropdownMenuItem(
                                    child: Text("AC"),
                                    value: DeviceType.ac,
                                  ),
                                  DropdownMenuItem(
                                    child: Text("TV"),
                                    value: DeviceType.tv,
                                  ),
                                  DropdownMenuItem(
                                    child: Text("Washing Machine"),
                                    value: DeviceType.washingMachine,
                                  ),

                                  DropdownMenuItem(
                                    child: Text("Other"),
                                    value: DeviceType.other,
                                  ),
                                  //add confirm button
                                ],
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
                                hint: Text(deviceIndex),
                                value: null,
                                onChanged: (value) {
                                  setState(() {
                                    deviceIndex = value.toString();
                                  });
                                },
                                items: [
                                  DropdownMenuItem(
                                    child: Text("1"),
                                    value: 1,
                                  ),
                                  DropdownMenuItem(
                                    child: Text("2"),
                                    value: 2,
                                  ),
                                  DropdownMenuItem(
                                    child: Text("3"),
                                    value: 3,
                                  ),
                                  DropdownMenuItem(
                                    child: Text("4"),
                                    value: 4,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
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
                              //add device to room
                              setState(() {
                                room.boards[0].devices.add(Device(
                                  bid: room.boards[0].bid,
                                  index: int.parse(deviceIndex),
                                  consumption: 0,
                                  did: generateID(6),
                                  name: _devicename.text,
                                  type: _deviceType,
                                  status: false,
                                ));
                              });
                              await addDevice(room.boards[0], deviceIndex,
                                  room.boards[0].devices.last);
                              Navigator.of(context).pop();
                            },
                            child: Text("Confirm"),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              });
  }
}
