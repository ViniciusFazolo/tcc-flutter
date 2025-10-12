import 'package:tcc_flutter/domain/user_role.dart';

class User {
  String? id;
  String? name;
  String? login;
  String? password;
  String? image;
  UserRole? role;

  User({this.id, this.name, this.login, this.password, this.image, this.role});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json["id"],
      name: json["name"],
      login: json["login"],
      image: json["image"],
      role: json["role"] != null ? UserRole.fromJson(json["role"]) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "login": login,
    "password": password,
    "image": image,
    "role": role?.toJson(),
  };
}
