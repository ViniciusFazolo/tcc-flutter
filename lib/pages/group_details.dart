import 'package:flutter/material.dart';
import 'package:tcc_flutter/controller/group_details_controller.dart';
import 'package:tcc_flutter/pages/camera.dart';
import 'package:tcc_flutter/utils/prefs.dart';
import 'package:tcc_flutter/utils/widget/album_card.dart';
import 'package:tcc_flutter/utils/widget/custom_popup_menu.dart';
import 'package:tcc_flutter/utils/widget/loading_overlay.dart';

class GroupDetails extends StatefulWidget {
  final String id;
  const GroupDetails({super.key, required this.id});

  @override
  State<GroupDetails> createState() => _GroupDetailsState();
}

class _GroupDetailsState extends State<GroupDetails> {
  final GroupDetailsController controller = GroupDetailsController();
  bool isLoading = true;
  bool isUserAdmin = false;
  bool isDeletingAlbums = false;

  bool isSelectionMode = false;
  List<String> selectedAlbumIds = [];

  @override
  void initState() {
    super.initState();
    _loadGroup();
  }

  Future<void> _loadGroup() async {
    await controller.fetchGroupById(widget.id);
    isUserAdmin = await controller.isUserAdmin();
    Prefs.setBool("isUserAdmin", isUserAdmin);
    setState(() {
      isLoading = false;
    });
  }

  void _toggleSelectionMode() {
    setState(() {
      isSelectionMode = !isSelectionMode;
      if (!isSelectionMode) {
        selectedAlbumIds.clear();
      }
    });
  }

  void _toggleAlbumSelection(String albumId) {
    setState(() {
      if (selectedAlbumIds.contains(albumId)) {
        selectedAlbumIds.remove(albumId);
        // Se não houver mais álbuns selecionados, sair do modo de seleção
        if (selectedAlbumIds.isEmpty) {
          isSelectionMode = false;
        }
      } else {
        selectedAlbumIds.add(albumId);
      }
    });
  }

  Future<void> _deleteSelectedAlbums() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Text(
          'Deseja realmente excluir ${selectedAlbumIds.length} álbum(ns)? Se houver imagens, elas serão permanentemente deletadas',
        ),
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
        isDeletingAlbums = true;
      });

      try {
        await controller.deleteAlbums(selectedAlbumIds);

        setState(() {
          isSelectionMode = false;
          selectedAlbumIds.clear();
        });

        await _loadGroup();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Álbuns excluídos com sucesso')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Erro ao excluir álbuns: $e')));
        }
      } finally {
        if (mounted) {
          setState(() {
            isDeletingAlbums = false;
          });
        }
      }
    }
  }

  void _selectAll() {
    setState(() {
      selectedAlbumIds = controller.albums.map((album) => album.id!).toList();
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
        leading: isSelectionMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: _toggleSelectionMode,
              )
            : null,
        title: isSelectionMode
            ? Text('${selectedAlbumIds.length} selecionado(s)')
            : Row(
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
          if (isSelectionMode) ...[
            if (selectedAlbumIds.length < controller.albums.length)
              IconButton(
                icon: const Icon(Icons.select_all),
                onPressed: _selectAll,
                tooltip: 'Selecionar tudo',
              ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: selectedAlbumIds.isEmpty
                  ? null
                  : _deleteSelectedAlbums,
              tooltip: 'Excluir',
            ),
          ] else
            Row(
              children: [
                CustomPopupMenu(
                  items: [
                    PopupMenuItemData(
                      value: 'membros',
                      label: 'Membros',
                      icon: Icons.people,
                      onTap: () async {
                        await controller.goToGroupMembers(
                          context,
                          controller.group,
                          isUserAdmin,
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(width: 8),
              ],
            ),
        ],
      ),
      floatingActionButton: isSelectionMode
          ? null
          : Column(
              mainAxisAlignment: MainAxisAlignment.end,
              spacing: 10,
              children: [
                if(controller.albums.isNotEmpty)
                  FloatingActionButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Camera(albums: controller.albums),
                        ),
                      );
                    },
                    child: const Icon(Icons.camera_alt),
                  ),
                if (isUserAdmin && controller.albums.isNotEmpty)
                  FloatingActionButton(
                    onPressed: () async {
                      await controller.goToNewAlbum(context, widget.id);
                      await controller.fetchAlbumsByGroupId(widget.id).then((
                        _,
                      ) {
                        setState(() {});
                      });
                    },
                    child: const Icon(Icons.add_to_photos),
                  ),
              ],
            ),
      body: Stack(
        children: [
          controller.albums.isNotEmpty
              ? SingleChildScrollView(
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: controller.albums.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.8,
                        ),
                    itemBuilder: (context, index) {
                      final album = controller.albums[index];
                      final isSelected = selectedAlbumIds.contains(album.id);

                      return GestureDetector(
                        onTap: () {
                          if (isSelectionMode) {
                            _toggleAlbumSelection(album.id!);
                          } else {
                            controller.goToAlbumDetails(
                              context,
                              album.id!,
                              isUserAdmin,
                            );
                          }
                        },
                        onLongPress: () {
                          if (!isSelectionMode && isUserAdmin) {
                            setState(() {
                              isSelectionMode = true;
                              selectedAlbumIds.add(album.id!);
                            });
                          }
                        },
                        child: Stack(
                          children: [
                            AlbumCard(
                              album: album,
                              onTap: () {
                                if (isSelectionMode) {
                                  _toggleAlbumSelection(album.id!);
                                } else {
                                  controller.goToAlbumDetails(
                                    context,
                                    album.id!,
                                    isUserAdmin,
                                  );
                                }
                              },
                            ),
                            if (isSelectionMode)
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSelected
                                        ? Theme.of(context).primaryColor
                                        : Colors.white.withOpacity(0.7),
                                    border: Border.all(
                                      color: isSelected
                                          ? Theme.of(context).primaryColor
                                          : Colors.grey,
                                      width: 2,
                                    ),
                                  ),
                                  child: isSelected
                                      ? const Icon(
                                          Icons.check,
                                          size: 16,
                                          color: Colors.white,
                                        )
                                      : null,
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                )
              : _buildEmptyState(),
          LoadingOverlay(
            isLoading: isDeletingAlbums,
            message:
                "Aguarde, o(s) album(ns) selecionados estão sendo excluídos...",
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.photo_album, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Nenhum álbum ainda',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Crie um novo álbum para começar',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () async {
              await controller.goToNewAlbum(context, widget.id);
              await controller.fetchAlbumsByGroupId(widget.id).then((_) {
                setState(() {});
              });
            },
            icon: const Icon(Icons.add_rounded),
            label: const Text('Criar álbum'),
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
