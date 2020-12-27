import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:taxi_zilla_driver/userStatus.enum.dart';
import 'main.dart';
import 'dart:async';
import 'package:audioplayers/audio_cache.dart';
import 'userOperations.dart';
import 'loggedInPage.dart';
import 'orderConfirmed.dart';

class newOrderPage extends StatefulWidget {
  @override
  _newOrderState createState() => _newOrderState();
}

class _newOrderState extends State<newOrderPage> {
  int a = 20;
  final cache = AudioCache();
  var player = AudioPlayer();
  void startPlayer() async {
    player = await cache.loop('sound/alarm.mp3');
  }

  void stopPlayer() async {
    player.stop();
  }

  @override
  void initState() {
    super.initState();
    startPlayer();
    Timer.periodic(Duration(seconds: 1), (timer) async {
      if (a == 0) {
        userFunctions().rejectOrder();
        runApp(loggedInPage());
        timer.cancel();
        stopPlayer();
      } else if (a == -1) {
        timer.cancel();
        stopPlayer();
      } else
        setState(() => a--);
    });
  }

  // This widget is the root of your application.
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
          body: Column(
            children: [
              Container(
                  margin: const EdgeInsets.only(top: 10.0),
                  child: Text(
                    "Имате нова поръчка до $address! Имате 20 секунди, за да я приемете!",
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
                          child: RaisedButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                                side: BorderSide(color: Colors.green)),
                            color: Colors.green,
                            onPressed: () {
                              status = userStatus.BUSY;
                              userFunctions().acceptOrder();
                              a = -1;
                              runApp(orderConfirmed());
                            },
                            child: Text('Приемане',
                                textAlign: TextAlign.center,
                                style: new TextStyle(fontSize: 25)),
                          )),
                      SizedBox(
                          height: 90,
                          child: RaisedButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                                side: BorderSide(color: Colors.red)),
                            color: Colors.red,
                            onPressed: () {
                              status = userStatus.ONLINE;
                              userFunctions().rejectOrder();
                              a = -1;
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
                      margin: const EdgeInsets.only(top: 40.0),
                      child: CircularCountDownTimer(
                        duration: 20,
                        controller: _controller,
                        width: 200,
                        height: 200,
                        color: Colors.white,
                        fillColor: primaryColor,
                        backgroundColor: null,
                        strokeWidth: 5.0,
                        strokeCap: StrokeCap.butt,
                        textStyle: TextStyle(
                            fontSize: 25,
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                        isReverse: true,
                        isReverseAnimation: true,
                        isTimerTextShown: true,
                      )),
                ],
              )
            ],
          )),
    );
  }
}
