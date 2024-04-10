import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:powervortex/database/collections.dart';
import 'package:powervortex/global.dart';
import 'package:powervortex/obj/objects.dart';
import 'screens/splash.dart';
import 'screens/home.dart';
import 'obj/ui.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:google_nav_bar/google_nav_bar.dart';
import 'screens/dashboard.dart';
import 'screens/schedule.dart';
import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/login.dart';
import 'screens/profile.dart';
import 'screens/about.dart';
import '../database/auth.dart';
import './api/gemini.dart';
import './api/apikey.dart';

import 'package:flutter_gemini/flutter_gemini.dart';

void main() async {
  Gemini.init(apiKey: API_KEY);
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(Vortex());
}

class Vortex extends StatelessWidget {
  Vortex({super.key});
  UIComponents ui = UIComponents();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Power Vortex',
      routes: {
        '/': (context) => Splash(ui: ui),
        //'/second': (context) => const SecondPage(title: 'Second Page'),
        '/home': (context) => Body(),
        '/login': (context) => Login(ui: ui),
      },
      theme: ThemeData(
          // primarySwatch: ui.primarySwatch,
          // brightness: ui.brightness,
          // backgroundColor: ui.background,
          // scaffoldBackgroundColor: ui.background,
          // colorScheme: ColorScheme(
          //   secondary: ui.theme.primarySwatch,
          //   onSecondary: ui.theme.primarySwatch,
          //   onPrimary: ui.theme.primarySwatch,
          //   primary: ui.theme.primarySwatch,
          //   background: ui.theme.background,
          // brightness: ui.theme.brightness,
          // error: Colors.yellow,
          // onBackground: ui.theme.background,
          // onError: Colors.yellow,
          // onSurface: ui.theme.background,
          // surface:
          // ),
          ),
      initialRoute: '/',
      //home: const MyHomePage(title: 'Vortex'),
    );
  }
}

class Body extends StatefulWidget {
  Body({super.key});

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  GlobalKey<SliderDrawerState> _key = GlobalKey<SliderDrawerState>();

