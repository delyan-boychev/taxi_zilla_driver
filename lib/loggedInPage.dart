import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'main.dart';
import 'dart:async';
import 'userFunctions.dart';
import 'newOrderPage.dart';
import 'package:location/location.dart';

//Proverka za poruchki na vseki 3 sekundi
checkForOrders() async {
  while (true) {
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    Location location = new Location();
    bool _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
    } else {
      final locData = await location.getLocation();
      final o = await userFunctions().checkForOrders(
          locData.longitude.toString(),
          locData.latitude.toString(),
          status.toString());
      if (o != null) {
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
              address = await userFunctions()
                  .getAdresssByCoords(order["x"], order["y"]);
            runApp(newOrderPage());
            break;
          }
        }
      }
    }
    await Future.delayed(const Duration(seconds: 3), () => "3");
  }
}

//Stranica kogato shofyoryt e vlqzul
class loggedInPage extends StatefulWidget {
  @override
  _loggedInState createState() => _loggedInState();
}

//State na stranicata
class _loggedInState extends State<loggedInPage> {
  var statusButttonText = "На линия";
  var statusButtonColor = Colors.green;

  //Osnova na stranicata
  @override
  Widget build(BuildContext context) {
    checkForOrders();
    if (status == "ONLINE") {
      setState(() {
        statusButtonColor = Colors.green;
        statusButttonText = "На линия";
      });
    } else {
      setState(() {
        statusButtonColor = Colors.red;
        statusButttonText = "Зает";
      });
    }
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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
                    child: new Text(name, textAlign: TextAlign.center))
              ],
            ),
          ),
          body: Container(
              margin: const EdgeInsets.only(top: 40),
              alignment: Alignment.topCenter,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    shape: CircleBorder(), primary: statusButtonColor),
                onPressed: () {
                  if (status == "ONLINE") {
                    status = "BUSY";
                    setState(() {
                      statusButtonColor = Colors.red;
                      statusButttonText = "Зает";
                    });
                  } else {
                    status = "ONLINE";
                    setState(() {
                      statusButtonColor = Colors.green;
                      statusButttonText = "На линия";
                    });
                  }
                },
                child: Container(
                  width: 300,
                  height: 300,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(shape: BoxShape.circle),
                  child: Text('$statusButttonText',
                      textAlign: TextAlign.center,
                      style: new TextStyle(fontSize: 50)),
                ),
              ))),
    );
  }
}
