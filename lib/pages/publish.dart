import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tcc_flutter/controller/publish_controller.dart';
import 'package:tcc_flutter/domain/commentary.dart';
import 'package:tcc_flutter/pages/image_viewer.dart';
import 'package:tcc_flutter/utils/prefs.dart';
import 'package:tcc_flutter/utils/widget/comment.dart';
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
  TextEditingController commentary = TextEditingController();
  List<Commentary> commentaries = [];

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

  void _openImageViewer(List<String> images, int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ImageViewer(images: images, initialIndex: initialIndex),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Fotos")),
      body: Stack(
        children: [
          controller.publishs.isNotEmpty
              ? SingleChildScrollView(
                  child: SizedBox(
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
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          Text(
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
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
                                if (pub.description != null &&
                                    pub.description!.isNotEmpty)
                                  Text(pub.description!),
                                if (pub.images != null &&
                                    pub.images!.isNotEmpty)
                                  SizedBox(
                                    height: 200,
                                    width: double.infinity,
                                    child: PageView.builder(
                                      itemCount: pub.images!.length,
                                      itemBuilder: (context, index) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 2,
                                          ),
                                          child: GestureDetector(
                                            onTap: () {
                                              final imageUrls = pub.images!
                                                  .map((img) => img.image!)
                                                  .toList();
                                              _openImageViewer(
                                                imageUrls,
                                                index,
                                              );
                                            },
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
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                GestureDetector(
                                  child: Row(
                                    spacing: 5,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.chat_bubble_outline_rounded,
                                        color: Colors.grey[700],
                                        size: 30,
                                      ),
                                      Text(
                                        pub.qtCommentary.toString(),
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                  onTap: () async {
                                    commentaries = await controller
                                        .loadingCommentaries(pub.id!);
                                    _openCommentaries(pub.id!);
                                  },
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                )
              : const Center(
                  child: Text(
                    'Nenhuma foto encontrada',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
          LoadingOverlay(
            isLoading: isDeletingImage,
            message: "Excluindo publicação...",
          ),
        ],
      ),
    );
  }

  _openCommentaries(String publishId) {
    final outerSetState = (VoidCallback fn) => setState(fn);

    return showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (context) {
        final primaryColor = Theme.of(context).colorScheme.primary;

        return StatefulBuilder(
          builder: (context, setState) {
            final canSend = commentary.text.trim().isNotEmpty;

            return GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: FractionallySizedBox(
                heightFactor: 0.8,
                child: Column(
                  children: [
                    // 1. CABEÇALHO - Título
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        "Comentários",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Divider(color: Colors.grey[300], height: 1),

                    // 2. MEIO - Lista de comentários
                    Expanded(
                      child: commentaries.isEmpty
                          ? Center(
                              child: Text(
                                "Nenhum comentário ainda.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              itemCount: commentaries.length,
                              itemBuilder: (context, index) {
                                final comment = commentaries[index];
                                return InkWell(
                                  onLongPress:
                                      widget.isUserAdmin ||
                                          comment.author.id == userIdLogged
                                      ? () async {
                                          final confirmed = await showDialog<bool>(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text(
                                                'Confirmar exclusão',
                                              ),
                                              content: const Text(
                                                'Deseja realmente excluir este comentário?',
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                        context,
                                                        false,
                                                      ),
                                                  style: TextButton.styleFrom(
                                                    foregroundColor:
                                                        Colors.grey,
                                                  ),
                                                  child: const Text('Cancelar'),
                                                ),
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                        context,
                                                        true,
                                                      ),
                                                  style: TextButton.styleFrom(
                                                    foregroundColor: Colors.red,
                                                  ),
                                                  child: const Text('Excluir'),
                                                ),
                                              ],
                                            ),
                                          );

                                          if (confirmed == true) {
                                            try {
                                              await controller.deleteCommentary(
                                                comment.id,
                                              );
                                              final cm = await controller
                                                  .loadingCommentaries(
                                                    publishId,
                                                  );

                                              commentaries = cm;

                                              final pubIndex = controller
                                                  .publishs
                                                  .indexWhere(
                                                    (p) => p.id == publishId,
                                                  );

                                              if (pubIndex != -1) {
                                                controller
                                                        .publishs[pubIndex]
                                                        .qtCommentary =
                                                    (controller
                                                            .publishs[pubIndex]
                                                            .qtCommentary ??
                                                        1) -
                                                    1;
                                              }

                                              outerSetState(() {});
                                              setState(() {});

                                              if (context.mounted) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'Comentário excluído com sucesso',
                                                    ),
                                                  ),
                                                );
                                              }
                                            } catch (e) {
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      'Erro ao excluir comentário: $e',
                                                    ),
                                                  ),
                                                );
                                              }
                                            }
                                          }
                                        }
                                      : null,
                                  child: Comment(
                                    userImage: comment.author.image ?? "",
                                    userName: comment.author.name!,
                                    comment: comment.content,
                                    timestamp: comment.whenSent as DateTime?,
                                  ),
                                );
                              },
                            ),
                    ),

                    // 3. RODAPÉ - Campo de digitar comentário
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          top: BorderSide(color: Colors.grey[300]!, width: 1),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: SafeArea(
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: commentary,
                                onChanged: (value) {
                                  setState(() {});
                                },
                                decoration: InputDecoration(
                                  hintText: "Adicione um comentário...",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(24),
                                    borderSide: BorderSide(
                                      color: Colors.grey[300]!,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(24),
                                    borderSide: BorderSide(
                                      color: Colors.grey[300]!,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(24),
                                    borderSide: BorderSide(
                                      color: primaryColor,
                                      width: 2,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                ),
                                maxLines: null,
                                textInputAction: TextInputAction.newline,
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: canSend
                                  ? () async {
                                      final res = await controller
                                          .addCommentary(
                                            context,
                                            publishId,
                                            commentary.text,
                                          );

                                      if (res) {
                                        final cm = await controller
                                            .loadingCommentaries(publishId);

                                        commentaries = cm;
                                        final index = controller.publishs
                                            .indexWhere(
                                              (p) => p.id == publishId,
                                            );

                                        if (index != -1) {
                                          controller
                                                  .publishs[index]
                                                  .qtCommentary =
                                              (controller
                                                      .publishs[index]
                                                      .qtCommentary ??
                                                  0) +
                                              1;
                                        }

                                        outerSetState(() {});
                                      }

                                      commentary.clear();
                                      setState(() {});
                                    }
                                  : null,
                              icon: Icon(
                                Icons.send_rounded,
                                color: canSend
                                    ? primaryColor
                                    : Colors.grey.shade400,
                              ),
                              style: IconButton.styleFrom(
                                backgroundColor: canSend
                                    ? primaryColor.withOpacity(0.1)
                                    : Colors.grey.shade100,
                                padding: const EdgeInsets.all(12),
                                disabledBackgroundColor: Colors.grey.shade100,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).then((_) {
      commentary.clear();
    });
  }
}
