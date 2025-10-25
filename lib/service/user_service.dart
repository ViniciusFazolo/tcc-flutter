import 'dart:convert';

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
}
