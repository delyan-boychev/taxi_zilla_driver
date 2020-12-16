import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'userOperations.dart';
import 'logInPage.dart';
import 'dart:io';
import 'loggedInPage.dart';
var name;
var order;
var address;
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
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.storage,
    ].request();
  }
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  requestPermissions();

 final dir = await getExternalStorageDirectory();
 if(await File(dir.path + "/credentials").exists())
 {
   final isLoggedIn = await userFunctions().logInTaxiDriver(await File(dir.path + "/credentials").readAsString());
   if(isLoggedIn)
   {
     name = await userFunctions().getNameTaxiDriver();
     runApp(loggedInPage());
   }
   else
   {
     runApp(loginPage());
   }
 }
 else
 {
   runApp(loginPage());
 }
}



