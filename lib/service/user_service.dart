import 'package:tcc_flutter/domain/user.dart';
import 'package:tcc_flutter/service/crud_service.dart';

class UserService extends CrudService<User>{
  UserService({required super.baseUrl}) : super(fromJson: User.fromJson);
}