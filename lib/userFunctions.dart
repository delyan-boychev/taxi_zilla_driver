import 'dart:math';
import 'package:path_provider/path_provider.dart';
import 'package:encrypt/encrypt.dart';
import 'main.dart';
import 'dart:convert';
import 'dart:io';
import 'Session.dart';

class userFunctions {
  final key = Key.fromUtf8("QfTjWnZq4t7w!z%C*F-JaNdRgUkXp2s5");
  final iv = IV.fromLength(16);
  String encryptCredentials(String creditinals) {
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    final encrypted = encrypter.encrypt(creditinals, iv: iv);
    return encrypted.base64;
  }

  void rejectOrderAfterAccept() async {
    final resp = await Session().post(
        "https://taxizilla.cheapsoftbg.com/order/rejectOrderAfterAccept",
        {'orderID': orderID.toString(), 'sender': order["sender"]});
  }

  Future<String> getNameTaxiDriver() async {
    final resp =
        await Session().get("https://taxizilla.cheapsoftbg.com/auth/profile");
    final json = jsonDecode(resp);
    return json["fName"] + " " + json["lName"];
  }

  Future<String> checkForOrders(String x, String y, String status) async {
    final resp = await Session().post(
        "https://taxizilla.cheapsoftbg.com/auth/changeStatusAndCheckForOrders",
        {'x': x, 'y': y, 'newStatus': status});
    if (resp == "")
      return null;
    else
      return resp;
  }

  void finishOrder() async {
    await Session().post(
        "https://taxizilla.cheapsoftbg.com/order/finishOrder", {'id': orderID});
  }

  Future<String> getAdresssByCoords(String x, String y) async {
    final resp = await Session().get(
        "https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/reverseGeocode?location=$x, $y&f=pjson");
    var a = jsonDecode(resp);
    return "${a["address"]["LongLabel"]}";
  }

  void acceptOrder() async {
    final resp = await Session()
        .post("https://taxizilla.cheapsoftbg.com/order/acceptOrder", {});
    orderID = resp;
  }

  final _chars =
      "\$%!@#^&*()-ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
  Random _rnd = Random();

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
  String algorithm() {
    DateTime date = new DateTime.now();
    DateTime dateUTC = new DateTime.utc(
        date.year, date.month, date.day, date.hour, date.minute, date.second);
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

  void rejectOrder() async {
    await Session()
        .post("https://taxizilla.cheapsoftbg.com/order/rejectOrder", {});
  }

  String decryptCredentials(String creditinals) {
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    final decrypted = encrypter.decrypt64(creditinals, iv: iv);
    return decrypted;
  }

  Future<bool> logInTaxiDriver(String json) async {
    var parsedJson = jsonDecode(decryptCredentials(json));
    parsedJson["key"] = algorithm();
    final j = await Session().post(
        "https://taxizilla.cheapsoftbg.com/auth/loginTaxiDriver", parsedJson);
    if (j == "true") {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> logInTaxiDriverFirstTime(String email, String password) async {
    final response = await Session().post(
        "https://taxizilla.cheapsoftbg.com/auth/loginTaxiDriver",
        {'email': email, 'password': password, 'key': algorithm()});
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
