import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tcc_flutter/service/group_service.dart';
import 'package:tcc_flutter/utils/prefs.dart';
import 'package:tcc_flutter/utils/utils.dart';

class NewGroupController {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  File? image;

  submit(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;

    String userId = await Prefs.getString("id");
    final groupService = GroupService(baseUrl: apiBaseUrl);

    try {
      await groupService.postMultipart(
        "group",
        {"name": nameController.text, "adm": userId},
        file: image,
        fileField: "image",
      );

      if (context.mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Erro ao criar grupo"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
