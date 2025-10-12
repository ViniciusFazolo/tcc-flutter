import 'package:flutter/material.dart';
import 'package:tcc_flutter/controller/home_controller.dart';
import 'package:tcc_flutter/utils/widget/custom_popup_menu.dart';
import 'package:tcc_flutter/utils/widget/group_card.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final HomeController controller = HomeController();

  @override
  void initState() {
    super.initState();
    controller.fetchGroupsByUserId().then((_) {
      setState(() {});
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
              IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.notifications_none, size: 25),
                onPressed: () {},
              ),
              CustomPopupMenu(
                items: [
                  PopupMenuItemData(
                    value: 'config',
                    label: 'Novo grupo',
                    icon: Icons.group_add,
                    onTap: () {
                      controller.goToNewGroup(context);
                    },
                  ),
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
      body: Container(
        color: Colors.grey[100],
        width: double.infinity,
        padding: const EdgeInsets.all(8),
        child: controller.groups.isEmpty
            ? const Center(
                child: Text(
                  "Nenhum grupo encontrado",
                  style: TextStyle(fontSize: 20),
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
