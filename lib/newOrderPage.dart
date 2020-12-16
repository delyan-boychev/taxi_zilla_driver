import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:taxi_zilla_driver/logInPage.dart';
import 'main.dart';
import 'dart:async';
import 'userOperations.dart';
import 'loggedInPage.dart';
import 'orderConfirmed.dart';

class newOrderPage extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    int a = 20;
    Timer.periodic(Duration(seconds: 1), (timer) async {
      if (a == 0) {
        userFunctions().rejectOrder();
        runApp(loggedInPage());
        timer.cancel();
      } else if (a == -1) {
        timer.cancel();
      } else
        a--;
    });

    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    return MaterialApp(
      title: 'taxiZilla Шофьор - ' + name,
      theme: ThemeData(
        primarySwatch: generateMaterialColor(Color.fromRGBO(255, 237, 0, 1)),
      ),
      home: Scaffold(
          appBar: AppBar(
            title: Row(
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
                    padding: const EdgeInsets.all(8.0),
                    child: new Text("Имате нова поръчка",
                        textAlign: TextAlign.center))
              ],
            ),
          ),
          body: Column(
            children: [
              Text(
                "Имате нова поръчка в следното населено място $address! Имате 20 секунди, за да я приемете!",
                style: new TextStyle(fontSize: 20),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  RaisedButton(
                    color: Colors.green,
                    onPressed: () {
                      userFunctions().acceptOrder();
                      a = -1;
                      runApp(orderConfirmed());
                    },
                    child: Text('Приемане', style: new TextStyle(fontSize: 20)),
                  ),
                  RaisedButton(
                    color: Colors.red,
                    onPressed: () {
                      userFunctions().rejectOrder();
                      a = -1;
                      runApp(loggedInPage());
                    },
                    child:
                        Text('Отказване', style: new TextStyle(fontSize: 20)),
                  ),
                ],
              ),
            ],
          )),
    );
  }
}
