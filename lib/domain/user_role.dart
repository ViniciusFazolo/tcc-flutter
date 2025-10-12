class UserRole {
  String? id;
  String? role;

  UserRole({this.id, this.role});

  factory UserRole.fromJson(Map<String, dynamic> json) {
    return UserRole(id: json["id"], role: json["role"]);
  }

  Map<String, dynamic> toJson() => {"id": id, "role": role};
}
