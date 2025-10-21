import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tcc_flutter/domain/publish.dart';
import 'package:tcc_flutter/service/crud_service.dart';
import 'package:http/http.dart' as http;
import 'package:tcc_flutter/utils/prefs.dart';

class PublishService extends CrudService<Publish> {
  PublishService({required super.baseUrl}) : super(fromJson: Publish.fromJson);

  submit({
    required String albumId,
    required String authorId,
    required List<XFile> imagens,
    String? description,
  }) async {
    final token = Prefs.getString("token");
    final uri = Uri.parse('$baseUrl/publish');
    final request = http.MultipartRequest('POST', uri);

    request.fields['album'] = albumId;
    request.fields['author'] = authorId;
    if (description != null) {
      request.fields['description'] = description;
    }

    // Arquivos (imagens)
    for (final imagem in imagens) {
      final file = File(imagem.path);
      final multipartFile = await http.MultipartFile.fromPath(
        'images',
        file.path,
      );
      request.files.add(multipartFile);
    }

    request.headers.addAll({'Authorization': 'Bearer $token'});

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return;
    } else {
      throw Exception(
        'Erro ao enviar publicação (status: ${response.statusCode}, corpo: ${response.body})',
      );
    }
  }
}
