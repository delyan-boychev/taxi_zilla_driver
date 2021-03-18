import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:taxi_zilla_driver/loggedInPage.dart';
import 'userFunctions.dart';
import 'main.dart';

//Stranica za prieta poruchka
// ignore: camel_case_types
class orderConfirmed extends StatelessWidget {
  //Osnova na stranuicata
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
                  Container(
                    margin: const EdgeInsets.only(top: 10.0),
                    child: SizedBox(
                        height: 90,
                        width: 200,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                  side: BorderSide(color: Colors.green)),
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
                                  borderRadius: BorderRadius.circular(20.0),
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
              )
            ],
          )),
    );
  }
}
