import 'dart:math';
import 'package:path_provider/path_provider.dart';
import 'package:encrypt/encrypt.dart';
import 'main.dart';
import 'dart:convert';
import 'dart:io';
import 'package:ntp/ntp.dart';
import 'Session.dart';

//Class userFunctions
// ignore: camel_case_types
class userFunctions {
  //Deklarirane na promenlivi
  final key = Key.fromUtf8("QfTjWnZq4t7w!z%C*F-JaNdRgUkXp2s5");
  final iv = IV.fromLength(16);
  //Kriptirane na kredentiali
  String encryptCredentials(String creditinals) {
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    final encrypted = encrypter.encrypt(creditinals, iv: iv);
    return encrypted.base64;
  }

  //Funkciq za otkazvane na poruchka sled priemane
  void rejectOrderAfterAccept() async {
    await Session().post(
        "https://taxizilla.cheapsoftbg.com/order/rejectOrderAfterAccept", {
      'orderID': orderID.toString(),
      'senderID': order["sender"]["id"].toString()
    });
  }

  Future<bool> checkCityIsSupported() async {
    final resp = await Session().post(
        "https://taxizilla.cheapsoftbg.com/auth/getCitiesByFirmId",
        {'firmID': profile["firmId"].toString()});
    var json = jsonDecode(resp);
    var exists = false;
    if (order["address"].toString() != "" &&
        order["address"].toString() != " ") {
      RegExp regex =
          new RegExp(r"[*]*[,] ((?:град|село) [а-яА-Я ]*), ([а-яА-Я ]*)");
      var matches = regex.allMatches(order["address"].toString());
      for (var el in json) {
        for (Match match in matches) {
          if (el["city"].toString().contains(match.group(1).trim()) &&
              el["region"].toString().contains(match.group(2).trim())) {
            exists = true;
          }
        }
      }
    } else {
      final resp2 = await Session().get(
          "https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/reverseGeocode?location=" +
              order["x"].toString() +
              ", " +
              order["y"].toString() +
              "&f=pjson");
      final json2 = jsonDecode(resp2);
      for (var el in json) {
        if (el["city"]
                .toString()
                .contains(json2["address"]["City"].toString()) &&
            el["region"]
                .toString()
                .contains(json2["address"]["Region"].toString())) {
          exists = true;
        }
      }
    }
    if (!exists) {
      rejectOrder();
    }
    return exists;
  }

  //Funkciq za vzemane na imeto na taksimetrov shofyor
  Future<String> getNameTaxiDriver() async {
    final resp =
        await Session().get("https://taxizilla.cheapsoftbg.com/auth/profile");
    final json = jsonDecode(resp);
    profile = jsonDecode(resp);
    final directory = await getExternalStorageDirectory();
    final File driverID = new File("${directory.path}/driverID");
    driverID.writeAsString(profile["id"].toString());
    return json["fName"] + " " + json["lName"];
  }

  //Funkciq za proverqvane na poruchki i updatevane na mestopolojenie i status
  Future<String> checkForOrders(String x, String y, String status) async {
    final resp = await Session().post(
        "https://taxizilla.cheapsoftbg.com/auth/changeStatusAndCheckForOrders",
        {'x': x, 'y': y, 'newStatus': status});
    if (resp == "")
      return null;
    else
      return resp;
  }

  //Funkciq za priklyuchvane na poruchka
  void finishOrder() async {
    await Session().post(
        "https://taxizilla.cheapsoftbg.com/order/finishOrder", {'id': orderID});
  }

  //Funkciq za vzemane na adres ot koordinati
  Future<String> getAdresssByCoords(String x, String y) async {
    final resp = await Session().get(
        "https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/reverseGeocode?location=$x, $y&f=pjson");
    var a = jsonDecode(resp);
    return "${a["address"]["LongLabel"]}";
  }

  //Funkciq za priemane na poruchka
  void acceptOrder() async {
    final resp = await Session()
        .post("https://taxizilla.cheapsoftbg.com/order/acceptOrder", {});
    orderID = resp;
  }

  final _chars =
      "\$%!@#^&*()-ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
  Random _rnd = Random();

  //Funkciq za generirane na random string po zadadena duljina
  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  //Funkciq za generirane na klyuch za verifikaciq pri login
  String algorithm() {
    DateTime dateUTC = new DateTime.now().toUtc();
    var data =
        "${dateUTC.year}${dateUTC.day.toString().padLeft(2, '0')}${dateUTC.month.toString().padLeft(2, '0')}${dateUTC.hour.toString().padLeft(2, '0')}${dateUTC.minute.toString().padLeft(2, '0')}${dateUTC.second.toString().padLeft(2, '0')}";
    var result = "";
    for (var i = 0; i < data.length; i += 2) {
      var tmp = int.parse(data[i]) * 10 + int.parse(data[i + 1]);
      tmp += 33;
      result += String.fromCharCode(tmp);
    }
    result = getRandomString(6) + result + getRandomString(6);
    return result;
  }

  //Funkciq za otkazvane na poruchka
  void rejectOrder() async {
    await Session()
        .post("https://taxizilla.cheapsoftbg.com/order/rejectOrder", {});
  }

  //Funkciq za dekriptirane na credentiali
  String decryptCredentials(String creditinals) {
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    final decrypted = encrypter.decrypt64(creditinals, iv: iv);
    return decrypted;
  }

  //Funkciq za login na taksimetrovi shofyori
  Future<bool> logInTaxiDriver(String json) async {
    DateTime _myTime;
    DateTime _ntpTime;
    _myTime = await NTP.now();
    final int offset = await NTP.getNtpOffset(localTime: DateTime.now());
    _ntpTime = _myTime.add(Duration(milliseconds: offset));
    var parsedJson = jsonDecode(decryptCredentials(json));
    parsedJson["key"] = algorithm();
    parsedJson["offset"] =
        _myTime.difference(_ntpTime).inMilliseconds.toString();
    final j = await Session().post(
        "https://taxizilla.cheapsoftbg.com/auth/loginTaxiDriver", parsedJson);
    if (j == "true") {
      return true;
    } else {
      return false;
    }
  }

  //Funkciq za purvonachalen login na taksimetrov shofyor
  Future<bool> logInTaxiDriverFirstTime(String email, String password) async {
    DateTime _myTime;
    DateTime _ntpTime;
    _myTime = await NTP.now();
    final int offset = await NTP.getNtpOffset(localTime: DateTime.now());
    _ntpTime = _myTime.add(Duration(milliseconds: offset));
    final response = await Session()
        .post("https://taxizilla.cheapsoftbg.com/auth/loginTaxiDriver", {
      'email': email,
      'password': password,
      'key': algorithm(),
      'offset': _myTime.difference(_ntpTime).inMilliseconds.toString()
    });
    if (response == "true") {
      final directory = await getExternalStorageDirectory();
      final File credentialsFile = new File("${directory.path}/credentials");
      credentialsFile.writeAsString(encryptCredentials(
          jsonEncode(<String, String>{'email': email, 'password': password})));
      return true;
    } else {
      return false;
    }
  }
}
