import 'dart:math';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:powervortex/global.dart';

//fn to find the room from the device id
Room getRoomFromDeviceID(String did) {
  for (var room in userdetails.homes[homeIndex].rooms) {
    for (var board in room.boards) {
      for (var device in board.devices) {
        if (device.did == did) {
          return room;
        }
      }
    }
  }
  return userdetails.homes[homeIndex].rooms[0];
}

String generateID(int length) {
  final random = Random();
  const chars =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';

  String randomString = '';
  for (int i = 0; i < length; i++) {
    randomString += chars[random.nextInt(chars.length)];
  }

  return randomString;
}

enum DeviceType { fan, light, tv, ac, fridge, washingMachine, other }

enum RoomType { bedroom, livingroom, kitchen, bathroom, other }

DeviceType getDeviceType(type) {
  switch (type) {
    case 'DeviceType.fan':
      return DeviceType.fan;
    case 'DeviceType.light':
      return DeviceType.light;
    case 'DeviceType.tv':
      return DeviceType.tv;
    case 'DeviceType.ac':
      return DeviceType.ac;
    case 'DeviceType.fridge':
      return DeviceType.fridge;
    case 'DeviceType.washingMachine':
      return DeviceType.washingMachine;
    case 'DeviceType.other':
      return DeviceType.other;
  }
  return DeviceType.other;
}

class Device {
  String did;
  String name;
  DeviceType type;
  bool status;
  double consumption;
  int index;
  String bid;
  Device(
      {required this.did,
      required this.name,
      required this.type,
      required this.status,
      required this.consumption,
      required this.index,
      required this.bid});
  double getConsumption() {
    return consumption;
  }
}

class Board {
  String bid;
  List<Device> devices;
  Board({required this.bid, required this.devices});
  void addDevice(Device device) {
    devices.add(device);
  }
}

class Room {
  String rid;
  String name;
  AssetImage lightimage;
  AssetImage darkimage;
  List<Board> boards;
  RoomType type;

  Room(
      {required this.rid,
      required this.boards,
      required this.type,
      this.lightimage = const AssetImage('assets/room1.png'),
      this.darkimage = const AssetImage('assets/room1_dark .png'),
      required this.name}) {}
  double getRoomConsumption() {
    double consumption = 0;
    for (var board in boards) {
      for (var device in board.devices) {
        consumption += device.getConsumption();
      }
    }
    return consumption;
  }

  void addBoard(Board board) {
    boards.add(board);
  }
}

class HomeDetails {
  String hid;
  String name;
  double totalconsumption = 0;
  List<Room> rooms;
  List<UserDetails> users;
  List consumptionHistory = [0, 0, 0, 0, 0, 0, 0];
  List<Device> activeDevices = [];
  HomeDetails(
      {required this.name,
      required this.hid,
      required this.rooms,
      required this.users});
  double getTotalConsumption() {
    double consumption = 0;
    for (var room in rooms) {
      consumption += room.getRoomConsumption();
    }
    return consumption;
  }

  void addRoom(Room room) {
    rooms.add(room);
  }

  void addUser(UserDetails user) {
    users.add(user);
  }

  double getCost() {
    double units = getTotalConsumption()*4 / 1000;
    print('units: $units');
    double charge = 0.0;
    int fixedCharge = 20; // Assuming single-phase connection

    if (units <= 250) {
      // Telescopic Billing
      if (units > 200) charge += (units - 200) * 7.00;
      if (units > 150) charge += (min(units, 200) - 150) * 5.80;
      if (units > 100) charge += (min(units, 150) - 100) * 4.20;
      if (units > 50) charge += (min(units, 100) - 50) * 3.20;
      charge += min(units, 50) * 2.80;
    } else {
      // Non-Telescopic Billing
      if (units > 500)
        charge = units * 7.50;
      else if (units > 400)
        charge = units * 6.70;
      else if (units > 350)
        charge = units * 6.10;
      else if (units > 300)
        charge = units * 5.70;
      else
        charge = units * 5.00;
    }

    return charge + fixedCharge;
  }
}

class UserDetails {
  String uid;
  String name;
  String email;
  // String phone;
  // DateTime dob;
  List<HomeDetails> homes = [];
  UserDetails({
    required this.uid,
    required this.name,
    required this.email,
    // required this.phone,
    // required this.dob,
  });

  void addHome(HomeDetails home) {
    homes.add(home);
  }

  //implement a sign in method here using firebase auth email and password
  void signIn(String email, String password) async {
    FirebaseAuth auth = FirebaseAuth.instance;

    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // User registration successful
    } catch (e) {
      // Handle registration error
    }
  }
}
