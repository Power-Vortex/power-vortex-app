import 'package:firebase_database/firebase_database.dart';
import 'package:powervortex/global.dart';
import 'package:powervortex/obj/objects.dart';
import 'dart:async';
import '../global.dart';
import 'package:powervortex/screens/home.dart';
import '../obj/objects.dart';

Future updateUserHomes(HomeDetails home) async {
  final homeref = await FirebaseDatabase.instance
      .ref()
      .child("users")
      .child(currentuser!.uid)
      .child("homes");
  print(home.rooms);
  homeref.child(home.hid).set(home.name);
  List uids = [];
  List rooms = [];
  for (UserDetails user in home.users) {
    uids.add(user.uid);
  }
  for (Room room in home.rooms) {
    rooms.add({
      'name': room.name,
      'board': room.boards.first.bid,
      'roomid': room.rid,
    });
  }

  print(rooms);
  print(uids);
  final dbRef = await FirebaseDatabase.instance.ref();
  await dbRef.child('homes').child(home.hid).child("users").set(uids);
  await dbRef.child('homes').child(home.hid).child("rooms").set(rooms);
  await dbRef
      .child('homes')
      .child(home.hid)
      .child("consumptionhistory")
      .set(home.consumptionHistory);
}

Future getAllHomes() async {
  userdetails.homes = [];
  final dbref =
      FirebaseDatabase.instance.ref().child('users').child(currentuser!.uid);
  await dbref.once().then((DatabaseEvent event) async {
    DataSnapshot snap = event.snapshot;
    userdetails.homes = [];
    for (var i = 0; i < snap.child('homes').children.length; i++) {
      await getHomeDetails(i);
    }
  });
}

//fn to get the home details of the user
Future getHomeDetails(index) async {
  String homeID;
  final homeidref = await FirebaseDatabase.instance
      .ref()
      .child("users")
      .child(currentuser!.uid);
  bool exist =
      await homeidref.once().then((value) => value.snapshot.hasChild('homes'));

  if (exist) {
    homeidref.child("homes").once().then((DatabaseEvent snapshot) async {
      DataSnapshot values1 = snapshot.snapshot;
      homeID = values1.children.elementAt(index).key.toString();
      if (!userdetails.homes.any((element) {
        print('elemetn : ${element.hid} : $homeID');
        if (element.hid == homeID) {
          print('yes');
          return true;
        } else
          return false;
      })) {
        //print(homeID);
        final homeref =
            await FirebaseDatabase.instance.ref().child("homes").child(homeID);
        homeref.once().then((DatabaseEvent snapshot) async {
          DataSnapshot values = snapshot.snapshot;
          print(
              List.from(values.child('consumptionhistory').value as Iterable));
          List chist =
              List.from(values.child('consumptionhistory').value as List);
          print('datafrom db {$chist}');
          HomeDetails home = HomeDetails(
            hid: homeID,
            name: values1.children.elementAt(index).value.toString(),
            users: [],
            rooms: [],
          );
          home.consumptionHistory = chist;

          home.users.add(userdetails);
          // print(values.child('rooms'));
          List rooms = List.from(values.child('rooms').value as Iterable);
          print(rooms);
          for (var room in rooms) {
            Room roomdetails = Room(
              //lightimage: 'assets/images/light.png',
              type: RoomType.other,
              rid: room['roomid'].toString(),
              name: room['name'].toString(),
              boards: [
                Board(
                  bid: room['board'].toString(),
                  devices: [],
                )
              ],
            );

            home.rooms.add(roomdetails);
          }
          userdetails.homes.add(home);
          //updateUserHomes();
// print(userdetails.homes[index].rooms);
          final dbRef = await FirebaseDatabase.instance.ref();

          for (Room room in userdetails.homes[index].rooms) {
            await dbRef.child('boards').once().then((value) async {
              if (value.snapshot.hasChild(room.boards.first.bid)) {
                //print(room.boards.first.bid);
                await dbRef
                    .child('boards')
                    .child(room.boards.first.bid)
                    .once()
                    .then((value) {
                  DataSnapshot values = value.snapshot;
                  List _devices = [];
                  for (int i = 1; i <= 5; i++) {
                    if (values.hasChild(i.toString())) {
                      // print(values.child('$i').value);
                      _devices.add(values.child('$i').value);
                      var d = _devices[i - 1];
                      print(DateTime.now().day);
                      // print(d);

                      Device devicedetails = Device(
                        index: i,
                        bid: room.boards.first.bid,
                        consumption: double.parse(d['consumption'].toString()),
                        did: d['did'].toString(),
                        name: d['name'].toString(),
                        type: getDeviceType(d['type']),
                        status: d['status'],
                      );
                      userdetails.homes[index].totalconsumption +=
                          devicedetails.getConsumption();
                      // print(devicedetails.consumption);
                      room.boards.first.devices.add(devicedetails);
                      if (devicedetails.status)
                        userdetails.homes[index].activeDevices
                            .add(devicedetails);
                    }
                  }
                });
              }
            });
          }
          double sumofallotherdays = 0;
          for (int i = 0; i < 7; i++) {
            if (DateTime.now().weekday % 7 != i)
              sumofallotherdays +=
                  userdetails.homes[index].consumptionHistory[i];
          }

          userdetails.homes[index]
                  .consumptionHistory[(DateTime.now().weekday % 7)] =
              userdetails.homes[index].totalconsumption - sumofallotherdays;

          //print(userdetails.homes[0].consumptionHistory[DateTime.now().weekday % 7]);

          //print(userdetails.homes[index].rooms.first.boards.first.devices);
        });
      } else
        print('exist');
      // print(values);
    });
  }
  //search for homeId in Homes collection and get the details
}

