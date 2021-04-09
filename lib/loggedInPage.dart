import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:taxi_zilla_driver/logInPage.dart';
import 'main.dart';
import 'userOperations.dart';

//Stranica kogato shofyoryt e vlqzul
// ignore: camel_case_types
class loggedInPage extends StatefulWidget {
  @override
  loggedInState createState() => loggedInState();
}

//State na stranicata
// ignore: camel_case_types
class loggedInState extends State<loggedInPage> with WidgetsBindingObserver {
  var statusButttonText = "На линия";
  var statusButtonColor = generateMaterialColor(Color.fromRGBO(14, 204, 14, 1));
  Icon iconButton = Icon(
    Icons.event_available_rounded,
    size: 50,
  );

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

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  //Osnova na stranicata
  @override
  Widget build(BuildContext context) {
    if (status == "ONLINE") {
      setState(() {
        iconButton = Icon(
          Icons.event_available_rounded,
          size: 50,
        );
        statusButtonColor =
            generateMaterialColor(Color.fromRGBO(14, 204, 14, 1));
        statusButttonText = "На линия";
      });
    } else {
      setState(() {
        iconButton = Icon(
          Icons.event_busy_rounded,
          size: 50,
        );
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
            actions: <Widget>[
              GestureDetector(
                  onTap: () {
                    userOperations().exitProfile();
                    runApp(loginPage());
                  },
                  child: Icon(
                    Icons.exit_to_app,
                    size: 35,
                  )),
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
                    child: new Text(name, textAlign: TextAlign.center))
              ],
            ),
          ),
          body: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Container(
                  width: double.infinity,
                  child: Column(children: <Widget>[
                    Container(
                        margin: const EdgeInsets.only(top: 40),
                        alignment: Alignment.topCenter,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              side: BorderSide(width: 5.0, color: Colors.black),
                              shape: CircleBorder(),
                              primary: statusButtonColor),
                          onPressed: () {
                            if (status == "ONLINE") {
                              status = "BUSY";
                              setState(() {
                                iconButton = Icon(
                                  Icons.event_busy_rounded,
                                  size: 50,
                                );
                                statusButtonColor = Colors.red;
                                statusButttonText = "Зает";
                              });
                            } else {
                              status = "ONLINE";
                              setState(() {
                                iconButton = Icon(
                                  Icons.event_available_rounded,
                                  size: 50,
                                );
                                statusButtonColor = generateMaterialColor(
                                    Color.fromRGBO(14, 204, 14, 1));
                                statusButttonText = "На линия";
                              });
                            }
                          },
                          child: Container(
                            width: 320,
                            height: 320,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(shape: BoxShape.circle),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  iconButton,
                                  Text('$statusButttonText',
                                      textAlign: TextAlign.center,
                                      style: new TextStyle(fontSize: 45))
                                ]),
                          ),
                        )),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 20.0),
                          child: SizedBox(
                              height: 90,
                              width: 200,
                              child: Builder(
                                  builder: (context) => ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20.0),
                                                side: BorderSide(
                                                    width: 5,
                                                    color: Colors.black)),
                                            primary: primaryColor),
                                        onPressed: () async {
                                          showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return new SimpleDialog(
                                                  title: new Text(
                                                      "QR код за taxiZilla"),
                                                  children: [
                                                    Image.asset(
                                                        'assets/img/qrcode.png')
                                                  ],
                                                );
                                              });
                                        },
                                        child: Text('Електронна визитка',
                                            textAlign: TextAlign.center,
                                            style: new TextStyle(fontSize: 25)),
                                      ))),
                        ),
                      ],
                    )
                  ])))),
    );
  }
}
