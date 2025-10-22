import 'package:tcc_flutter/domain/user.dart';
import 'package:tcc_flutter/service/user_service.dart';
import 'package:tcc_flutter/utils/utils.dart';

class GroupMembersController {
  List<User> people = [];

  Future<void> findPeopleByGroupId(String groupId) async {
    try {
      final UserService userService = UserService(baseUrl: apiBaseUrl);
      people = await userService.getList("user/byGroupId/$groupId");
      print('Membros carregados: ${people.length}');
    } catch (e) {
      print('Erro no controller ao buscar membros: $e');
      people = [];
      rethrow; // Repassa o erro para ser tratado na UI
    }
  }
}