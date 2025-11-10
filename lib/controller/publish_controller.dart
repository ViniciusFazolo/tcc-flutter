import 'package:tcc_flutter/domain/publish.dart';
import 'package:tcc_flutter/service/publish_service.dart';
import 'package:tcc_flutter/utils/utils.dart';

class PublishController {
  List<Publish> publishs = [];
  final PublishService publishService = PublishService(
    baseUrl: "$apiBaseUrl/publish",
  );

  Future<void> fetchPublishsByAlbumId(String albumId) async {
    publishs = await publishService.getList(albumId);
  }

  Future<void> delete(String id) async {
    await publishService.deleteItem(id);
  }
}
