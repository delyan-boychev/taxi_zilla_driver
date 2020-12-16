import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'main.dart';
import 'dart:async';
import 'userOperations.dart';
import 'newOrderPage.dart';

class loggedInPage extends StatelessWidget {
  checkForOrders() async
  {
       Timer.periodic(Duration(seconds: 3), (timer) async {
         final o = await userFunctions().checkForOrders();
         if(o != null)
         {
         order = jsonDecode(o);
         address = await userFunctions().getAdresssByCoords(order["x"], order["y"]); 
         runApp(newOrderPage());
         timer.cancel();
         }
         });
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    checkForOrders();
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    return MaterialApp(
      title: 'taxiZilla Шофьор - ' + name,
      theme: ThemeData(
        primarySwatch: generateMaterialColor(Color.fromRGBO(255, 237, 0, 1)),
      ),
      home: Scaffold(
        appBar: AppBar(
            title:Row(
              children: [
                  Container(
          margin: new EdgeInsets.only(top: 10, bottom: 10),
          child: Image.asset(
            'assets/img/logo.png',
            height: 60,
            width: 60,
          ),
        ),
              Container(
                  padding: const EdgeInsets.all(8.0), child: new Text(name, textAlign: TextAlign.center))
            ],

          ),

        ),
      ),
    );
  }
}