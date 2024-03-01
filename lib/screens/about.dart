import 'package:flutter/material.dart';
import 'package:powervortex/global.dart';

class About extends StatefulWidget {
  const About({super.key});

  @override
  State<About> createState() => _AboutState();
}

class _AboutState extends State<About> {
  //fn to show bottom sheet
 
  @override
  void initState() {
    
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
appBar: AppBar( 
    backgroundColor: uic.primarySwatch,
        elevation: 0,
    leading: IconButton(
      icon: Icon(Icons.arrow_back, color: uic.yellow),
      onPressed: () {
        Navigator.pop(context);
      },
    
    ),
        title: Text(
          'About us',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: uic.yellow, // Updated font color here
          ),
        ),
      ),
      body: Container(
        
        height: MediaQuery.of(context).size.height,
        color: uic.primarySwatch, // Updated background color here
        padding: EdgeInsets.only(left: 20, top: 32,right: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
           
            SizedBox(height: 20),
            Text(
              'Meet the creators',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: uic.textcolor // Updated font color here
              ),
            ),
            SizedBox(height: 20),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ProfileWidget(
                  imagePath: 'assets/profile1.jpg',
                  name: 'Adithya Anil',
                  email: 'unidreamerzz@gmail.com',
                ),
                SizedBox(width: 30),
                ProfileWidget(
                  imagePath: 'assets/profile2.jpg',
                  name: 'Ashwin A',
                  email: 'ashwin022001@gmail.com',
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ProfileWidget(
                  imagePath: 'assets/profile3.jpg',
                  name: 'Gopal S',
                  email: 'gopalshibu142@gmail.com',
                ),
                SizedBox(width: 30),
                ProfileWidget(
                  imagePath: 'assets/profile4.jpg',
                  name: 'Shibin Shibu',
                  email: 'shibinsb01@gmail.com',
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              'Guided by',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: uic.textcolor, // Updated font color here
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ProfileWidget(
                  imagePath: 'assets/profile5.jpg',
                  name: 'Ms Deepthi K Moorthy',
                  email: 'Assistant professor, Dept. of CSE',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileWidget extends StatelessWidget {
  final String imagePath;
  final String name;
  final String email;
  final double circleSize;

  const ProfileWidget({
    required this.imagePath,
    required this.name,
    required this.email,
    this.circleSize = 150,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: circleSize,
          height: circleSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color:uic.yellow, // Dark yellow border color
              width: 3,
            ),
            image: DecorationImage(
              image: AssetImage(imagePath),
              fit: BoxFit.cover,
            ),
          ),
        ),
        SizedBox(height: 8),
        Text(
          name,
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: uic.textcolor, // Updated font color here
          ),
        ),
        SizedBox(height: 5),
        Text(
          email,
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: uic.textcolor, // Updated font color here
          ),
        ),
      ],
    );
  }
}