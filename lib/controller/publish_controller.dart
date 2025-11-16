import 'package:flutter/material.dart';
import 'package:tcc_flutter/domain/commentary.dart';
import 'package:tcc_flutter/domain/publish.dart';
import 'package:tcc_flutter/service/commentary_service.dart';
import 'package:tcc_flutter/service/publish_service.dart';
import 'package:tcc_flutter/utils/prefs.dart';
import 'package:tcc_flutter/utils/utils.dart';

class PublishController {
  List<Publish> publishs = [];
  final PublishService publishService = PublishService(
    baseUrl: "$apiBaseUrl/publish",
  );
  final CommentaryService commentaryService = CommentaryService(
    baseUrl: "$apiBaseUrl/commentary",
  );

  Future<void> fetchPublishsByAlbumId(String albumId) async {
    publishs = await publishService.getList(albumId);
  }

  Future<void> delete(String id) async {
    await publishService.deleteItem(id);
  }

  Future<bool> addCommentary(
    BuildContext context,
    String publishId,
    String content,
  ) async {
    String userId = await Prefs.getString("id");
    final body = {'content': content, 'author': userId, 'publish': publishId};

    try {
      await commentaryService.postItem("", body);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<Commentary>> loadingCommentaries(String publishId) {
    return commentaryService.getCommentaryByPublishId(publishId);
  }
}
