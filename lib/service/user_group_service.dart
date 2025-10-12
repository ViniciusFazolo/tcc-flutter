import 'package:tcc_flutter/domain/user_group.dart';
import 'package:tcc_flutter/service/crud_service.dart';
import 'package:http/http.dart' as http;
import 'package:tcc_flutter/utils/prefs.dart';

class UserGroupService extends CrudService {
  UserGroupService({required super.baseUrl})
    : super(fromJson: UserGroup.fromJson);

  Future<void> resetNotify(String groupId, String userId) async {
    final token = await Prefs.getString("token");
    final url = Uri.parse(
      baseUrl,
    ).replace(queryParameters: {"groupId": groupId, "userId": userId});
    final headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };

    await http.get(url, headers: headers);
  }
}
