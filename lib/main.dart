import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'userFunctions.dart';
import 'logInPage.dart';
import 'dart:io';
import 'loggedInPage.dart';

//Deklarirane na promenlivi nujni na prilojenieto
String name;
Map order;
Map profile;
String orderID;
String orderText;
String email;
String address;
String status = "ONLINE";
bool isChecking = false;
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@drawable/notification');
final InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);
MaterialColor primary = generateMaterialColor(Color.fromRGBO(255, 237, 0, 1));
Color primaryColor = Color.fromRGBO(255, 237, 0, 1);

//Funkciq za generirane na MaterialColor ot daden Color
MaterialColor generateMaterialColor(Color color) {
  return MaterialColor(color.value, {
    50: color,
    100: color,
    200: color,
    300: color,
    400: color,
    500: color,
    600: color,
    700: color,
    800: color,
    900: color,
  });
}

//Heduri nujni pri post i get zaqvki
Map<String, String> headers = {};

//Davene na dostup do mestoplojenie i storage
void requestPermissions() async {
  await [
    Permission.location,
    Permission.storage,
  ].request();
}

//Driver code
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  requestPermissions();
  final dir = await getExternalStorageDirectory();
  if (await File(dir.path + "/credentials").exists()) {
    final isLoggedIn = await userFunctions()
        .logInTaxiDriver(await File(dir.path + "/credentials").readAsString());
    if (isLoggedIn) {
      name = await userFunctions().getNameTaxiDriver();
      runApp(loggedInPage());
    } else {
      runApp(loginPage());
    }
  } else {
    runApp(loginPage());
  }
}
