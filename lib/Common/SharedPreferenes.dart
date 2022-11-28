import 'package:shared_preferences/shared_preferences.dart';

adduserIdSF(String value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('user_id', value);
}


getuserIdSF() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? stringValue = prefs.getString('user_id');
  return stringValue;
}

adduserNameSF(String value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('user_name', value);
}


getuserNameSF() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? stringValue = prefs.getString('user_name');
  return stringValue;
}


adduserEmailSF(String value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('email', value);
}


getuserEmailSF() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? stringValue = prefs.getString('email');
  return stringValue;
}

