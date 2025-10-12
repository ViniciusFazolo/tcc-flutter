import 'package:tcc_flutter/domain/group.dart';
import 'package:tcc_flutter/domain/user.dart';

class UserGroup {
  String? id;
  User? user;
  Group? group;
  int totalNotifies;
  String? hourLastPublish;

  UserGroup({
    this.id,
    this.user,
    this.group,
    this.totalNotifies = 0,
    this.hourLastPublish,
  });

  factory UserGroup.fromJson(Map<String, dynamic> json) {
    return UserGroup(
      id: json["id"],
      user: json["user"] != null ? User.fromJson(json["user"]) : null,
      group: json["group"] != null ? Group.fromJson(json["group"]) : null,
      totalNotifies: json["totalNotifies"] ?? 0,
      hourLastPublish: json["hourLastPublish"],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "user": user?.toJson(),
    "group": group?.toJson(),
    "totalNotifies": totalNotifies,
    "hourLastPublish": hourLastPublish,
  };
}
