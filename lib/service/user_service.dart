import 'dart:convert';
import 'dart:io';

import 'package:tcc_flutter/domain/user.dart';
import 'package:tcc_flutter/service/crud_service.dart';
import 'package:http/http.dart' as http;
import 'package:tcc_flutter/utils/utils.dart';

class UserService extends CrudService<User> {
  UserService({required super.baseUrl}) : super(fromJson: User.fromJson);

  Future<bool> findByLogin(String login) async {
    Uri url = Uri.parse("$apiBaseUrl/user/existsByLogin/$login");

    final res = await http.get(url);

    if (res.statusCode == 200) {
      bool value = jsonDecode(res.body) as bool;
      return value;
    } else {
      return false;
    }
  }

  Future<bool> updateUser({
    required String id,
    required String name,
    required String email,
    required String password,
    required String roleId,
    File? image, // opcional
  }) async {
    final uri = Uri.parse("$apiBaseUrl/user");

    var request = http.MultipartRequest("PUT", uri);

    // Campos normais
    request.fields["id"] = id;
    request.fields["name"] = name;
    request.fields["login"] = email;
    request.fields["roleId"] = roleId;

    // Envia senha somente se alterada
    if (password.isNotEmpty) {
      request.fields["password"] = password;
    }

    // Arquivo opcional
    if (image != null) {
      request.files.add(await http.MultipartFile.fromPath("image", image.path));
    }

    final res = await request.send();

    if (res.statusCode != 200) {
      final responseFromStream = await http.Response.fromStream(res);
      final data = jsonDecode(responseFromStream.body);

      throw Exception(data['message']);
    } else {
      return true;
    }
  }
}
