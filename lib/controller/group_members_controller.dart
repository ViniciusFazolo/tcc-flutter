import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tcc_flutter/domain/group_invite.dart';
import 'package:tcc_flutter/domain/user.dart';
import 'package:tcc_flutter/service/user_service.dart';
import 'package:tcc_flutter/utils/utils.dart';
import 'package:http/http.dart' as http;

class GroupMembersController {
  List<User> people = [];
  final UserService userService = UserService(baseUrl: apiBaseUrl);

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
}
