import 'package:flutter/material.dart';

class Comment {
  final String id;
  final String userName;
  final String text;
  final DateTime date;

  Comment({
    required this.id,
    required this.userName,
    required this.text,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userName': userName,
      'text': text,
      'date': date.toIso8601String(),
    };
  }

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] ?? '',
      userName: json['userName'] ?? 'Anónimo',
      text: json['text'] ?? '',
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
    );
  }
}
