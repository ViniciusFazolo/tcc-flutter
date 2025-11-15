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
    setState(() {});
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
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.group_add),
        onPressed: () async {
          final wasCreated = await controller.goToNewGroup(context);

          if (wasCreated) {
            await controller.fetchGroupsByUserId();
            setState(() {});
          }
        },
      ),
      body: Container(
        color: Colors.grey[100],
        width: double.infinity,
        padding: const EdgeInsets.all(8),
        child: controller.groups.isEmpty
            ? const Center(
                child: Text(
                  'Nenhum grupo encontrado',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
            : SizedBox(
                height: double.infinity,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: controller.groups
                        .map(
                          (group) => GroupCard(
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
                            onTap: () {
                              if (group.userGroups![0].totalNotifies > 0) {
                                controller.resetGroupNotify(context, group.id!);
                              }
                              controller.goToGroupById(context, group.id!);
                            },
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
      ),
    );
  }
}
