import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tcc_flutter/domain/user.dart';
import 'package:tcc_flutter/service/user_service.dart';
import 'package:tcc_flutter/utils/prefs.dart';
import 'package:tcc_flutter/utils/utils.dart';
import 'package:tcc_flutter/utils/widget/input.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:tcc_flutter/utils/widget/loading_overlay.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final UserService service = UserService(baseUrl: "$apiBaseUrl/user");
  User? user;
  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController pw = TextEditingController();
  final formKey = GlobalKey<FormState>();

  bool hasChanges = false;
  bool formSubmitted = false;
  String originalName = "";
  String originalEmail = "";

  // Adicione esta variável para a imagem
  File? selectedProfileImage;

  @override
  void initState() {
    super.initState();
    _loadUser();

    name.addListener(_checkChanges);
    email.addListener(_checkChanges);
    pw.addListener(_checkChanges);
  }

  _loadUser() async {
    final userlogged = await Prefs.getString("id");

    User res = await service.getItem(userlogged);
    user = res;

    originalName = res.name ?? "";
    originalEmail = res.login ?? "";

    name.text = originalName;
    email.text = originalEmail;

    setState(() {});
  }

  _editUser() async {
    if (!formKey.currentState!.validate()) return;

    setState(() {
      formSubmitted = true;
    });

    try {
      await service.updateUser(
        id: user?.id ?? "",
        name: name.text,
        email: email.text,
        password: pw.text,
        roleId: user?.role?.id ?? "",
        image: selectedProfileImage,
      );

      final login = email.text != user?.login ? email.text : user?.login;
      Uri url = Uri.parse("$apiBaseUrl/auth/newToken/$login");

      final res = await http.get(url);

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        final usuario = data['loginName'];
        final userRole = data['role'];
        final token = data['token'];
        final id = data['id'];

        Prefs.setString("loginName", usuario);
        Prefs.setString("role", userRole.toString());
        Prefs.setString("token", token);
        Prefs.setString("id", id);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Dados atualizados com sucesso")),
        );
      }

      if (pw.text.isNotEmpty) {
        pw.text = "";
      }

      setState(() {
        hasChanges = false;
      });
    } catch (e) {
      if (mounted) {
        String errorMessage = e.toString().replaceFirst('Exception: ', '');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() {
        formSubmitted = false;
      });
    }
  }

  void _checkChanges() {
    final bool changed =
        name.text != originalName ||
        email.text != originalEmail ||
        pw.text.isNotEmpty ||
        selectedProfileImage != null;

    if (changed != hasChanges) {
      setState(() {
        hasChanges = changed;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Perfil")),
      body: Stack(
        children: [
          GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    spacing: 10,
                    children: [
                      // Avatar circular com InputImage oculto
                      GestureDetector(
                        onTap: () async {
                          // Simula o clique no InputImage
                          final picker = ImagePicker();
                          final picked = await picker.pickImage(
                            source: ImageSource.gallery,
                            imageQuality: 80,
                          );
                          if (picked != null) {
                            setState(() {
                              selectedProfileImage = File(picked.path);
                            });
                            _checkChanges();
                          }
                        },
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // CircleAvatar visível
                            CircleAvatar(
                              radius: 80,
                              backgroundColor: Colors.grey.shade300,
                              backgroundImage: selectedProfileImage != null
                                  ? FileImage(selectedProfileImage!)
                                        as ImageProvider
                                  : (user?.image != null &&
                                            user!.image!.isNotEmpty
                                        ? NetworkImage(user!.image!)
                                        : null),
                              child:
                                  (selectedProfileImage == null &&
                                      (user?.image == null ||
                                          user!.image!.isEmpty))
                                  ? Icon(
                                      Icons.person,
                                      size: 80,
                                      color: Colors.grey.shade600,
                                    )
                                  : null,
                            ),

                            // Botão de câmera
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: Icon(
                                  Icons.camera_alt,
                                  size: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 10),
                      Input(label: "Nome", controller: name),
                      Input(
                        label: "E-mail",
                        controller: email,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Campo obrigatório";
                          }

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
                        label: "Nova senha",
                        obscureText: true,
                        controller: pw,
                        requiredField: false,
                      ),
                      SizedBox(height: 20),

                      if (hasChanges)
                        ElevatedButton(
                          onPressed: () {
                            _editUser();
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(double.infinity, 50),
                          ),
                          child: Text("Salvar alterações"),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          LoadingOverlay(
            isLoading: formSubmitted,
            message: "Atualizando os dados...",
          ),
        ],
      ),
    );
  }
}
