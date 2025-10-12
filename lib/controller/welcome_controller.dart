import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tcc_flutter/pages/home.dart';
import 'package:tcc_flutter/pages/login.dart';
import 'package:tcc_flutter/utils/prefs.dart';

class WelcomeController {
  void startApplication(BuildContext context) {
    Future future = Future.delayed(Duration(seconds: 2));
    future.then((value) => {_callApi(context)});
  }

  Future _callApi(BuildContext context) async {
    final tokenJWT = await Prefs.getString("token");

    try {
      final response = await http.get(
        Uri.parse('http://localhost:8080/auth/validate/$tokenJWT'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final isValid = response.body.toLowerCase() == 'true';

        if (isValid) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Home()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Login()),
          );
        }
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Login()),
        );
      }
    } catch (e) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Login()),
      );
    }
  }
}
