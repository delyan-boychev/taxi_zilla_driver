import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'main.dart';
import 'dart:async';
import 'package:audioplayers/audio_cache.dart';
import 'userOperations.dart';
import 'loggedInPage.dart';
import 'orderConfirmed.dart';

//Stranica za priemane ili otkazvane na poruchka
// ignore: camel_case_types
class newOrderPage extends StatefulWidget {
  @override
  newOrderState createState() => newOrderState();
}

//State na stranicata
// ignore: camel_case_types
class newOrderState extends State<newOrderPage> {
  //Deklarirane na promenlivi
  int a = 20;
  final cache = AudioCache();
  var player = AudioPlayer();
  //Fuknkciq za puskane na ton za izvestqvane i notifikaciq
  void startPlayerAndPushNotification() async {
    player = await cache.loop('sound/alarm.mp3');
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
            'taxi_zilla_bg', 'taxi_zilla_bg', 'taxi_zilla_bg',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: false);
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(0, 'Нова поръчка',
        'Имате нова поръчка в taxiZilla!', platformChannelSpecifics,
        payload: 'item x');
  }

  //Funkciq za spirane na tona za izvestqvane
  void stopPlayer() async {
    player.stop();
  }

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

  //Funkciq pri startirane
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    startPlayerAndPushNotification();
    Timer.periodic(Duration(seconds: 1), (timer) async {
      if (a == 0) {
        userOperations().rejectOrder();
        timer.cancel();
        stopPlayer();
        isOrderDelivered = false;
        runApp(loggedInPage());
      } else if (a == -1) {
        isOrderDelivered = false;
        timer.cancel();
        stopPlayer();
      } else
        a--;
    });
  }

  //Osnova na stranicata
  @override
  Widget build(BuildContext context) {
    CountDownController _controller = CountDownController();
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
                    child: new Text("Имате нова поръчка",
                        textAlign: TextAlign.center))
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
                            "$orderText",
                            textAlign: TextAlign.center,
                            style: new TextStyle(fontSize: 25),
                          )),
                      Container(
                          margin: const EdgeInsets.only(top: 40.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              SizedBox(
                                  height: 90,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20.0),
                                            side: BorderSide(
                                                width: 5, color: Colors.black)),
                                        primary: generateMaterialColor(
                                            Color.fromRGBO(14, 204, 14, 1))),
                                    onPressed: () {
                                      status = "BUSY";
                                      userOperations().acceptOrder();
                                      a = -1;
                                      isOrderDelivered = false;
                                      if (order["address"] == "" ||
                                          order["address"] == null) {
                                        address =
                                            "Адрес: Моля включете навигацията, защото адресът може да не е точен!!!";
                                      } else {
                                        address = "Адрес: $address";
                                      }
                                      if (order["items"] == "" ||
                                          order["items"] == null) {
                                        notesOrItems =
                                            "Бележки: ${order["notes"]}";
                                      } else {
                                        notesOrItems =
                                            "Указания за пазаруване: ${order["items"]}";
                                      }
                                      runApp(orderConfirmedPage());
                                    },
                                    child: Text('Приемане',
                                        textAlign: TextAlign.center,
                                        style: new TextStyle(fontSize: 25)),
                                  )),
                              SizedBox(
                                  height: 90,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20.0),
                                            side: BorderSide(
                                                width: 5, color: Colors.black)),
                                        primary: Colors.red),
                                    onPressed: () {
                                      userOperations().rejectOrder();
                                      a = -1;
                                      isOrderDelivered = false;
                                      runApp(loggedInPage());
                                    },
                                    child: Text('Отказване',
                                        textAlign: TextAlign.center,
                                        style: new TextStyle(fontSize: 25)),
                                  )),
                            ],
                          )),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                              margin: const EdgeInsets.only(top: 30.0),
                              child: CircularCountDownTimer(
                                duration: 20,
                                controller: _controller,
                                width: 120,
                                height: 120,
                                fillColor: Colors.white,
                                ringColor: primaryColor,
                                backgroundColor: null,
                                strokeWidth: 5.0,
                                strokeCap: StrokeCap.butt,
                                textStyle: TextStyle(
                                    fontSize: 30,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                                isReverse: true,
                                isTimerTextShown: true,
                              )),
                        ],
                      )
                    ],
                  )))),
    );
  }
}
