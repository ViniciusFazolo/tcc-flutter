import 'package:tcc_flutter/domain/user.dart';

class GroupInvite {
  String? id;
  String? groupId;
  String? groupName;
  User? invitedBy;
  User? invitedUser;
  String? status;

  GroupInvite({
    this.id,
    this.groupId,
    this.groupName,
    this.invitedBy,
    this.invitedUser,
    this.status,
  });

  factory GroupInvite.fromJson(Map<String, dynamic> json) {
    return GroupInvite(
      id: json["id"],
      groupId: json["groupId"],
      groupName: json["groupName"] ?? '',
      invitedBy: json["invitedBy"] != null
          ? User.fromJson(json["invitedBy"])
          : null,
      invitedUser: json["invitedUser"] != null
          ? User.fromJson(json["invitedUser"])
          : null,
      status: json["status"],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "groupId": groupId,
    "groupName": groupName,
    "invitedBy": invitedBy,
    "invitedUser": invitedUser,
    "status": status,
  };
}
