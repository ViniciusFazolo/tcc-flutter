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
  final LoginController loginController = LoginController();
  final loginTextControler = TextEditingController();
  final pwTextController = TextEditingController();
  bool isLoading = false;

  goToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Register()),
    );
  }

  @override
  void dispose() {
    loginTextControler.dispose();
    pwTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Form(
            key: _formKey,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              child: Column(
                spacing: 8,
                children: [
                  Image.asset(
                    'assets/logos/logo.png',
                    width: 200,
                    height: 200,
                    fit: BoxFit.contain,
                  ),
                  Input(
                    label: "Login",
                    controller: loginTextControler,
                    
                    enabled: !isLoading,
                  ),
                  Input(
                    label: "Senha",
                    controller: pwTextController,
                    obscureText: true,
                    enabled: !isLoading,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: isLoading
                        ? ElevatedButton(
                            onPressed: null,
                            child: const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            ),
                          )
                        : Button(
                            label: "Login",
                            onPressed: onPressedLogin,
                          ),
                  ),
                ],
              ),
            ),
          ),
          InkWell(
            onTap: isLoading ? null : goToRegister,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                "Cadastre-se",
                style: TextStyle(
                  color: isLoading ? Colors.grey : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> onPressedLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    try {
      await loginController.login(
        context,
        login: loginTextControler.text,
        pw: pwTextController.text,
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
}