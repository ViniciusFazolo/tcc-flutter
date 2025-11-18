import 'package:flutter/material.dart';
import 'package:tcc_flutter/controller/register_controller.dart';
import 'package:tcc_flutter/utils/widget/button.dart';
import 'package:tcc_flutter/utils/widget/input.dart';
import 'package:tcc_flutter/utils/widget/input_image.dart';
import 'package:tcc_flutter/utils/widget/loading_overlay.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();
  RegisterController controller = RegisterController();
  bool isLoadingRegister = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Registro")),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              child: Column(
                spacing: 8,
                children: [
                  InputImage(
                    onChanged: (image) {
                      controller.image = image;
                    },
                  ),
                  Input(label: "Nome", controller: controller.nome),
                  Input(
                    label: "E-mail",
                    controller: controller.email,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Campo obrigatório";
                      }
          
                      // Regex para validar email
                      final emailRegex = RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      );
          
                      if (!emailRegex.hasMatch(value)) {
                        return "Email inválido";
                      }
          
                      return null;
                    },
                  ),
                  Input(
                    label: "Senha",
                    controller: controller.pw,
                    obscureText: true,
                  ),
                  Input(
                    label: "Confirmar senha",
                    controller: controller.confirmPw,
                    obscureText: true,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: Button(
                      label: "Registrar",
                      onPressed: () async {
                        setState(() {
                          isLoadingRegister = true;
                        });
                        await controller.register(context, _formKey);
                        setState(() {
                          isLoadingRegister = false;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          LoadingOverlay(
            isLoading: isLoadingRegister,
            message: "Aguarde, sua conta já está sendo criada...",
          ),
        ],
      ),
    );
  }
}
