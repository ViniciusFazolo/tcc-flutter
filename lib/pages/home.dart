import 'package:flutter/material.dart';
import 'package:tcc_flutter/controller/home_controller.dart';
import 'package:tcc_flutter/domain/group_invite.dart';
import 'package:tcc_flutter/utils/widget/custom_popup_menu.dart';
import 'package:tcc_flutter/utils/widget/group_card.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final HomeController controller = HomeController();
  List<GroupInvite> notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getGroups();
    getGroupInvites();
  }

  getGroupInvites() async {
    notifications = await controller.getGroupInvites();
    setState(() {});
  }

  getGroups() async {
    await controller.fetchGroupsByUserId();
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Recordando momentos"),
        actions: [
          Row(
            children: [
              Stack(
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.notifications_none, size: 25),
                    onPressed: () async {
                      final hasChanges = await controller.goToNotifications(
                        context,
                      );

                      if (hasChanges == true) {
                        getGroups();
                        getGroupInvites();
                      }
                    },
                  ),
                  if (notifications.isNotEmpty)
                    Positioned(
                      right: 3,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          '${notifications.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              CustomPopupMenu(
                items: [
                  PopupMenuItemData(
                    value: 'logout',
                    label: 'Sair',
                    icon: Icons.logout,
                    onTap: () {
                      controller.logout(context);
                    },
                  ),
                ],
              ),
              SizedBox(width: 8),
            ],
          ),
        ],
      ),
      floatingActionButton: controller.groups.isNotEmpty
          ? FloatingActionButton(
              child: Icon(Icons.group_add),
              onPressed: () async {
                final wasCreated = await controller.goToNewGroup(context);

                if (wasCreated) {
                  await controller.fetchGroupsByUserId();
                  setState(() {});
                }
              },
            )
          : null,
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Container(
              color: Colors.grey[100],
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              child: controller.groups.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: () async {
                        await getGroups();
                      },
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: controller.groups.length,
                        separatorBuilder: (context, index) => const Divider(
                          height: 1,
                          indent: 88,
                          thickness: 0.5,
                        ),
                        itemBuilder: (context, index) {
                          final group = controller.groups[index];
                          return GroupCard(
                            imageUrl: group.image!,
                            groupName: group.name!,
                            timeLastPublish: controller.formatHour(
                              group.userGroups?.isNotEmpty == true
                                  ? group.userGroups![0].hourLastPublish
                                  : null,
                            ),
                            notifications:
                                (group.userGroups != null &&
                                    group.userGroups!.isNotEmpty)
                                ? group.userGroups![0].totalNotifies
                                : 0,
                            onTap: () async {
                              if (group.userGroups![0].totalNotifies > 0) {
                                await controller.resetGroupNotify(
                                  context,
                                  group.id!,
                                );

                                // Atualiza localmente o contador para 0
                                setState(() {
                                  group.userGroups![0].totalNotifies = 0;
                                  // group.userGroups![0].hourLastPublish = "";
                                });
                              }
                              controller.goToGroupById(context, group.id!);
                            },
                          );
                        },
                      ),
                    ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.groups_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Nenhum grupo ainda',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Crie um novo grupo para começar',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () async {
              final wasCreated = await controller.goToNewGroup(context);
              if (wasCreated) {
                await controller.fetchGroupsByUserId();
                setState(() {});
              }
            },
            icon: const Icon(Icons.add_rounded),
            label: const Text('Criar grupo'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
