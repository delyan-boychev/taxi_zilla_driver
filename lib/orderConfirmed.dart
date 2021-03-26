import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:taxi_zilla_driver/loggedInPage.dart';
import 'package:taxi_zilla_driver/maps_sheet.dart';
import 'userFunctions.dart';
import 'main.dart';

//Stranuca za prieta poruchka
// ignore: camel_case_types
class orderConfirmedPage extends StatefulWidget {
  @override
  orderConfirmedState createState() => orderConfirmedState();
}

//State za stranica za prieta poruchka
// ignore: camel_case_types
class orderConfirmedState extends State<orderConfirmedPage> {
  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  Location location = new Location();
  bool _serviceEnabled;
  bool isChecking2 = false;
  var locData;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    Timer.periodic(Duration(seconds: 3), (timer) async {
      if (!isChecking2) {
        isChecking2 = true;
        _serviceEnabled = await location.serviceEnabled();
        if (!_serviceEnabled) {
          _serviceEnabled = await location.requestService();
          isChecking2 = false;
        } else {
          locData = await location.getLocation();
          userFunctions().checkForOrders(locData.longitude.toString(),
              locData.latitude.toString(), "BUSY");
          isChecking2 = false;
        }
      }
    });
  }

  //Osnova na stranicata
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'taxiZilla Шофьор - ' + name,
      theme: ThemeData(
        primarySwatch: generateMaterialColor(Color.fromRGBO(255, 237, 0, 1)),
      ),
      home: Scaffold(
          appBar: AppBar(
            actions: [
              Builder(
                  builder: (context) => GestureDetector(
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return new SimpleDialog(
                                title: new Text("QR код за taxiZilla"),
                                children: [
                                  Image.asset('assets/img/qrcode.png')
                                ],
                              );
                            });
                      },
                      child: Icon(
                        Icons.assignment_ind_rounded,
                        size: 35,
                      )))
            ],
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
                    child:
                        new Text("Приета поръчка", textAlign: TextAlign.center))
              ],
            ),
          ),
          body: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Container(
                  width: double.infinity,
                  child: Column(
                    children: [
                      Container(
                          margin: const EdgeInsets.only(top: 10.0),
                          child: Text(
                            "$address",
                            textAlign: TextAlign.center,
                            style: new TextStyle(fontSize: 25),
                          )),
                      Container(
                          margin: const EdgeInsets.only(top: 10.0),
                          child: Text(
                            "$notesOrItems",
                            textAlign: TextAlign.center,
                            style: new TextStyle(fontSize: 25),
                          )),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 10.0),
                            child: SizedBox(
                                height: 90,
                                width: 200,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                          side:
                                              BorderSide(color: Colors.green)),
                                      primary: Colors.green),
                                  onPressed: () {
                                    status = "ONLINE";
                                    userFunctions().finishOrder();
                                    runApp(loggedInPage());
                                  },
                                  child: Text('Приключи поръчка',
                                      textAlign: TextAlign.center,
                                      style: new TextStyle(fontSize: 25)),
                                )),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 10.0),
                            child: SizedBox(
                                height: 90,
                                width: 200,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                          side: BorderSide(color: Colors.red)),
                                      primary: Colors.red),
                                  onPressed: () {
                                    status = "BUSY";
                                    userFunctions().rejectOrderAfterAccept();
                                    runApp(loggedInPage());
                                  },
                                  child: Text('Откажи поръчка',
                                      textAlign: TextAlign.center,
                                      style: new TextStyle(fontSize: 25)),
                                )),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 10.0),
                            child: SizedBox(
                                height: 90,
                                width: 200,
                                child: Builder(
                                    builder: (context) => ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20.0),
                                                  side: BorderSide(
                                                      color: primaryColor)),
                                              primary: primaryColor),
                                          onPressed: () async {
                                            if (order["address"] != "") {
                                              MapsSheet.show(
                                                context: context,
                                                onMapTap: (map) {
                                                  map.showMarker(
                                                    coords: Coords(0, 0),
                                                    title: order["address"],
                                                    extraParams: {
                                                      'q': order["address"]
                                                    },
                                                  );
                                                },
                                              );
                                            } else {
                                              MapsSheet.show(
                                                context: context,
                                                onMapTap: (map) {
                                                  map.showMarker(
                                                    coords: Coords(
                                                        double.parse(
                                                            order["y"]),
                                                        double.parse(
                                                            order["x"])),
                                                    title: address,
                                                  );
                                                },
                                              );
                                            }
                                          },
                                          child: Text('Отвори навигация',
                                              textAlign: TextAlign.center,
                                              style:
                                                  new TextStyle(fontSize: 25)),
                                        ))),
                          ),
                        ],
                      ),
                    ],
                  )))),
    );
  }
}
