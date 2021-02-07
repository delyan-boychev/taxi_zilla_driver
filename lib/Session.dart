import 'package:taxi_zilla_driver/userFunctions.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'main.dart';
import 'package:http/http.dart' as http;

//Class Session
class Session {
  //Biskvitki
  Map<String, String> cookies = {};

  //Funkciq za updatevane na biskvitkite
  void _updateCookie(http.Response response) {
    String allSetCookie = response.headers['set-cookie'];

    if (allSetCookie != null) {
      var setCookies = allSetCookie.split(',');

      for (var setCookie in setCookies) {
        var cookies = setCookie.split(';');

        for (var cookie in cookies) {
          _setCookie(cookie);
        }
      }

      headers['Cookie'] = _generateCookieHeader();
    }
  }

  //Funkciq za suzdavane na biskvitki
  void _setCookie(String rawCookie) {
    if (rawCookie.length > 0) {
      var keyValue = rawCookie.split('=');
      if (keyValue.length == 2) {
        var key = keyValue[0].trim();
        var value = keyValue[1];
        if (key == 'path' ||
            key == 'Path' ||
            key == 'expires' ||
            key == 'domain' ||
            key == 'SameSite') return;

        this.cookies[key] = value;
      }
    }
  }

  //Funkciq za generirane na heduri s biskvitki
  String _generateCookieHeader() {
    String cookie = "";

    for (var key in cookies.keys) {
      if (cookie.length > 0) cookie += ";";
      cookie += key + "=" + cookies[key];
    }

    return cookie;
  }

  //Funkciq za get zaqvka
  Future<String> get(String url) async {
    try {
      http.Response response = await http.get(url, headers: headers);
      if (response.body == "401") {
        headers = {};
        final dir = await getExternalStorageDirectory();
        userFunctions().logInTaxiDriver(
            await File(dir.path + "/credentials").readAsString());
        http.Response response = await http.get(url, headers: headers);
        return response.body;
      } else {
        _updateCookie(response);
        return response.body;
      }
    } catch (ex) {
      return "";
    }
  }

  void postExit(String url, dynamic data) {
    http.post(url, body: data, headers: headers);
  }

  //Funkciq za post zaqvka
  Future<String> post(String url, dynamic data) async {
    try {
      http.Response response =
          await http.post(url, body: data, headers: headers);
      if (response.body == "401") {
        headers = {};
        final dir = await getExternalStorageDirectory();
        userFunctions().logInTaxiDriver(
            await File(dir.path + "/credentials").readAsString());
        http.Response response =
            await http.post(url, body: data, headers: headers);
        _updateCookie(response);
        return response.body;
      } else {
        _updateCookie(response);
        return response.body;
      }
    } catch (ex) {
      return "";
    }
  }
}
