import 'dart:convert';

import 'package:tcc_flutter/domain/commentary.dart';
import 'package:tcc_flutter/service/crud_service.dart';
import 'package:http/http.dart' as http;
import 'package:tcc_flutter/utils/utils.dart';

class CommentaryService extends CrudService<Commentary> {
  CommentaryService({required super.baseUrl})
    : super(fromJson: Commentary.fromJson);

  Future<List<Commentary>> getCommentaryByPublishId(String id) async {
    final url = Uri.parse("$apiBaseUrl/commentary/byPublishId/$id");

    final res = await http.get(url);

    if (res.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(res.body);
      return jsonList.map((json) => Commentary.fromJson(json)).toList();
    } else {
      return [];
    }
  }
}
