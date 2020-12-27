import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'main.dart';
import 'dart:async';
import 'userOperations.dart';
import 'newOrderPage.dart';
import 'package:location/location.dart';

checkForOrders() async {
  Timer.periodic(Duration(seconds: 4), (timer) async {
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    Location location = new Location();
    bool _serviceEnabled = await location.serviceEnabled();
    final locData = await location.getLocation();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
    } else {
      final o = await userFunctions().checkForOrders(
          locData.longitude.toString(),
          locData.latitude.toString(),
          status.toString());
      if (o != null) {
        if (o.contains("address") && o.contains("x")) {
          if (status == "BUSY") {
            userFunctions().rejectOrder();
          } else {
            timer.cancel();
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
          }
        }
      }
    }
  });
}

class loggedInPage extends StatefulWidget {
  @override
  _loggedInState createState() => _loggedInState();
}

class _loggedInState extends State<loggedInPage> {
  var statusButttonText = "На линия";
  var statusButtonColor = Colors.green;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    checkForOrders();
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
            child: SizedBox(
                height: 110,
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      side: BorderSide(color: Colors.black, width: 5)),
                  color: statusButtonColor,
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
                  child: Text('$statusButttonText',
                      textAlign: TextAlign.center,
                      style: new TextStyle(fontSize: 50)),
                ))),
      ),
    );
  }
}
