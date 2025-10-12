import 'package:tcc_flutter/domain/publish.dart';

class Album {
  String? id;
  String? image;
  String name;
  String? group;
  List<Publish>? publishs;

  Album({this.id, this.image, required this.name, this.group, this.publishs});

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      id: json["id"],
      image: json["image"],
      name: json["name"] ?? '',
      group: json["group"],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "image": image,
    "name": name,
    "group": group,
    "publishs": publishs?.map((x) => x.toJson()).toList(),
  };
}
