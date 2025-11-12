import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:tcc_flutter/pages/home.dart';
import 'package:tcc_flutter/utils/prefs.dart';

class LoginController {
  Future login(
    BuildContext context, {
    required String login,
    required String pw,
  }) async {
    Map<String, String> data = {'login': login, 'password': pw};

    String body = json.encode(data);

    String url = Platform.isAndroid ? "http://10.0.2.2:8080/api" : "http://localhost:8080/api";

    try {
      final response = await http.post(
        Uri.parse('$url/auth/login'),
        body: body,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final usuario = data['loginName'];
        final userRole = data['role'];
        final token = data['token'];
        final id = data['id'];

        Prefs.setString("loginName", usuario);
        Prefs.setString("role", userRole.toString());
        Prefs.setString("token", token);
        Prefs.setString("id", id);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Login efetuado com sucesso")),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Home()),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Usuário ou senha inválidos"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Erro ao efetuar login, tente novamente mais tarde"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
