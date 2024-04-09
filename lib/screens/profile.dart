import 'package:flutter/material.dart';
import 'package:powervortex/obj/objects.dart';
import '../global.dart';
import '../database/auth.dart';
import '../database/collections.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  List<Room> rooms = [];
  List<Board> boards = [];
  XFile? pickedImage;

  Future<void> _pickImage() async {
    final pickedImageVal =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    setState(() {
      pickedImage = pickedImageVal;
      image = Image.file(
        File(pickedImage!.path),
        fit: BoxFit.cover,
        height: 150,
        width: 150,
      );
    });
    updateProfilePic(pickedImage!.path).then((value) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile Picture Updated'),
          duration: Duration(seconds: 1),
        ),
      );
    });
  }

  TextEditingController _buildingname = TextEditingController();
  TextEditingController _roomname = TextEditingController();
  TextEditingController _boardid = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          leading: IconButton(
            onPressed: () async {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back,
              color: uic.yellow,
            ),
          ),
          elevation: 0,
          title: Text(
            'Profile',
            style: TextStyle(
                color: uic.yellow, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          backgroundColor: uic.primarySwatch,
          actions: [
            //changetheme
            IconButton(
              onPressed: () {
                setState(() {
                  uic.changeTheme();
                });
                getHomeDetails(homeIndex);
              },
              icon: Icon(
                  uic.isDark
                      ? Icons.brightness_5_outlined
                      : Icons.brightness_4_outlined,
                  color: uic.textcolor),
            )
          ],
        ),
        backgroundColor: uic.primarySwatch,
        body: ListView(
          children: [
            SizedBox(
              height: 20,
            ),
            Center(
              child: GestureDetector(
                onTap: () async {
                  await _pickImage();
                },
                child: CircleAvatar(
                    backgroundColor: uic.yellow,
                    minRadius: 75,
                    maxRadius: 80,
                    child: CircleAvatar(
                      radius: 75,
                      backgroundColor: uic.background,
                      child: ClipOval(
                          child: currentuser!.photoURL != null || image != null
                              ? image
                              : Icon(
                                  Icons.person,
                                  size: 140,
                                )),
                    )),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Align(
              alignment: Alignment.center,
              child: Text(
                currentuser!.displayName!,
                style: TextStyle(
                    color: uic.textcolor,
                    fontSize: 32,
                    fontWeight: FontWeight.bold),
              ),
            ),
            //SizedBox(height: 20,),
            Align(
              child: Text(
                currentuser!.email!,
                style: TextStyle(
                    color: uic.textcolor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 20,
            ),

            Align(
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: uic.yellow,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20))),
                  onPressed: () async {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            backgroundColor: uic.primarySwatch,
                            title: Text('Alert! you are about to logout',
                                style: TextStyle(color: uic.textcolor)),
                            content: Text('Are you sure you want to log out?',
                                style: TextStyle(color: uic.textcolor)),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    'Cancel',
                                    style: TextStyle(color: uic.yellow),
                                  )),
                              TextButton(
                                  onPressed: () async {
                                    Navigator.pop(context);
                                    signOutfn();
                                  },
                                  child: Text(
                                    'Log Out',
                                    style: TextStyle(color: Colors.red),
                                  ))
                            ],
                          );
                        });

                    //Navigator.pushNamed(context, '/login');
                  },
                  child: Text(
                    'Log Out',
                    style: TextStyle(color: uic.background, fontSize: 18),
                  )),
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.only(left: 20),
              alignment: Alignment.centerLeft,
              child: Text('My Buildings',
                  style: TextStyle(
                      color: uic.textcolor,
                      fontSize: 22,
                      fontWeight: FontWeight.bold)),
            ),
            SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                  shrinkWrap: true,
                  
                  itemCount: userdetails.homes.length + 1,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: .95,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 20,
                      mainAxisExtent: 150

                      
                      ),
                  scrollDirection: Axis.vertical,
                  itemBuilder: (BuildContext context, int index) {
                    return index == userdetails.homes.length
                        ? GestureDetector(
                            child: Container(
                              height: 100,
                              decoration: BoxDecoration(
                                  color: uic.background,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 10,
                                        spreadRadius: 2)
                                  ],),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add,
                                    color: uic.yellow,
                                    size: 50,
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    'Add Building',
                                    style: TextStyle(
                                        color: uic.textcolor,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  )
                                ],
                              ),
                            ),
                            onTap: () async {
                              // textdb();
                              //show modelbottomsheet
                              showModalBottomSheet(
                                  backgroundColor: uic.isDark
                                      ? uic.yellow
                                      : uic.primarySwatch,
                                  shape: BeveledRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(20),
                                          topRight: Radius.circular(20))),
                                  context: context,
                                  builder: (context) {
                                    return addBuildingSheet(context);
                                  }).then((value) {
                                setState(() {});
                              });
                            },
                          )
                        : GestureDetector(
                            onTap: () async{
                              homeIndex = index;
                              await getHomeDetails(homeIndex);
                              setState(() {
                              });
                            },
                            child: Container(
                              height: 100,
                              decoration: BoxDecoration(
                                  color: uic.background,
                                  borderRadius: BorderRadius.circular(20)),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: EdgeInsets.only(
                                        left: 10, top: 8, right: 10),
                                    alignment: Alignment.topLeft,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          userdetails.homes[index].name,
                                          style: TextStyle(
                                              color: uic.textcolor,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        if (homeIndex == index)
                                          Icon(
                                            Icons.check,
                                            color: uic.yellow,
                                            size: 22,
                                          )
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Image.asset(
                                    uic.isDark
                                        ? 'assets/homeDark.png'
                                        : 'assets/homeLight.png',
                                    height: 100,
                                    width: 150,
                                    fit: BoxFit.cover,
                                  )
                                ],
                              ),
                            ),
                          );
                  }),
            )
          ],
        ));
  }

  StatefulBuilder addBuildingSheet(BuildContext context) {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return Container(
        height: 700,
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: Colors.transparent,
          body: Container(
            decoration: BoxDecoration(
              color: uic.isDark ? uic.yellow : uic.primarySwatch,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            ),
            height: 600,
            child: ListView(
              children: [
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Text(
                    'Setup Building',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 42,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: Text(
                    'Add/Edit buildings',
                    style: TextStyle(color: Colors.black, fontSize: 18),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(20),
                  child: TextFormField(
                    controller: _buildingname,
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      labelText: 'Building Name',
                      labelStyle: TextStyle(color: Colors.black),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 2),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: TextFormField(
                    controller: _roomname,
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      hintText: 'Room Name',
                      labelText: 'Create Room',
                      labelStyle: TextStyle(color: Colors.black),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 2),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                  child: TextFormField(
                    controller: _boardid,
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      suffix: GestureDetector(
                          onTap: () {
                            setState(() {
                              boards
                                  .add(Board(bid: _boardid.text, devices: []));
                              rooms.add(Room(
                                  rid: generateID(10),
                                  boards: [
                                    Board(bid: _boardid.text, devices: [])
                                  ],
                                  type: RoomType.other,
                                  lightimage: AssetImage('assets/room1.png'),
                                  darkimage:
                                      AssetImage('assets/room1_dark.png'),
                                  name: _roomname.text));
                            });
                          },
                          child: Icon(
                            Icons.add_box,
                          )),
                      labelText: 'Board Id',
                      labelStyle: TextStyle(color: Colors.black),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 2),
                      ),
                    ),
                  ),
                ),

                Container(
                  padding: EdgeInsets.all(20),
                  width: MediaQuery.of(context).size.width,
                  height: 90,
                  child: rooms.isEmpty
                      ? Center(
                          child: Text(
                            'No Rooms Added',
                            style: TextStyle(color: Colors.black),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemCount: rooms.length,
                          itemBuilder: (context, index) {
                            return Row(
                              children: [
                                Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        color: Colors.transparent,
                                        border:
                                            Border.all(color: Colors.black)),
                                    padding: EdgeInsets.all(10),
                                    //color: Colors.red,
                                    height: 45,
                                    //width: 100,
                                    child: Row(
                                      children: [
                                        Center(
                                            child: Text(
                                          rooms[index].name,
                                          style: TextStyle(color: Colors.black),
                                        )),
                                        GestureDetector(
                                          child: Icon(
                                            Icons.close,
                                            color: Colors.black,
                                          ),
                                          onTap: () {
                                            setState(() {
                                              boards.removeAt(index);
                                              rooms.removeAt(index);
                                            });
                                          },
                                        )
                                      ],
                                    )),
                                SizedBox(
                                  width: 10,
                                )
                              ],
                            );
                          },
                        ),
                ),
                //ListView.builder(itemBuilder: item)
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      userdetails.homes.add(HomeDetails(
                          name: _buildingname.text,
                          rooms: rooms,
                          hid: generateID(10),
                          users: [userdetails]));
                      await updateUserHomes(HomeDetails(
                          name: _buildingname.text,
                          rooms: rooms,
                          hid: generateID(10),
                          users: [userdetails])).then((value) async {
                        await getHomeDetails(homeIndex);
                      });
                      setState(() {
                        _buildingname.text = '';
                        _roomname.text = '';
                        _boardid.text = '';
                        rooms = [];
                      });

                      Navigator.pop(context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Text(
                        'Confirm',
                        style: TextStyle(color: uic.textcolor, fontSize: 18),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: uic.background,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15))),
                  ),
                )
              ],
            ),
          ),
        ),
      );
    });
  }

  void signOutfn() async {
    await signOut().then((value) {
      if (value == 'success') {
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(value),
            duration: Duration(seconds: 3),
          ),
        );
      }
    });
  }
}
