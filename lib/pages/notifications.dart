import 'package:flutter/material.dart';
import 'package:tcc_flutter/controller/notifications_controller.dart';
import 'package:tcc_flutter/domain/group_invite.dart';

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  final NotificationsController controller = NotificationsController();
  List<GroupInvite> invites = [];
  bool isLoading = true;
  bool hasChanges = false; // Flag para indicar se houve mudanças

  @override
  void initState() {
    super.initState();
    _getInvitesByUserId();
  }

  _getInvitesByUserId() async {
    setState(() {
      isLoading = true;
    });
    invites = await controller.getInvitesByUserId();
    setState(() {
      isLoading = false;
    });
  }

  void _handleAccept(GroupInvite invite) async {
    await controller.acceptInvite(invite.id!, context);

    setState(() {
      invites.remove(invite);
      hasChanges = true; // Marca que houve mudança
    });
  }

  void _handleDecline(GroupInvite invite) async {
    await controller.declineInvite(invite.id!, context);

    setState(() {
      invites.remove(invite);
      hasChanges = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, hasChanges);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(title: const Text("Notificações")),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : invites.isEmpty
            ? const Center(
                child: Text(
                  'Nenhuma notificação',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
            : ListView.builder(
                itemCount: invites.length,
                padding: const EdgeInsets.all(8),
                itemBuilder: (context, index) {
                  final invite = invites[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 4,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Convite para grupo',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            invite.groupName ?? 'Grupo sem nome',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Convidado por: ${invite.invitedBy?.name ?? 'Usuário desconhecido'}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () => _handleDecline(invite),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
                                child: const Text('Recusar'),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () => _handleAccept(invite),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Aceitar'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
