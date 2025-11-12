import 'package:flutter/material.dart';
import 'package:tcc_flutter/controller/login_controller.dart';
import 'package:tcc_flutter/pages/register.dart';
import 'package:tcc_flutter/utils/widget/button.dart';
import 'package:tcc_flutter/utils/widget/input.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  LoginController loginController = LoginController();
  final loginTextControler = TextEditingController();
  final pwTextController = TextEditingController();

  goToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Register()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Form(
            key: _formKey,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              child: Column(
                spacing: 8,
                children: [
                  Image.asset(
                    'assets/logos/logo.png',
                    width: 200,
                    height: 200,
                    fit: BoxFit.contain,
                  ),
                  Input(label: "Login", controller: loginTextControler),
                  Input(
                    label: "Senha",
                    controller: pwTextController,
                    obscureText: true,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: Button(label: "Login", onPressed: onPressedLogin),
                  ),
                ],
              ),
            ),
          ),
          InkWell(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Text("Cadastre-se"),
            ),
            onTap: () {
              goToRegister();
            },
          ),
        ],
      ),
    );
  }

  onPressedLogin() {
    if (!_formKey.currentState!.validate()) return;

    loginController.login(
      context,
      login: loginTextControler.text,
      pw: pwTextController.text,
    );
  }
}
