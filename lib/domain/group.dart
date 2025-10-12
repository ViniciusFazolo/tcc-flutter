import 'package:tcc_flutter/domain/user.dart';
import 'package:tcc_flutter/domain/user_group.dart';

class Group {
  String? id;
  String? name;
  String? description;
  String? image;
  String? imageName;
  User? adm;
  List<UserGroup>? userGroups;

  Group({
    this.id,
    this.name,
    this.description,
    this.image,
    this.imageName,
    this.adm,
    this.userGroups,
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json["id"],
      name: json["name"],
      description: json["description"],
      image: json["image"],
      imageName: json["image_name"],
      adm: json["adm"] != null ? User.fromJson(json["adm"]) : null,
      userGroups: (json["userGroups"] as List<dynamic>?)
          ?.map((e) => UserGroup.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "description": description,
    "image": image,
    "image_name": imageName,
    "adm": adm?.toJson(),
    "userGroups": userGroups?.map((e) => e.toJson()).toList(),
  };
}
