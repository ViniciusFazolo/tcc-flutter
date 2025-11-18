import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:tcc_flutter/pages/login.dart';
import 'package:tcc_flutter/utils/utils.dart';

class RegisterController {
  final nome = TextEditingController();
  final email = TextEditingController();
  final pw = TextEditingController();
  final confirmPw = TextEditingController();
  File? image;

  Future<void> register(
    BuildContext context,
    GlobalKey<FormState> formKey,
  ) async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    if (pw.text != confirmPw.text) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Erro"),
            content: Text("As senhas devem coincidir"),
            actions: <Widget>[
              TextButton(
                child: Text("Fechar"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );

      return;
    }

    final url = Uri.parse("$apiBaseUrl/auth/register");

    // Cria a requisição multipart
    var request = http.MultipartRequest('POST', url);

    // Adiciona os campos de texto
    request.fields['name'] = nome.text;
    request.fields['login'] = email.text;
    request.fields['password'] = pw.text;

    // Adiciona a imagem se existir
    if (image != null) {
      var stream = http.ByteStream(image!.openRead());
      var length = await image!.length();

      var multipartFile = http.MultipartFile(
        'image', // nome do campo esperado pelo Spring
        stream,
        length,
        filename: image!.path.split('/').last,
      );

      request.files.add(multipartFile);
    }

    try {
      // Envia a requisição
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Sucesso
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Sucesso"),
              content: Text("Cadastro realizado com sucesso!"),
              actions: <Widget>[
                TextButton(
                  child: Text("OK"),
                  onPressed: () {
                    Navigator.of(context).pop();

                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => Login()),
                      (route) => false,
                    );
                  },
                ),
              ],
            );
          },
        );
      } else {
        final data = jsonDecode(response.body);

        // Erro
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Erro"),
              content: Text(data['message'] ?? "Erro ao realizar cadastro"),
              actions: <Widget>[
                TextButton(
                  child: Text("Fechar"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Erro"),
            content: Text("Erro de conexão: $e"),
            actions: <Widget>[
              TextButton(
                child: Text("Fechar"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }
}
