import 'package:tcc_flutter/domain/publish.dart';
import 'package:tcc_flutter/service/publish_service.dart';
import 'package:tcc_flutter/utils/utils.dart';

class PublishController {
  List<Publish> publishs = [];

  Future<void> fetchPublishsByAlbumId(String albumId) async {
    final PublishService publishService = PublishService(
      baseUrl: "$apiBaseUrl/publish",
    );

    publishs = await publishService.getList(albumId);
  }
}
