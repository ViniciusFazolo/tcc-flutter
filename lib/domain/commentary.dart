import 'package:tcc_flutter/domain/user.dart';

class Commentary {
  final String id;
  final String content;
  final DateTime whenSent;
  final User author;
  final String publishId;

  Commentary({
    required this.id,
    required this.content,
    required this.whenSent,
    required this.author,
    required this.publishId,
  });

  // Factory para criar a partir de JSON
  factory Commentary.fromJson(Map<String, dynamic> json) {
    return Commentary(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      content: json['content'] as String? ?? '',
      whenSent: json['whenSent'] != null
          ? DateTime.parse(json['whenSent'] as String)
          : (json['createdAt'] != null
                ? DateTime.parse(json['createdAt'] as String)
                : DateTime.now()),
      author: json['author'] is Map<String, dynamic>
          ? User.fromJson(json['author'] as Map<String, dynamic>)
          : json['author'] is String
          ? User(
              id: json['author'] as String,
              name: 'Usuário',
              login: '',
              image: null,
            )
          : User(id: '', name: 'Usuário', login: '', image: null),
      publishId:
          json['publishId'] as String? ?? json['publish'] as String? ?? '',
    );
  }

  // Converter para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'whenSent': whenSent.toIso8601String(),
      'author': author.toJson(),
      'publishId': publishId,
    };
  }
}
