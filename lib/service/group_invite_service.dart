import 'package:tcc_flutter/domain/group_invite.dart';
import 'package:tcc_flutter/service/crud_service.dart';
import 'package:http/http.dart' as http;
import 'package:tcc_flutter/utils/utils.dart';

class GroupInviteService extends CrudService<GroupInvite> {
  GroupInviteService({required super.baseUrl})
    : super(fromJson: GroupInvite.fromJson);

  Future<bool> respondeInvite(String inviteId, bool status) async {
    final url = Uri.parse(
      "$apiBaseUrl/group/invite/$inviteId/respond",
    ).replace(queryParameters: {'accept': status.toString()});

    final res = await http.post(url);

    if (res.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }
}
