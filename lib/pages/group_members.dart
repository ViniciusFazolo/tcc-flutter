import 'package:flutter/material.dart';
import 'package:tcc_flutter/controller/group_members_controller.dart';
import 'package:tcc_flutter/domain/group.dart';
import 'package:tcc_flutter/domain/group_invite.dart';
import 'package:tcc_flutter/domain/user.dart';
import 'package:tcc_flutter/domain/user_group.dart';
import 'package:tcc_flutter/utils/prefs.dart';
import 'package:tcc_flutter/utils/widget/input.dart';

class GroupMembers extends StatefulWidget {
  final Group group;
  final User admin;
  final bool isUserAdmin;
  const GroupMembers({super.key, required this.group, required this.admin, required this.isUserAdmin});

  @override
  State<GroupMembers> createState() => _GroupMembersState();
}

class _GroupMembersState extends State<GroupMembers> {
  final GroupMembersController controller = GroupMembersController();
  bool isLoading = true;
  String? errorMessage;
  List<GroupInvite> pendingInvites = [];
  String userIdLogged = "";

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final invites = await controller.getPendingInvite(
        widget.group.id!,
        context,
      );
      userIdLogged = await Prefs.getString("id");

      if (mounted) {
        setState(() {
          pendingInvites = invites;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          errorMessage = 'Erro ao carregar dados: $e';
        });
      }
    }
  }

  Future<void> _promoteToAdmin(User user) async {
    final success = await controller.promoteToAdmin(
      user,
      widget.group.id!,
      context,
    );

    if (success) {
      setState(() {
        if (widget.group.userGroups != null) {
          final index = widget.group.userGroups!.indexWhere(
            (ug) => ug.user?.id == user.id,
          );
          if (index != -1) {
            widget.group.userGroups![index].adm = true;
          }
        }
      });
    }
  }

  Future<void> _removeFromAdminList(User user) async {
    final success = await controller.removeFromAdminList(
      user,
      widget.group.id!,
      context,
    );

    if (success) {
      setState(() {
        if (widget.group.userGroups != null) {
          final index = widget.group.userGroups!.indexWhere(
            (ug) => ug.user?.id == user.id,
          );
          if (index != -1) {
            widget.group.userGroups![index].adm = false;
          }
        }
      });
    }
  }

  Future<void> _removeFromGroup(User user) async {
    final success = await controller.removeFromGroup(
      user,
      widget.group.id!,
      context,
    );

    if (success) {
      setState(() {
        if (widget.group.userGroups != null) {
          final index = widget.group.userGroups!.indexWhere(
            (ug) => ug.user?.id == user.id,
          );
          if (index != -1) {
            widget.group.userGroups!.removeAt(index);
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Membros")),
      floatingActionButton: widget.isUserAdmin
          ? FloatingActionButton(
              child: Icon(Icons.person_add),
              onPressed: () {
                _openDialog(context);
              },
            )
          : null,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isLoading = true;
                        errorMessage = null;
                      });
                      _loadData();
                    },
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            )
          : _buildMembersList(),
    );
  }

  Widget _buildMembersList() {
    return ListView(
      children: [
        // Lista de convites pendentes
        if (pendingInvites.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Convites Pendentes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          ...pendingInvites.map((invite) => _buildPendingInviteItem(invite)),
          const Divider(thickness: 1, height: 32),
        ],

        // Lista de membros
        if (widget.group.userGroups?.isEmpty ?? true)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Text(
                "Nenhum membro encontrado",
                style: TextStyle(fontSize: 16),
              ),
            ),
          )
        else if (widget.group.userGroups != null)
          ...widget.group.userGroups!.map((member) => _buildMemberItem(member)),
      ],
    );
  }

  Widget _buildPendingInviteItem(GroupInvite invite) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.orange[300],
        backgroundImage:
            invite.invitedUser!.image != null &&
                invite.invitedUser!.image!.isNotEmpty
            ? NetworkImage(invite.invitedUser!.image!)
            : null,
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              invite.invitedUser!.login ?? 'Sem identificação',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
      subtitle: Text(
        'Aguardando aceite',
        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
      ),
    );
  }

  Widget _buildMemberItem(UserGroup userGroup) {
    return GestureDetector(
      onTap: () async {
        final String userIdLogged = await Prefs.getString("id");
        if (widget.isUserAdmin && userIdLogged != userGroup.user?.id) {
          _showMemberOptions(userGroup);
        }
      },
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor,
          backgroundImage:
              userGroup.user?.image != null && userGroup.user!.image!.isNotEmpty
              ? NetworkImage(userGroup.user!.image!)
              : null,
          child: userGroup.user?.image == null || userGroup.user!.image!.isEmpty
              ? Text(
                  userGroup.user?.name != null &&
                          userGroup.user!.name!.isNotEmpty
                      ? userGroup.user!.name![0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                userGroup.user?.name ?? 'Sem nome',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            if (userGroup.adm ?? false)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  "ADMIN",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _openDialog(BuildContext context) {
    final TextEditingController emailController = TextEditingController();

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 60, left: 20, right: 20),
            child: Material(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Adicionar Membro',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Input(label: "E-mail", controller: emailController),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('Cancelar'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () async {
                              final email = emailController.text.trim();
                              if (email.isNotEmpty) {
                                await controller.sendInvite(
                                  widget.group.id!,
                                  widget.admin.id!,
                                  email,
                                  context,
                                );

                                // Atualiza a lista de convites pendentes
                                final invites = await controller
                                    .getPendingInvite(
                                      widget.group.id!,
                                      context,
                                    );

                                if (mounted) {
                                  setState(() {
                                    pendingInvites = invites;
                                  });
                                }
                              } else {
                                final overlay = Overlay.of(context);
                                final overlayEntry = OverlayEntry(
                                  builder: (context) => Positioned(
                                    bottom: 20,
                                    left: 20,
                                    right: 20,
                                    child: Material(
                                      elevation: 6,
                                      borderRadius: BorderRadius.circular(4),
                                      color: Colors.red,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 14,
                                        ),
                                        child: const Text(
                                          'Por favor, digite um email válido',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                                overlay.insert(overlayEntry);
                                Future.delayed(const Duration(seconds: 2), () {
                                  overlayEntry.remove();
                                });
                              }
                            },
                            child: const Text('Adicionar'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -1),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
          child: child,
        );
      },
    );
  }

  void _showMemberOptions(UserGroup userGroup) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                spacing: 10,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Theme.of(context).primaryColor,
                    backgroundImage:
                        userGroup.user?.image != null &&
                            userGroup.user!.image!.isNotEmpty
                        ? NetworkImage(userGroup.user!.image!)
                        : null,
                    child:
                        userGroup.user?.image == null ||
                            userGroup.user!.image!.isEmpty
                        ? Text(
                            userGroup.user?.name != null &&
                                    userGroup.user!.name!.isNotEmpty
                                ? userGroup.user!.name![0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 30,
                            ),
                          )
                        : null,
                  ),
                  Text(
                    userGroup.user?.name ?? "",
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),

              SizedBox(height: 10),

              if (!userGroup.adm!)
                InkWell(
                  onTap: () async {
                    await _promoteToAdmin(userGroup.user!);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.add_moderator_outlined),
                        SizedBox(width: 10),
                        Text(
                          "Promover a admin do grupo",
                          style: TextStyle(fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                ),

              Divider(color: Colors.grey[300]),

              if (userGroup.adm!)
                InkWell(
                  onTap: () async {
                    await _removeFromAdminList(userGroup.user!);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.person_remove_alt_1_outlined,
                          color: Colors.red,
                        ),
                        SizedBox(width: 10),
                        Text(
                          "Remover da lista de admins",
                          style: TextStyle(fontSize: 15, color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ),

              InkWell(
                onTap: () async {
                  await _removeFromGroup(userGroup.user!);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.remove_circle_outline, color: Colors.red),
                      SizedBox(width: 10),
                      Text(
                        "Remover do grupo",
                        style: TextStyle(fontSize: 15, color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }
}