Future getConsumption() async {
  if (userdetails.homes.length != 0) {
    double previouscon = userdetails.homes[homeIndex].totalconsumption;
    final dbRef = await FirebaseDatabase.instance.ref();
    for (Room room in userdetails.homes[homeIndex].rooms) {
      await dbRef.child('boards').once().then((value) async {
        if (value.snapshot.hasChild(room.boards.first.bid)) {
          //print(room.boards.first.bid);
         
          await dbRef
              .child('boards')
              .child(room.boards.first.bid)
              .once()
              .then((value) {
            DataSnapshot values = value.snapshot;
            List devices = [];
            userdetails.homes[homeIndex].totalconsumption = 0.0;
            for (int i = 1; values.hasChild(i.toString()); i++) {
              // print(values.child('$i').value);
              devices.add(values.child('$i').value);

              //  print(DateTime.now().day);
              // print(d);
            }
            userdetails.homes[homeIndex].rooms.forEach((element) {
              element.boards.first.devices.forEach((device) {
                for (int i = 0; i < devices.length; i++) {
                  if (device.did == devices[i]['did']) {
                    device.status = devices[i]['status'];
                    if (device.status)
                      userdetails.homes[homeIndex].activeDevices.add(device);
                    else
                      userdetails.homes[homeIndex].activeDevices.remove(device);
                    device.consumption =
                        double.parse(devices[i]['consumption'].toString());
                     print(devices[i].name + devices[i]['consumption']);
                  }
                }
                userdetails.homes[homeIndex].totalconsumption +=
                    device.getConsumption();
                // double sumofotherdays
              });
            });
          });
        }
      });
    }
    userdetails
            .homes[homeIndex].consumptionHistory[DateTime.now().weekday % 7] +=
        userdetails.homes[homeIndex].totalconsumption - previouscon;
    //print(userdetails.homes[homeIndex].consumptionHistory);
    dbRef
        .child('homes')
        .child(userdetails.homes[homeIndex].hid)
        .child('consumptionhistory')
        .set(userdetails.homes[homeIndex].consumptionHistory);
    // print(DateTime.now().weekday%7 );
  }
}

//fn to set device details inside the board
Future addDevice(Board board, index, Device device) async {
  final dbRef = await FirebaseDatabase.instance.ref();
  List devices = [];
  board.devices.forEach((element) async {
    dbRef.child('boards').child(board.bid).child(index).set({
      'name': element.name,
      'type': element.type.toString(),
      'did': element.did,
      'consumption': element.consumption,
      'status': element.status,
    });
  });
}

