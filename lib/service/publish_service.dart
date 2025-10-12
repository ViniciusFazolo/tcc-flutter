import 'package:tcc_flutter/domain/publish.dart';
import 'package:tcc_flutter/service/crud_service.dart';

class PublishService extends CrudService<Publish>{
  PublishService({required super.baseUrl}) : super(fromJson: Publish.fromJson);
}