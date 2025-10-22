import 'package:flutter/material.dart';
import 'package:tcc_flutter/domain/album.dart';
import 'package:tcc_flutter/domain/group.dart';
import 'package:tcc_flutter/pages/group_members.dart';
import 'package:tcc_flutter/pages/new_album.dart';
import 'package:tcc_flutter/pages/publish.dart';
import 'package:tcc_flutter/service/album_service.dart';
import 'package:tcc_flutter/service/group_service.dart';
import 'package:tcc_flutter/utils/utils.dart';

class GroupDetailsController {
  late Group group;
  List<Album> albums = [];

  Future<void> fetchGroupById(String id) async {
    final GroupService groupService = GroupService(
      baseUrl: "$apiBaseUrl/group",
    );

    group = await groupService.getItem(id);
    albums = await fetchAlbumsByGroupId(group.id!);
  }

  Future<List<Album>> fetchAlbumsByGroupId(String id) async {
    final AlbumService albumService = AlbumService(
      baseUrl: "$apiBaseUrl/album",
    );

    final res = await albumService.getList("group/$id");
    albums = res;
    return res;
  }

  goToAlbumDetails(BuildContext context, String albumId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Publish(albumId: albumId)),
    );
  }

  Future<void> goToNewAlbum(BuildContext context, String groupId) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NewAlbum(groupId: groupId)),
    );
  }

  Future<void> goToGroupMembers(BuildContext context, String groupId) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GroupMembers(groupId: groupId, admin: group.adm!,)),
    );
  }

  // goToCamera(BuildContext context, Future<List<CameraDescription>> cameras) async {
  //   final camerasRes = await cameras;

  //   Navigator.push(context, MaterialPageRoute(builder: (context) => Camera(cameras: camerasRes,)));
  // }
}
