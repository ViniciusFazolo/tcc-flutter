import 'dart:convert';

import 'package:flutter/material.dart';
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
    try {
      final headers = {'Content-Type': 'application/json'};
      final body = jsonEncode({
        "groupId": groupId,
        "senderId": senderId,
        "receiverLogin": receiverLogin,
      });
      final url = Uri.parse("$apiBaseUrl/group/invite");

      await http.post(url, body: body, headers: headers);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Convite enviado com sucesso")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Erro ao enviar convite"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
