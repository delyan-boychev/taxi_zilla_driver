import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'main.dart';
import 'userOperations.dart';
import 'loggedInPage.dart';

//Stranica za login na shofyor
// ignore: camel_case_types
class loginPage extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'taxiZilla Шофьор',
      theme: ThemeData(
        primarySwatch: primary,
      ),
      home: Scaffold(
        appBar: AppBar(
            title: Container(
          margin: new EdgeInsets.only(top: 10, bottom: 10),
          child: Image.asset(
            'assets/img/logo.png',
            height: 60,
            width: 60,
          ),
        )),
        body: loginForm(),
      ),
    );
  }
}

//Stranica za vlizane v prilojenieto
// ignore: camel_case_types
class loginForm extends StatefulWidget {
  @override
  loginFormState createState() {
    return loginFormState();
  }
}

//State na stranicata
// ignore: camel_case_types
class loginFormState extends State<loginForm> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
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
    Future<void> showMyDialog() async {
      return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Информация'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(
                      'taxiZilla използва достъпa дo местоположението постоянно, за да може да приема поръчки дори във фонов режим. Ние не съхраняваме история на местоположението Ви, а само последното изпратено. Използва се за изчисляване на разстояние между шофьора и клиента. Само клиентът може да Ви проследи, докато поръчката е със статус Приета. Съгласни ли сте?'),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child:
                    Text('Съглсен съм', style: TextStyle(color: Colors.black)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

    void requestPermissions() async {
      if (!await Permission.locationAlways.isGranted) {
        await showMyDialog();
      }
      await [
        Permission.location,
        Permission.locationAlways,
        Permission.storage,
      ].request();
    }

    requestPermissions();
    //Formulqr za login
    return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
            width: double.infinity,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: new EdgeInsets.only(top: 10, bottom: 10),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Text(
                        "Влизане като таксиметров шофьор",
                        style: TextStyle(fontSize: 20.0),
                      ),
                    ),
                  ),
                  Container(
                    margin: new EdgeInsets.only(left: 10.0, right: 10.0),
                    child: TextFormField(
                      controller: emailController,
                      decoration: InputDecoration(hintText: 'Email'),
                      validator: (value) {
                        var isEmail = RegExp(
                            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
                        if (!isEmail.hasMatch(value)) {
                          return 'Невалиден имейл адрес!';
                        }
                        return null;
                      },
                    ),
                  ),
                  Container(
                    margin: new EdgeInsets.only(left: 10.0, right: 10.0),
                    child: TextFormField(
                      controller: passwordController,
                      decoration: InputDecoration(hintText: 'Парола'),
                      validator: (value) {
                        if (value.length < 8) {
                          return 'Невалидна парола!';
                        }
                        return null;
                      },
                      obscureText: true,
                    ),
                  ),
                  //Buton za login
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState.validate()) {
                            userOperations()
                                .logInTaxiDriverFirstTime(emailController.text,
                                    passwordController.text)
                                .then((isLoggedIn) {
                              if (isLoggedIn == true) {
                                loggedIn = true;
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    content: Text(
                                        "Успешно влязохте в профила си! Моля изчакайте...")));
                                userOperations().getNameTaxiDriver().then(
                                    (nm) =>
                                        {name = nm, runApp(loggedInPage())});
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    content: Text(
                                        "Неправилен имейл адрес или парола!")));
                              }
                            });
                          }
                        },
                        child: Text(
                          'Влизане',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )));
  }
}