Future changeStatus(Device device) async {
  final dbRef = await FirebaseDatabase.instance.ref();
  dbRef
      .child('boards')
      .child(device.bid)
      .child(device.index.toString())
      .child('status')
      .set(device.status);
}

Future changeConsumption(Device device) async {
  final dbRef = await FirebaseDatabase.instance.ref();
  dbRef
      .child('boards')
      .child(device.bid)
      .child(device.index.toString())
      .child('consumption')
      .set(device.consumption);
}
//fn to run a timer on background even when the app is closed

// Future getDevices(Room room) async {
//   List _devices = [];
//   room.boards.first.devices = [];
//   final dbRef = await FirebaseDatabase.instance.ref();
//   await dbRef.child('boards').once().then((value) async {
//     if (value.snapshot.hasChild(room.boards.first.bid)) {
//       //print(room.boards.first.bid);
//       await dbRef
//           .child('boards')
//           .child(room.boards.first.bid)
//           .once()
//           .then((value) {
//         DataSnapshot values = value.snapshot;

//         for (int i = 1; i <= 5; i++) {
//           if (values.hasChild(i.toString())) {
//             // print(values.child('$i').value);
//             _devices.add(values.child('$i').value);
//             var d = _devices[i - 1];
//             print(d);
//             // print(d);

//             Device devicedetails = Device(
//               index: i,
//               bid: room.boards.first.bid,
//               consumption: double.parse(d['consumption'].toString()),
//               did: d['did'].toString(),
//               name: d['name'].toString(),
//               type: getDeviceType(d['type']),
//               status: d['status'],
//             );
//             print('adding');

//             room.boards.first.devices.add(devicedetails);
//             if (devicedetails.status &&
//                 userdetails.homes[0].activeDevices.every((element) {
//                   print('${element.did} != ${devicedetails.did}');
//                   if (element.did == devicedetails.did)
//                     return false;
//                   else
//                     return true;
//                 })) {
//               print(devicedetails.name);
//               userdetails.homes[0].activeDevices.add(devicedetails);
//             }
//           }
//         }
//       });
//     }
//   });
// }

//add a fn to listen for changes in the consumption of each devices in each board of the boards collection and update the consumption of the device in the device object
Future listenForConsumptionChanges() async {
  final dbRef = await FirebaseDatabase.instance.ref().child('boards');
  //dbRef.once().then((value) => print(value.snapshot.children.length.toString()));

  dbRef.onValue.listen((event) async {
    print('listened');
    await getConsumption();
    //await getStatus();
  });

  // var d = event.snapshot.value;
  // Device devicedetails = Device(
  //   index: int.parse(event.snapshot.key.toString()),
  //   bid: event.snapshot.ref.parent!.key.toString(),
  //   consumption: double.parse(d['consumption'].toString()),
  //   did: d['did'].toString(),
  //   name: d['name'].toString(),
  //   type: getDeviceType(d['type']),
  //   status: d['status'],
  // );
  // print(devicedetails.consumption);
  // print(devicedetails.name);
  // print(devicedetails.status);
  // print(devicedetails.bid);
  // print(devicedetails.index);
  // print(userdetails.homes[0].rooms.first.boards.first.devices);
  // userdetails.homes[0].rooms.first.boards.first.devices
  //     .forEach((element) async {
  //   if (element.did == devicedetails.did) {
  //     element.consumption = devicedetails.consumption;
  //     element.status = devicedetails.status;
  //     if (element.status &&
  //         userdetails.homes[0].activeDevices.every((element) {
  //           print('${element.did} != ${devicedetails.did}');
  //           if (element.did == devicedetails.did)
  //             return false;
  //           else
  //             return true;
  //         })) {
  //       print(devicedetails.name);
  //       userdetails.homes[0].activeDevices.add(devicedetails);
  //     }
  //   }
  // });
  // print(userdetails.homes[0].rooms.first.boards.first.devices);
}
