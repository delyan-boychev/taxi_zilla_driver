import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:taxi_zilla_driver/loggedInPage.dart';
import 'userFunctions.dart';
import 'main.dart';

class orderConfirmed extends StatelessWidget {
  // This widget is the root of your application.
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
          body: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                      height: 90,
                      width: 200,
                      child: RaisedButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            side: BorderSide(color: Colors.green)),
                        color: Colors.green,
                        onPressed: () {
                          status = "ONLINE";
                          userFunctions().finishOrder();
                          runApp(loggedInPage());
                        },
                        child: Text('Приключи поръчка',
                            textAlign: TextAlign.center,
                            style: new TextStyle(fontSize: 25)),
                      )),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                      height: 90,
                      width: 200,
                      child: RaisedButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            side: BorderSide(color: Colors.green)),
                        color: Colors.red,
                        onPressed: () {
                          userFunctions().rejectOrderAfterAccept();
                          runApp(loggedInPage());
                        },
                        child: Text('Откажи поръчка',
                            textAlign: TextAlign.center,
                            style: new TextStyle(fontSize: 25)),
                      )),
                ],
              )
            ],
          )),
    );
  }
}
