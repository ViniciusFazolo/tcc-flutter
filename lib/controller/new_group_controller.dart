import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tcc_flutter/pages/group_details.dart';
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
      final res = await groupService.postMultipart(
        "group",
        {"name": nameController.text, "adm": userId},
        file: image,
        fileField: "image",
      );

      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => GroupDetails(id: res.id!)),
        );
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
