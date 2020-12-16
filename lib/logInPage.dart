import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'main.dart';
import 'userOperations.dart';
import 'loggedInPage.dart';

class loginPage extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    requestPermissions();

    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    return MaterialApp(
      title: 'taxiZilla Шофьор',
      theme: ThemeData(
        primarySwatch: generateMaterialColor(Color.fromRGBO(255, 237, 0, 1)),
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

class loginForm extends StatefulWidget {
  @override
  loginFormState createState() {
    return loginFormState();
  }
}

// Create a corresponding State class.
// This class holds data related to the form.
class loginFormState extends State<loginForm> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a GlobalKey<FormState>,
  // not a GlobalKey<MyCustomFormState>.
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Form(
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
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: ElevatedButton(
                onPressed: () {
                  // Validate returns true if the form is valid, or false
                  // otherwise.
                  if (_formKey.currentState.validate()) {
                    // If the form is valid, display a Snackbar.
                    userFunctions()
                        .logInTaxiDriverFirstTime(
                            emailController.text, passwordController.text)
                        .then((isLoggedIn) {
                      if (isLoggedIn == true) {
                        Scaffold.of(context).showSnackBar(SnackBar(
                            content: Text(
                                "Успешно влязохте в профила си! Моля изчакайте...")));
                        userFunctions()
                            .getNameTaxiDriver()
                            .then((nm) => {name = nm, runApp(loggedInPage())});
                      } else {
                        Scaffold.of(context).showSnackBar(SnackBar(
                            content:
                                Text("Неправилен имейл адрес или парола!")));
                      }
                    });
                  }
                },
                child: Text('Влизане'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
