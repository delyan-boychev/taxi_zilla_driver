import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'userFunctions.dart';
import 'logInPage.dart';
import 'dart:io';
import 'loggedInPage.dart';

var name;
var order;
var orderID;
var email;
var address;
var status = "ONLINE";
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@drawable/notification');
final InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);
MaterialColor primary = generateMaterialColor(Color.fromRGBO(255, 237, 0, 1));
Color primaryColor = Color.fromRGBO(255, 237, 0, 1);
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

Map<String, String> headers = {};
void requestPermissions() async {
  await [
    Permission.location,
    Permission.storage,
  ].request();
}

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
