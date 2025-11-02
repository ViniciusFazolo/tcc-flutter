import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tcc_flutter/domain/group_invite.dart';
import 'package:tcc_flutter/domain/user.dart';
import 'package:tcc_flutter/domain/user_group.dart';
import 'package:tcc_flutter/service/user_group_service.dart';
import 'package:tcc_flutter/service/user_service.dart';
import 'package:tcc_flutter/utils/prefs.dart';
import 'package:tcc_flutter/utils/utils.dart';
import 'package:http/http.dart' as http;

class GroupMembersController {
  List<User> people = [];
  final UserService userService = UserService(baseUrl: apiBaseUrl);
  final UserGroupService userGroupService = UserGroupService(
    baseUrl: apiBaseUrl,
  );

  Future<void> findPeopleByGroupId(String groupId) async {
    try {
      people = await userService.getList("user/byGroupId/$groupId");
      print('Membros carregados: ${people.length}');
    } catch (e) {
      print('Erro no controller ao buscar membros: $e');
      people = [];
      rethrow; // Repassa o erro para ser tratado na UI
    }
  }

  Future<void> sendInvite(
    String groupId,
    String senderId,
    String receiverLogin,
    BuildContext context,
  ) async {
    final bool receiverExists = await userService.findByLogin(receiverLogin);

    if (!receiverExists) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Este usuário não existe"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final headers = {'Content-Type': 'application/json'};
      final body = jsonEncode({
        "groupId": groupId,
        "senderId": senderId,
        "receiverLogin": receiverLogin,
      });
      final url = Uri.parse("$apiBaseUrl/group/invite");

      final res = await http.post(url, body: body, headers: headers);

      if (res.statusCode == 200) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Convite enviado com sucesso")),
        );
      } else {
        final data = jsonDecode(res.body);

        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? "Erro ao enviar convite"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Erro ao enviar convite"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<List<GroupInvite>> getPendingInvite(
    String groupId,
    BuildContext context,
  ) async {
    try {
      final url = Uri.parse("$apiBaseUrl/group/invite/pending/$groupId");
      final res = await http.get(url);

      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);

        // Converte cada item da lista JSON em um objeto GroupInvite
        final invites = data.map((item) => GroupInvite.fromJson(item)).toList();

        return invites;
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Erro ao resgatar convites pendentes"),
          backgroundColor: Colors.red,
        ),
      );
    }

    return [];
  }

  Future<bool> isUserAdm(List<UserGroup> userGroup) async {
    final userId = await Prefs.getString("id");

    for (var ug in userGroup) {
      String? ugUserId = ug.user?.id;

      if (ugUserId == userId) {
        if (ug.adm!) return true;

        return false;
      }
    }

    return false;
  }

  Future<bool> promoteToAdmin(
    User user,
    String groupId,
    BuildContext context,
  ) async {
    final res = await userGroupService.promoteToAdmin(groupId, user.id!);
    final String name = user.name!;

    Navigator.pop(context);

    if (res.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$name foi promovido a admin do grupo")),
      );

      return true;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erro ao promover $name a admin do grupo, tente novamente"),
          backgroundColor: Colors.red,
        ),
      );

      return false;
    }
  }
  
  Future<bool> removeFromAdminList(
    User user,
    String groupId,
    BuildContext context,
  ) async {
    final res = await userGroupService.removeFromAdminList(groupId, user.id!);
    final String name = user.name!;

    Navigator.pop(context);

    if (res.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$name foi removido da lista de admins do grupo")),
      );

      return true;
    } else {
      final data = jsonDecode(res.body);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(data["message"] ?? "Erro ao remover $name da lista de admins do grupo, tente novamente"),
          backgroundColor: Colors.red,
        ),
      );

      return false;
    }
  }

  Future<bool> removeFromGroup(
    User user,
    String groupId,
    BuildContext context,
  ) async {
    final res = await userGroupService.removeFromGroup(groupId, user.id!);
    final String name = user.name!;

    Navigator.pop(context);

    if (res.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$name foi removido do grupo")),
      );

      return true;
    } else {
      final data = jsonDecode(res.body);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(data["message"] ?? "Erro ao remover $name do grupo, tente novamente"),
          backgroundColor: Colors.red,
        ),
      );

      return false;
    }
  }
}
