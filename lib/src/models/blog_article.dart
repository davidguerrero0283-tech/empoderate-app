import 'package:flutter/material.dart';
import 'comment.dart';

class BlogArticle {
  final String id;
  final String title;
  final String subtitle;
  final String description; // short excerpt
  final String category;
  final DateTime date;
  final String imageUrl; // asset or network placeholder
  final String content; // full article content (HTML or plain text)
  final List<String> keywords;
  final List<String> relatedIds; // ids of related articles
  final String status; // 'published', 'draft', 'scheduled'
  final bool isFeatured;
  final String metaTitle;
  final String metaDescription;
  final String contentRaw; // For editing
  
  // New CMS Fields
  final List<String> tags;
  final int views;
  final int likes;
  final bool allowComments;
  final List<Comment> comments;
  final DateTime? scheduledDate;
  final DateTime? publishedAt;

  BlogArticle({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.category,
    required this.date,
    required this.imageUrl,
    required this.content,
    required this.keywords,
    required this.relatedIds,
    this.status = 'published',
    this.isFeatured = false,
    this.metaTitle = '',
    this.metaDescription = '',
    this.contentRaw = '', 
    this.tags = const [],
    this.views = 0,
    this.likes = 0,
    this.allowComments = true,
    this.comments = const [],
    this.scheduledDate,
    this.publishedAt,
  });

  // Calculate read time (approx 200 words per minute)
  double get readTime {
    final wordCount = content.split(RegExp(r'\s+')).length;
    final minutes = wordCount / 200;
    return minutes < 1 ? 1 : minutes;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'description': description,
      'category': category,
      'date': date.toIso8601String(),
      'imageUrl': imageUrl,
      'content': content,
      'keywords': keywords,
      'relatedIds': relatedIds,
      'status': status,
      'isFeatured': isFeatured,
      'metaTitle': metaTitle,
      'metaDescription': metaDescription,
      'contentRaw': contentRaw,
      'tags': tags,
      'views': views,
      'likes': likes,
      'allowComments': allowComments,
      'comments': comments.map((c) => c.toJson()).toList(),
      'scheduledDate': scheduledDate?.toIso8601String(),
      'publishedAt': publishedAt?.toIso8601String(),
    };
  }

  factory BlogArticle.fromJson(Map<String, dynamic> json) {
    return BlogArticle(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      imageUrl: json['imageUrl'] ?? '',
      content: json['content'] ?? '',
      keywords: List<String>.from(json['keywords'] ?? []),
      relatedIds: List<String>.from(json['relatedIds'] ?? []),
      status: json['status'] ?? 'draft',
      isFeatured: json['isFeatured'] ?? false,
      metaTitle: json['metaTitle'] ?? '',
      metaDescription: json['metaDescription'] ?? '',
      contentRaw: json['contentRaw'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      views: json['views'] ?? 0,
      likes: json['likes'] ?? 0,
      allowComments: json['allowComments'] ?? true,
      comments: (json['comments'] as List<dynamic>? ?? [])
          .map((c) => Comment.fromJson(c))
          .toList(),
      scheduledDate: json['scheduledDate'] != null ? DateTime.tryParse(json['scheduledDate']) : null,
      publishedAt: json['publishedAt'] != null ? DateTime.tryParse(json['publishedAt']) : null,
    );
  }
}