  PageController _pageController = PageController();
  int _pageIndex = 0;
  stt.SpeechToText _speechToText = stt.SpeechToText();
  bool _speechEnabled = false;
  bool _isListening = false;
  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize(
        onStatus: (value) => print(value), onError: (value) => print(value));
    print('done');
  }

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: uic.background,
        // appBar: AppBar(
        //   backgroundColor: ui.primarySwatch,
        //   leading: IconButton(
        //     icon: Icon(
        //       ui.isDark ? Icons.wb_sunny : Icons.nightlight_round,
        //       color: ui.textcolor,
        //     ),
        //     onPressed: () => setState(() {
        //       ui.changeTheme();
        //     }),
        //   ),
        // ),
        body: SafeArea(
          child: SliderDrawer(
            key: _key,
            slideDirection: SlideDirection.RIGHT_TO_LEFT,
            appBar: SliderAppBar(
                trailing: Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: Image(image: AssetImage('assets/logotext.png')),
                ),
                drawerIconColor: uic.textcolor,
                appBarColor: uic.background,
                title: Text('')),
            slider: Container(
              padding: EdgeInsets.only(top: 20),
              alignment: Alignment.center,
              color: uic.primarySwatch,
              child: ListView(
                children: [
                  CircleAvatar(
                    radius: 80,
                    backgroundColor: uic.yellow,
                    child: CircleAvatar(
                      radius: 75,
                      backgroundImage: currentuser!.photoURL == null
                          ? AssetImage('assets/logotransparent.png')
                          : image.image,
                    ),
                  ),
                  //slideOption('Settings', Icons.settings, () {}),
                  SizedBox(
                    height: 20,
                  ),
                  slideOption('About', Icons.info, () {
                    Navigator.push(context,
                            MaterialPageRoute(builder: (context) => About()))
                        .then((value) {
                      setState(() {});
                    });
                  }),
                  slideOption('Profile', Icons.person, () {
                    Navigator.push(context,
                            MaterialPageRoute(builder: (context) => Profile()))
                        .then((value) {
                      setState(() {});
                    });
                  }),
                  const SizedBox(
                    height: 20,
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.brightness_3,
                      color: uic.textcolor,
                    ),
                    title: Text(
                      'Dark Mode',
                      style: TextStyle(
                        color: uic.textcolor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    trailing: Switch(
                      // inactiveThumbColor: ui.textcolor,
                      // activeThumbImage: AssetImage('assets/moon.png'),
                      // activeColor: ui.textcolor,
                      // inactiveThumbImage: AssetImage('assets/sun.png'),
                      activeColor: uic.textcolor,
                      value: uic.isDark,
                      onChanged: (value) => setState(() {
                        uic.changeTheme();
                      }),
                    ),
                  ),
                  ListTile(
                    onTap: () async {
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
                                      await signOut().then((value) {
                                        if (value == 'success') {
                                          Navigator.pushReplacementNamed(
                                              context, '/login');
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(value),
                                              duration: Duration(seconds: 3),
                                            ),
                                          );
                                        }
                                      });
                                    },
                                    child: Text(
                                      'Log Out',
                                      style: TextStyle(color: Colors.red),
                                    ))
                              ],
                            );
                          });
                    },
                    leading: Icon(
                      Icons.logout,
                      color: uic.yellow,
                    ),
                    title: Text(
                      'Logout',
                      style: TextStyle(
                        color: uic.textcolor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                ],
              ),
            ),
            child: Container(
              height: double.infinity,
              width: double.infinity,
              color: uic.background,
              child: PageView(
                physics: NeverScrollableScrollPhysics(),
                controller: _pageController,
                children: [
                  Home(ui: uic),
                  Schedule(ui: uic),
                  DashBoard(ui: uic),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: Container(
          height: 250,
          width: 250,
          alignment: Alignment.bottomRight,
          padding: EdgeInsets.only(left: 40, bottom: 20),
          child: FittedBox(
            child: FloatingActionButton(
              tooltip: "Voice Command",
              backgroundColor: uic.background,
              //foregroundColor: uic.background,
              //set radius to 50

              shape: RoundedRectangleBorder(
                  side: BorderSide(color: uic.yellow, width: 0.2),
                  borderRadius: BorderRadius.circular(10)),

              onPressed: () async {
                String words = '';
                // Navigator.pushNamed(context, '/home');
                await HapticFeedback.vibrate();
                if (_speechEnabled) {
                  try {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            backgroundColor: uic.primarySwatch,
                            title: Text(
                              'Listening...',
                              style: TextStyle(color: uic.textcolor),
                            ),
                            content: Text(
                              words,
                              style: TextStyle(color: uic.textcolor),
                            ),
                            actions: [
                              TextButton(
                                  onPressed: () async {
                                    await _speechToText.stop();
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    'Stop',
                                    style: TextStyle(color: uic.yellow),
                                  ))
                            ],
                          );
                        });
                    //testGemini();
                    _speechToText
                        .listen(
                          onResult: (value) async {
                            words = value.recognizedWords;
                            setState(() {});
                            print(words);

                            final gemini = Gemini.instance;
                            List<String> content = [];
                            gemini.streamGenerateContent('''Hi i need your help
            I will give you a sentence you have to break it down for me. Sentence will say about turning a device on or off from a bedroom.
            For example if the sentence is 
            Turn on light one from bedroom one you should reply with 
            on,light1,bedroom1
            As comma separated values nothing more or less each response should contain 3 such words that on/off,device,room
            
            The given sentence is 
            $words''').listen((value) async {
                              content = value.output!.split(',');
                              print(content);

                              Device device = getDeviceFromName(
                                  roomname: content[2].trim(),
                                  devicename: content[1].trim());
                              if (device.did == '0000') {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text('Device not found'),
                                        duration: Duration(seconds: 3)));
                                return;
                              }
                              device.status = content[0] == 'on' ? true : false;
                              changeStatus(device);
                              if (device.status&&userdetails.homes[homeIndex].activeDevices.where((element) => element.did==device.did).isEmpty) {
                                userdetails.homes[homeIndex].activeDevices.add(device);
                               // userdetails.homes[homeIndex].activeDevices.add(device);
                              }
                              Navigator.pop(context);
                              //show success snackbar
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: Text(
                                      'Device "${device.name}" of Room "${content[2]}" has turned ${device.status ? 'on' : 'off'}'),
                                  duration: Duration(seconds: 3)));
                                  setState(() {
                                    
                                  });
                            }).onError((e) {
                              print(e.toString());
                              Navigator.pop(context);
                              //show error snackbar
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: Text('Something went wrong please try again'),
                                  duration: Duration(seconds: 3)));
                            });
                          },

                          listenFor: Duration(seconds: 10),
                          pauseFor: Duration(seconds: 3),

                          cancelOnError: true,
                          partialResults: false,
                          //onDevice: true,
                          localeId: 'en_IN',
                        )
                        .then((value) => {
                              print(value),
                            });
                  } catch (e) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content:
                            Text(words == '' ? 'No input detected' : words),
                        duration: Duration(seconds: 3)));
                  }
                }
              },
              child: Icon(
                Icons.mic,
                size: 30,
                color: uic.yellow,
              ),
            ),
          ),
        ),
        bottomNavigationBar: GNav(
          gap: 5,
          tabMargin: EdgeInsets.symmetric(horizontal: 4, vertical: 10),
          tabActiveBorder: Border.all(color: uic.textcolor, width: 0.2),
          padding: EdgeInsets.all(10),
          tabBackgroundColor: uic.secondary,
          backgroundColor: uic.primarySwatch,
          color: uic.textcolor,
          activeColor: uic.background,
          onTabChange: (value) => setState(() {
            //print(currentuser!.email);

            _key.currentState!.closeSlider();
            _pageIndex = value;
            _pageController.animateToPage(value,
                duration: Duration(milliseconds: 300), curve: Curves.ease);
          }),
          tabs: [
            GButton(
              icon: Icons.home,
              text: 'Home',
            ),
            GButton(
              icon: Icons.timer,
              text: 'Schedule',
            ),
            GButton(
              icon: Icons.dashboard,
              text: 'Dashboard',
            ),
          ],
          selectedIndex: _pageIndex,
        ));
  }

  ListTile slideOption(String title, IconData icon, void Function() onTap) {
    return ListTile(
      onTap: () async {
        await HapticFeedback.vibrate();
        onTap();
        // _key.currentState!.closeSlider();
      },
      leading: Icon(
        icon,
        color: uic.textcolor,
      ),
      title: Text(title,
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w700, color: uic.textcolor)),
      // onTap: () => setState(() {
      //   _pageIndex = index;
      //   _pageController.animateToPage(index,
      //       duration: Duration(milliseconds: 300),
      //       curve: Curves.ease);

      // }),
    );
  }
}
