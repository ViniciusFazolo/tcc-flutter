import 'dart:convert';
import 'dart:io';

import 'package:tcc_flutter/domain/group.dart';
import 'package:tcc_flutter/service/crud_service.dart';
import 'package:http/http.dart' as http;

class GroupService extends CrudService<Group> {
  GroupService({required super.baseUrl}) : super(fromJson: Group.fromJson);

  Future<Group> postMultipart(String endpoint, Map<String, String> fields, {File? file, String fileField = 'file'}) async {
    var uri = Uri.parse('$baseUrl/$endpoint');
    var request = http.MultipartRequest('POST', uri);

    request.fields.addAll(fields);

    if (file != null) {
      request.files.add(
        await http.MultipartFile.fromPath(fileField, file.path),
      );
    }

    var streamedResponse = await request.send();

    // Converte o stream em um Response normal
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonData = jsonDecode(response.body);
      return Group.fromJson(jsonData);
    } else {
      throw Exception('Erro ao criar grupo: ${response.statusCode} - ${response.body}');
    }
  }
}
