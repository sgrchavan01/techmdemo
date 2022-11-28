import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:techmdemo/Screens/login_screen.dart';


import '../Common/comHelper.dart';
import '../Common/getTextFormField.dart';
import '../DatabaseHandler/dbHelper.dart';
import '../Model/usermodel.dart';

class SignUpScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => InitState();
}

class InitState extends State<SignUpScreen> {
  @override
  Widget build(BuildContext context) => initWidget();

  final _formKey = new GlobalKey<FormState>();

  final _conUserName = TextEditingController();
  final _conEmail = TextEditingController();
  final _conPassword = TextEditingController();
  final _conCPassword = TextEditingController();
  var dbHelper;

  @override
  void initState() {
    super.initState();
    dbHelper = DbHelper();
  }

  signUp() async {
    String uname = _conUserName.text;
    String email = _conEmail.text;
    String passwd = _conPassword.text;
    String cpasswd = _conCPassword.text;

    if (_formKey.currentState!.validate()) {
      if (uname.isEmpty) {
        alertDialog('Enter Name',context);
      } else if (!validateEmail(email)) {
        alertDialog('Enter Valid Email',context);
      } else if (passwd.isEmpty) {
        alertDialog('Enter Password',context);
      } else if (passwd != cpasswd) {
        alertDialog('Password Mismatch',context);
      } else {
        _formKey.currentState!.save();
        UserModel uModel = UserModel(uname, email, passwd);
        await dbHelper.saveData(uModel).then((userData) {
          if (userData != null) {
            alertDialog("Successfully Saved", context);
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => LoginScreen()));
          }else{
            alertDialog("Error: Email Already Exists", context);
          }
        }).catchError((error) {
          print(error);
          alertDialog("Error: Data Save Fail",context);
        });
      }
    }
  }

  Widget initWidget() {
    return Scaffold(
        body: Form(
            key: _formKey,
            child: SingleChildScrollView(
                child: Column(
              children: [
                Container(
                  height: 250,
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
                          "Register",
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                      )
                    ],
                  )),
                ),
                getTextFormField(
                    controller: _conUserName,
                    icon: Icons.person_outline,
                    inputType: TextInputType.text,
                    hintName: 'Name'),
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
                getTextFormField(
                    controller: _conCPassword,
                    icon: Icons.key,
                    inputType: TextInputType.text,
                    isObscureText: true,
                    hintName: 'Confirm Password'),
                InkWell(
                  onTap: () {
                    signUp();
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
                      "REGISTER",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 10, bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Have Already Member?  "),
                      GestureDetector(
                        child: Text(
                          "Login Now",
                          style: TextStyle(color: Color(0xffF5591F)),
                        ),
                        onTap: () {
                          // Write Tap Code Here.
                          Navigator.pop(context);
                        },
                      )
                    ],
                  ),
                )
              ],
            ))));
  }


}
