import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tcc_flutter/controller/publish_controller.dart';
import 'package:tcc_flutter/utils/prefs.dart';
import 'package:tcc_flutter/utils/widget/custom_popup_menu.dart';
import 'package:tcc_flutter/utils/widget/loading_overlay.dart';

class Publish extends StatefulWidget {
  final String albumId;
  final bool isUserAdmin;
  const Publish({super.key, required this.albumId, required this.isUserAdmin});

  @override
  State<Publish> createState() => _PublishState();
}

class _PublishState extends State<Publish> {
  PublishController controller = PublishController();
  bool isLoading = true;
  bool isDeletingImage = false;
  String userIdLogged = "";

  @override
  void initState() {
    super.initState();
    controller.fetchPublishsByAlbumId(widget.albumId).then((_) {
      setState(() {
        isLoading = false;
      });
    });
    _loadUserId();
  }

  _loadUserId() async {
    userIdLogged = await Prefs.getString("id");
  }

  Future<void> _deleteImage(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text('Deseja realmente excluir esta publicação?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(foregroundColor: Colors.grey),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        isDeletingImage = true;
      });

      try {
        await controller.delete(id);

        await controller.fetchPublishsByAlbumId(widget.albumId);

        if (mounted) {
          setState(() {});
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Publicação excluída com sucesso')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao excluir publicação: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            isDeletingImage = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Fotos")),
      body: Stack(
        children: [
          controller.publishs.isNotEmpty
              ? SingleChildScrollView(
                  child: Container(
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        spacing: 10,
                        children: controller.publishs.map((pub) {
                          return Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              spacing: 10,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  spacing: 15,
                                  children: [
                                    CircleAvatar(
                                      backgroundImage: NetworkImage(
                                        pub.author!.image ?? "",
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            pub.author!.name!,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          Text(
                                            style: TextStyle(fontSize: 12),
                                            DateFormat(
                                              "dd/MM/yyyy HH:mm",
                                            ).format(
                                              DateTime.parse(pub.whenSent!),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (pub.author?.id! == userIdLogged ||
                                        widget.isUserAdmin)
                                      CustomPopupMenu(
                                        items: [
                                          PopupMenuItemData(
                                            value: 'excluir',
                                            label: 'Excluir',
                                            icon: Icons.delete,
                                            onTap: () => _deleteImage(pub.id!),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                                pub.description != null
                                    ? Text(pub.description!)
                                    : SizedBox(height: 0),
                                if (pub.images != null &&
                                    pub.images!.isNotEmpty)
                                  SizedBox(
                                    height: 200, // altura do carrossel
                                    width: double.infinity,
                                    child: PageView.builder(
                                      itemCount: pub.images!.length,
                                      itemBuilder: (context, index) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 2,
                                          ),
                                          child: Container(
                                            color: Colors.black87,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: Image.network(
                                                pub.images![index].image!,
                                                fit: BoxFit.contain,
                                                width: double.infinity,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                )
              : Center(
                  child: Text("Não há fotos", style: TextStyle(fontSize: 20)),
                ),
          LoadingOverlay(
            isLoading: isDeletingImage,
            message: "Excluindo publicação...",
          ),
        ],
      ),
    );
  }
}
