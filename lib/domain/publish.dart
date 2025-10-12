import 'package:tcc_flutter/domain/user.dart';
import 'package:tcc_flutter/domain/image_entity.dart';

class Publish {
  String? id;
  List<ImageEntity>? images;
  String? description;
  User? author;
  String? whenSent;
  String? album;

  Publish({
    this.id,
    this.images,
    this.description,
    this.author,
    this.whenSent,
    this.album,
  });

  factory Publish.fromJson(Map<String, dynamic> json) {
    return Publish(
      id: json["id"],
      images: json["images"] != null
          ? (json["images"] as List)
                .map((x) => ImageEntity.fromJson(x))
                .toList()
          : null,
      description: json["description"],
      author: json["author"] != null ? User.fromJson(json["author"]) : null,
      whenSent: json["whenSent"],
      album: json["album"],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "images": images?.map((x) => x.toJson()).toList(),
    "description": description,
    "author": author?.toJson(),
    "whenSent": whenSent,
    "album": album,
  };
}
