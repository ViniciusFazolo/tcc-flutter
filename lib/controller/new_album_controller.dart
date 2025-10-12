import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tcc_flutter/service/album_service.dart';
import 'package:tcc_flutter/utils/utils.dart';

class NewAlbumController {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  File? image;

  submit(BuildContext context, String groupId) async {
    if (!formKey.currentState!.validate()) return;

    final service = AlbumService(baseUrl: apiBaseUrl);

    try {
      await service.postMultipart(
        "album",
        {"name": nameController.text, "group": groupId},
        file: image,
        fileField: "image",
      );

      if (context.mounted) {
        Navigator.pop(context);
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