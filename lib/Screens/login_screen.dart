import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:techmdemo/Common/SharedPreferenes.dart';
import 'package:techmdemo/Screens/home_screen.dart';
import 'package:techmdemo/Screens/signup_screen.dart';

import '../Common/comHelper.dart';
import '../Common/getTextFormField.dart';
import '../DatabaseHandler/dbHelper.dart';
import '../Model/usermodel.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => StartState();
}

class StartState extends State<LoginScreen> {


  @override
  Widget build(BuildContext context) {
    return initWidget();
  }

  final _formKey = new GlobalKey<FormState>();

  final _conEmail = TextEditingController();
  final _conPassword = TextEditingController();
  var dbHelper;

  @override
  void initState() {
    super.initState();
    dbHelper = DbHelper();
  }

  doLogin() async {
    String email = _conEmail.text;
    String passwd = _conPassword.text;

    if (_formKey.currentState!.validate()) {
      if (!validateEmail(email)) {
        alertDialog('Enter Valid Email',context);
      } else if (passwd.isEmpty) {
        alertDialog('Enter Password', context);
      } else {
        _formKey.currentState!.save();
        await dbHelper.getLoginUser(email, passwd).then((userData) {
          if (userData != null) {
            setSP(userData).whenComplete(() {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => HomeScreen()),
                  (Route<dynamic> route) => false);
            });
          } else {
            alertDialog("Error: User Not Found", context);
          }
        }).catchError((error) {
          print(error);
          alertDialog("Error: Login Fail", context);
        });
      }
    }
  }

  Future setSP(UserModel user) async {
    adduserIdSF(user.user_id!.toString());
    adduserNameSF(user.user_name!);
    adduserEmailSF(user.email!);
  }

  initWidget() {
    return Scaffold(
        body: Form(
            key: _formKey,
            child: SingleChildScrollView(
                child: Column(
              children: [
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.only(bottomLeft: Radius.circular(90)),
                    color: new Color(0xffF5591F),
                    gradient: LinearGradient(
                      colors: [(new Color(0xffF5591F)), new Color(0xffF2861E)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Center(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: 50),
                        child: Image.asset(
                          "assets/images/app_logo.png",
                          height: 90,
                          width: 90,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(right: 20, top: 20),
                        alignment: Alignment.bottomRight,
                        child: Text(
                          "Login",
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                      )
                    ],
                  )),
                ),
                getTextFormField(
                    controller: _conEmail,
                    icon: Icons.email,
                    inputType: TextInputType.emailAddress,
                    hintName: 'Email'),
                getTextFormField(
                    controller: _conPassword,
                    icon: Icons.key,
                    inputType: TextInputType.text,
                    isObscureText: true,
                    hintName: 'Password'),
                InkWell(
                  onTap: () {
                    doLogin();
                  },
                  child: Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(left: 20, right: 20, top: 70),
                    padding: EdgeInsets.only(left: 20, right: 20),
                    height: 54,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [
                            (new Color(0xffF5591F)),
                            new Color(0xffF2861E)
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight),
                      borderRadius: BorderRadius.circular(50),
                      color: Colors.grey[200],
                      boxShadow: [
                        BoxShadow(
                            offset: Offset(0, 10),
                            blurRadius: 50,
                            color: Color(0xffEEEEEE)),
                      ],
                    ),
                    child: Text(
                      "LOGIN",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Don't Have Any Account?  "),
                      GestureDetector(
                        child: Text(
                          "Register Now",
                          style: TextStyle(color: Color(0xffF5591F)),
                        ),
                        onTap: () {
                          // Write Tap Code Here.
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SignUpScreen(),
                              ));
                        },
                      )
                    ],
                  ),
                )
              ],
            ))));
  }
}
