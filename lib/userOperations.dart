import 'package:path_provider/path_provider.dart';
import 'package:encrypt/encrypt.dart';
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

  Future<String> getNameTaxiDriver() async {
    final resp =
        await Session().get("https://taxizilla.cheapsoftbg.com/auth/profile");
    final json = jsonDecode(resp);
    return json["fName"] + " " + json["lName"];
  }

  Future<String> checkForOrders() async {
    final resp = await Session().post(
        "https://taxizilla.cheapsoftbg.com/auth/changeStatus",
        {'x': "25.679881", 'y': "43.132070", 'newStatus': "ONLINE"});
    final resp2 = await Session()
        .get("https://taxizilla.cheapsoftbg.com/order/getMyOrders");
    if (resp2 == "")
      return null;
    else
      return resp2;
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
  }

  void rejectOrder() async {
    final resp = await Session()
        .post("https://taxizilla.cheapsoftbg.com/order/rejectOrder", {});
  }

  String decryptCredentials(String creditinals) {
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    final decrypted = encrypter.decrypt64(creditinals, iv: iv);
    return decrypted;
  }

  Future<bool> logInTaxiDriver(String json) async {
    var parsedJson = jsonDecode(decryptCredentials(json));
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
        {'email': email, 'password': password});
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
