import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tcc_flutter/domain/group.dart';
import 'package:tcc_flutter/pages/group_details.dart';
import 'package:tcc_flutter/pages/login.dart';
import 'package:tcc_flutter/pages/new_group.dart';
import 'package:tcc_flutter/service/group_service.dart';
import 'package:tcc_flutter/service/user_group_service.dart';
import 'package:tcc_flutter/utils/prefs.dart';
import 'package:tcc_flutter/utils/utils.dart';

class HomeController {
  List<Group> groups = [];

  Future<void> fetchGroupsByUserId() async {
    final userId = await Prefs.getString('id');
    final GroupService groupService = GroupService(
      baseUrl: "$apiBaseUrl/group",
    );

    final res = await groupService.getList("userId/$userId");

    if (res.isNotEmpty) {
      groups = res;
    }
  }

  goToGroupById(BuildContext context, String id) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GroupDetails(id: id)),
    );
  }

  Future<void> resetGroupNotify(BuildContext context, String groupId) async {
    final UserGroupService service = UserGroupService(
      baseUrl: "$apiBaseUrl/userGroup",
    );

    final userId = await Prefs.getString("id");

    await service.resetNotify(groupId, userId);
  }

  String? formatHour(String? hour) {
    if (hour == null) return null;
    try {
      final parsed = DateFormat("HH:mm:ss").parse(hour);
      return DateFormat("HH:mm").format(parsed);
    } catch (e) {
      debugPrint("Erro ao converter hora: $e | valor: $hour");
      return hour;
    }
  }

  Future<void> logout(BuildContext context) async {
    Prefs.setString("loginName", "");
    Prefs.setString("role", "");
    Prefs.setString("token", "");
    Prefs.setString("id", "");

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Login()),
    );
  }

  Future<void> goToNewGroup(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NewGroup()),
    );
  }
}
