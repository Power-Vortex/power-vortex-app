import 'package:flutter/material.dart';
import 'package:powervortex/database/collections.dart';
import '../obj/ui.dart';
import '../database/auth.dart';
import '../global.dart';

class Login extends StatefulWidget {
  final UIComponents ui;
  const Login({super.key, required this.ui});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> with TickerProviderStateMixin {
  TextEditingController emailsignup = TextEditingController();
  TextEditingController passwordsignup = TextEditingController();
  TextEditingController name = TextEditingController();
  TextEditingController useremail = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController confirmpassword = TextEditingController();
  bool _obscureText = true;
  bool _obscureText2 = true;

  void startSignIn() async {
    showDialog(
      context: context,
      barrierDismissible:
          false, // Prevent dismissing the popup by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: uic.primarySwatch,
          title: Text('Loading',
              style: TextStyle(
                color: uic.textcolor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              )),
          content: Row(
            children: [
              CircularProgressIndicator(
                color: uic.textcolor,
              ), // Loading indicator
              SizedBox(width: 16.0),
              Text('Please wait...',
                  style: TextStyle(
                    color: uic.textcolor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  )),
            ],
          ),
        );
      },
    );
    if (useremail.text.isEmpty || password.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please fill all fields'),
        duration: Duration(seconds: 2),
      ));
      Navigator.of(context).pop();
      return;
    }
    await signIn(useremail.text.trim(), password.text.trim()).then((value) {
      if (value == 'success') {
        Future.delayed(Duration(seconds: 3)).then((value) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Sign in successful'),
            duration: Duration(seconds: 2),
          ));
          Navigator.of(context).pop();
          Navigator.of(context).pushReplacementNamed('/home');
        });
      } else if (value.toString() == 'null') {
        print(value);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('user not found'),
          duration: Duration(seconds: 2),
        ));
        Navigator.of(context).pop();
      } else if (value.toString() == 'Email not verified') {
        print(value);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          animation: AnimationController(vsync: this),
          content: Text('please verify your email'),
          action: SnackBarAction(label: 'send verification', onPressed: sentVerification),
          duration: Duration(seconds: 5),
        ));
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(value.toString()),
          duration: Duration(seconds: 2),
        ));
        Navigator.of(context).pop();
      }
    });
  }

  void startSignUp() async {
    showDialog(
      context: context,
      barrierDismissible:
          false, // Prevent dismissing the popup by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: uic.primarySwatch,
          title: Text('Loading',
              style: TextStyle(
                color: uic.textcolor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              )),
          content: Row(
            children: [
              CircularProgressIndicator(
                color: uic.textcolor,
              ), // Loading indicator
              SizedBox(width: 16.0),
              Text('Please wait...',
                  style: TextStyle(
                    color: uic.textcolor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  )),
            ],
          ),
        );
      },
    );
    if (name.text.isEmpty ||
        emailsignup.text.isEmpty ||
        passwordsignup.text.isEmpty ||
        confirmpassword.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please fill all fields'),
        duration: Duration(seconds: 2),
      ));
      Navigator.of(context).pop();
      return;
    }

    if (passwordsignup.text != confirmpassword.text) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Passwords do not match'),
        duration: Duration(seconds: 2),
      ));
      Navigator.of(context).pop();
      return;
    }

    await signUp(emailsignup.text.trim(), passwordsignup.text.trim(),
            name.text.trim())
        .then((value) {
      // value.toString().contains('null');
      if (value == 'success') {
        Future.delayed(Duration(seconds: 1)).then((value) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Verification Email has been sent to your email'),
            duration: Duration(seconds: 2),
          ));
          emailsignup.clear();
          passwordsignup.clear();
          name.clear();
          confirmpassword.clear();
          Navigator.of(context).pop();
          Navigator.of(context).pop();
          _showSignIn();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(value.toString()),
          duration: Duration(seconds: 2),
        ));
        Navigator.of(context).pop();
      }
    });
  }

  void forgetPass() async {
    if (useremail.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please enter email'),
        duration: Duration(seconds: 2),
      ));
      return;
    }
    //show snack bar
    //send email using forget password function
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Email sent'),
      duration: Duration(seconds: 2),
    ));
    await forgetPassword(useremail.text).then((value) {
      if (value == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Email sent'),
          duration: Duration(seconds: 2),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(value.toString()),
          duration: Duration(seconds: 2),
        ));
      }
    });
  }

  void _showSignUp() {
    Future.delayed(Duration(milliseconds: 100), () {
      showModalBottomSheet(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20))),
          enableDrag: false,
          isScrollControlled: false,
          anchorPoint: Offset(1, 0),
          elevation: 5,
          backgroundColor: Colors.transparent,
          transitionAnimationController: AnimationController(
              vsync: this, duration: Duration(milliseconds: 1000)),
          isDismissible: false,
          //showDragHandle: true,
          context: context,
          builder: (ctx) => signUpSheet());
    });
  }

  //final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  void _showSignIn() {
    Future.delayed(Duration(milliseconds: 100), () {
      showModalBottomSheet(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20))),
          enableDrag: false,
          isScrollControlled: false,
          anchorPoint: Offset(1, 0),
          elevation: 5,
          backgroundColor: Colors.transparent,
          transitionAnimationController: AnimationController(
              vsync: this, duration: Duration(milliseconds: 1000)),
          isDismissible: false,
          //showDragHandle: true,
          context: context,
          builder: (ctx) => signInSheeet());
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _showSignIn();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Color(0xffE1BA48),
        body: Container(
          padding: EdgeInsets.only(top: 100),
          alignment: Alignment.topCenter,
          child: Container(
            height: 100,
            width: 300,
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/textlogoblackpng.png'),
                    fit: BoxFit.contain)),
          ),
        ));
  }

  WillPopScope signInSheeet() {
    return WillPopScope(
      onWillPop: () async => false,
      child: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
        return Container(
          height: 500,
          child: Scaffold(
            resizeToAvoidBottomInset: true,
            backgroundColor: Colors.transparent,
            body: Container(
              //alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: uic.primarySwatch,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20))),

              padding: EdgeInsets.all(50),
              child: ListView(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        style: TextStyle(
                            fontSize: 35,
                            fontWeight: FontWeight.bold,
                            color: uic.textcolor),
                        'Sign in',
                        textAlign: TextAlign.center,
                      ),
                      IconButton(
                          onPressed: () {
                            setState(() {
                              uic.changeTheme();
                            });
                          },
                          icon: Icon(
                            uic.isDark
                                ? Icons.wb_sunny
                                : Icons.nightlight_round,
                            color: uic.textcolor,
                          ))
                    ],
                  ),
                  Row(
                    children: [
                      Text('New User? ',
                          style: TextStyle(fontSize: 14, color: uic.textcolor)),
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _showSignUp();
                          },
                          child: Text(
                            'Create an account',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xffE1BA48)),
                          ))
                    ],
                  ),
                  TextField(
                      cursorColor: Color(0xffE1BA48),
                      style: TextStyle(
                        color: uic.textcolor,
                      ),
                      controller: useremail,
                      decoration: InputDecoration(
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: uic.textcolor,
                          ),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(0xffE1BA48),
                          ),
                        ),
                        hintText: 'Email address ',
                        hintStyle: TextStyle(color: uic.textcolor),
                      )),
                  SizedBox(
                    height: 20,
                  ),
                  TextField(
                      obscureText: _obscureText,
                      cursorColor: Color(0xffE1BA48),
                      style: TextStyle(
                        color: uic.textcolor,
                      ),
                      controller: password,
                      decoration: InputDecoration(
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: uic.textcolor,
                            ),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xffE1BA48),
                            ),
                          ),
                          hintText: 'password ',
                          hintStyle: TextStyle(color: uic.textcolor),
                          suffix: IconButton(
                            onPressed: () {
                              setState(() {
                                _obscureText = !_obscureText;
                              });
                            },
                            icon: _obscureText
                                ? Icon(Icons.visibility_off)
                                : Icon(Icons.visibility),
                          ))),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                          onPressed: () {
                            forgetPassword(useremail.text);
                            //show snackbar please check ur email
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text('please check your email')));
                          },
                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xffE1BA48)),
                          )),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xffE1BA48),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                          ),
                          onPressed: () {
                            startSignIn();
                          },
                          child: Text(
                            'Continue',
                            style: TextStyle(color: uic.textcolor),
                          ))
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  WillPopScope signUpSheet() {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        _showSignIn();
        return false;
      },
      child: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
        return Container(
          height: 700,
          child: Scaffold(
            resizeToAvoidBottomInset: true,
            backgroundColor: Colors.transparent,
            body: Container(
              //alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: uic.primarySwatch,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20))),

              padding: EdgeInsets.all(50),
              child: ListView(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        style: TextStyle(
                            fontSize: 35,
                            fontWeight: FontWeight.bold,
                            color: uic.textcolor),
                        'Sign up',
                        textAlign: TextAlign.center,
                      ),
                      IconButton(
                          onPressed: () {
                            setState(() {
                              uic.changeTheme();
                            });
                          },
                          icon: Icon(
                            uic.isDark
                                ? Icons.wb_sunny
                                : Icons.nightlight_round,
                            color: uic.textcolor,
                          ))
                    ],
                  ),
                  Row(
                    children: [
                      Text('Existing user? ',
                          style: TextStyle(fontSize: 14, color: uic.textcolor)),
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _showSignIn();
                          },
                          child: Text(
                            'Sign in to your account',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xffE1BA48)),
                          ))
                    ],
                  ),
                  TextField(
                      cursorColor: Color(0xffE1BA48),
                      style: TextStyle(
                        color: uic.textcolor,
                      ),
                      controller: name,
                      decoration: InputDecoration(
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: uic.textcolor,
                          ),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(0xffE1BA48),
                          ),
                        ),
                        hintText: 'Name ',
                        hintStyle: TextStyle(color: uic.textcolor),
                      )),
                  SizedBox(
                    height: 20,
                  ),
                  TextField(
                      cursorColor: Color(0xffE1BA48),
                      style: TextStyle(
                        color: uic.textcolor,
                      ),
                      controller: emailsignup,
                      decoration: InputDecoration(
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: uic.textcolor,
                          ),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(0xffE1BA48),
                          ),
                        ),
                        hintText: 'Email address ',
                        hintStyle: TextStyle(color: uic.textcolor),
                      )),
                  TextField(
                      obscureText: _obscureText,
                      cursorColor: Color(0xffE1BA48),
                      style: TextStyle(
                        color: uic.textcolor,
                      ),
                      controller: passwordsignup,
                      decoration: InputDecoration(
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: uic.textcolor,
                            ),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xffE1BA48),
                            ),
                          ),
                          hintText: 'password ',
                          hintStyle: TextStyle(color: uic.textcolor),
                          suffix: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscureText = !_obscureText;
                                });
                              },
                              icon: Icon(
                                _obscureText
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Color(0xffE1BA48),
                              )))),
                  TextField(
                      obscureText: _obscureText2,
                      cursorColor: Color(0xffE1BA48),
                      style: TextStyle(
                        color: uic.textcolor,
                      ),
                      controller: confirmpassword,
                      decoration: InputDecoration(
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: uic.textcolor,
                            ),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xffE1BA48),
                            ),
                          ),
                          hintText: 'confirm password ',
                          hintStyle: TextStyle(color: uic.textcolor),
                          suffix: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscureText2 = !_obscureText2;
                                });
                              },
                              icon: Icon(
                                _obscureText2
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Color(0xffE1BA48),
                              )))),
                  SizedBox(
                    height: 20,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xffE1BA48),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                        ),
                        onPressed: () {
                          startSignUp();
                        },
                        child: Text(
                          'Continue',
                          style: TextStyle(color: uic.textcolor),
                        )),
                  )
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
