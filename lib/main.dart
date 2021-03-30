import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'newOrderPage.dart';
import 'userFunctions.dart';
import 'logInPage.dart';
import 'dart:io';
import 'loggedInPage.dart';

//Deklarirane na promenlivi nujni na prilojenieto
String name = "";
Map order = {};
Map profile = {};
String orderID = "";
String orderText = "";
String email = "";
String address = "";
String status = "ONLINE";
bool isChecking = false;
bool loggedIn = false;
bool isOrderDelivered = false;
String notesOrItems = "";
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@drawable/notification');
final InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);
MaterialColor primary = generateMaterialColor(Color.fromRGBO(255, 237, 0, 1));
Color primaryColor = Color.fromRGBO(255, 237, 0, 1);
MethodChannel channel = new MethodChannel("taxiZillaMethodChannel");

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

Location location = new Location();
bool _serviceEnabled;
var citySupported;
var locData;
var o;
bool locationReqeustSended = false;

//Heduri nujni pri post i get zaqvki
Map<String, String> headers = {};
//Davene na dostup do mestoplojenie i storage

Future<dynamic> myUtilsHandler(MethodCall methodCall) async {
  switch (methodCall.method) {
    case "checkForOrdersAndSetLocation":
      if (loggedIn && !locationReqeustSended) {
        checkForOrdersAndSetLocation();
      }
      break;
  }
}

void checkForOrdersAndSetLocation() async {
  _serviceEnabled = await location.serviceEnabled();
  if (!_serviceEnabled) {
    locationReqeustSended = true;
    _serviceEnabled = await location.requestService();
    locationReqeustSended = false;
  } else {
    locData = await location.getLocation();
    o = await userFunctions().checkForOrders(locData.longitude.toString(),
        locData.latitude.toString(), status.toString());
    if (o != null && !isOrderDelivered) {
      if (o.contains("address") && o.contains("x")) {
        if (status == "BUSY") {
          userFunctions().rejectOrder();
        } else {
          order = jsonDecode(o);
          status = "BUSY";
          await userFunctions().checkForOrders(locData.longitude.toString(),
              locData.latitude.toString(), status.toString());
          if (order["address"] != "")
            address = order["address"];
          else
            address = await userFunctions().getAdresssByCoords(
                order["x"].toString(), order["y"].toString());
          citySupported = await userFunctions().checkCityIsSupported();
          if (citySupported) {
            if (order["items"] == "" || order["items"] == null) {
              orderText =
                  "ПОРЪЧКА НА ТАКСИ \nИмате нова поръчка до $address! \nБележки: ${order["notes"]}";
            } else {
              orderText =
                  "ПОРЪЧКА ЗА ПАЗАРУВАНЕ \nИмате нова поръчка за пазаруване до $address! \nУказания за пазаруване: ${order["items"]}";
            }
            isOrderDelivered = true;
            runApp(newOrderPage());
          } else {
            status = "ONLINE";
            await userFunctions().checkForOrders(locData.longitude.toString(),
                locData.latitude.toString(), status.toString());
          }
        }
      }
    }
  }
}

//Driver code
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  channel.setMethodCallHandler(myUtilsHandler);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  final dir = await getExternalStorageDirectory();
  if (await File(dir.path + "/credentials").exists()) {
    final isLoggedIn = await userFunctions()
        .logInTaxiDriver(await File(dir.path + "/credentials").readAsString());
    if (isLoggedIn) {
      name = await userFunctions().getNameTaxiDriver();
      runApp(loggedInPage());
      loggedIn = true;
    } else {
      runApp(loginPage());
    }
  } else {
    runApp(loginPage());
  }
}
