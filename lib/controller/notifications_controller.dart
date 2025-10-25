import 'package:flutter/material.dart';
import 'package:tcc_flutter/domain/group_invite.dart';
import 'package:tcc_flutter/service/group_invite_service.dart';
import 'package:tcc_flutter/utils/prefs.dart';
import 'package:tcc_flutter/utils/utils.dart';

class NotificationsController {
  final GroupInviteService service = GroupInviteService(
    baseUrl: "$apiBaseUrl/group/invite",
  );

  Future<List<GroupInvite>> getInvitesByUserId() async {
    final userId = await Prefs.getString("id");
    return await service.getList("pending/user/$userId");
  }

  Future<void> acceptInvite(String inviteId, BuildContext context) async {
    final res = await service.respondeInvite(inviteId, true);

    if (res) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Convite aceito')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao aceitar convite, tente novamente'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> declineInvite(String inviteId, BuildContext context) async {
    final res = await service.respondeInvite(inviteId, false);

    if (res) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Convite recusado')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao recusar convite, tente novamente'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
