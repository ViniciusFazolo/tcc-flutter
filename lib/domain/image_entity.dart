import 'package:tcc_flutter/domain/publish.dart';

class ImageEntity {
  String? id;
  String? image;
  Publish? publish;

  ImageEntity({this.id, this.image, this.publish});

  factory ImageEntity.fromJson(Map<String, dynamic> json) {
    return ImageEntity(
      id: json["id"],
      image: json["image"],
      publish: json["publish"] != null 
          ? Publish.fromJson(json["publish"]) 
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "image": image,
    "publish": publish?.toJson(),
  };
}
