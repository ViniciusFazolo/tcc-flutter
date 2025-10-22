import 'package:flutter/material.dart';
import 'package:tcc_flutter/controller/group_details_controller.dart';
import 'package:tcc_flutter/pages/camera.dart';
import 'package:tcc_flutter/utils/widget/album_card.dart';
import 'package:tcc_flutter/utils/widget/custom_popup_menu.dart';

class GroupDetails extends StatefulWidget {
  final String id;
  const GroupDetails({super.key, required this.id});

  @override
  State<GroupDetails> createState() => _GroupDetailsState();
}

class _GroupDetailsState extends State<GroupDetails> {
  final GroupDetailsController controller = GroupDetailsController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGroup();
  }

  Future<void> _loadGroup() async {
    await controller.fetchGroupById(widget.id);
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(controller.group.image ?? ''),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                controller.group.name ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        actions: [
          Row(
            children: [
              CustomPopupMenu(
                items: [
                  PopupMenuItemData(
                    value: 'new_album',
                    label: 'Novo álbum',
                    icon: Icons.photo_album_outlined,
                    onTap: () async {
                      await controller.goToNewAlbum(context, widget.id);
                      await controller.fetchAlbumsByGroupId(widget.id).then((
                        _,
                      ) {
                        setState(() {});
                      });
                    },
                  ),
                  PopupMenuItemData(
                    value: 'membros',
                    label: 'Membros',
                    icon: Icons.people,
                    onTap: () async {
                      await controller.goToGroupMembers(context, widget.id);
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
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Camera(albums: controller.albums),
            ),
          );
        },
        child: Icon(Icons.camera_alt),
      ),
      body: controller.albums.isNotEmpty
          ? SingleChildScrollView(
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: controller.albums.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.8,
                ),
                itemBuilder: (context, index) {
                  final album = controller.albums[index];
                  return AlbumCard(
                    album: album,
                    onTap: () {
                      controller.goToAlbumDetails(context, album.id!);
                    },
                  );
                },
              ),
            )
          : Center(
              child: Text("Não há álbuns", style: TextStyle(fontSize: 20)),
            ),
    );
  }
}
