import 'dart:convert';

class PostDraft {
  final String id;
  final String title;
  final String slug;
  final String excerpt;
  final String content;
  final List<String> tags;
  final String imagePrompt;
  final String imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String status; // 'draft' or 'published'
  final String source; // 'external', 'app', or 'both'

  PostDraft({
    required this.id,
    required this.title,
    required this.slug,
    required this.excerpt,
    required this.content,
    required this.tags,
    required this.imagePrompt,
    required this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
    required this.source,
  });

  // Factory constructor from JSON
  factory PostDraft.fromJson(Map<String, dynamic> json) {
    return PostDraft(
      id: json['id'] as String,
      title: json['title'] as String,
      slug: json['slug'] as String,
      excerpt: json['excerpt'] as String,
      content: json['content'] as String,
      tags: List<String>.from(json['tags'] as List),
      imagePrompt: json['imagePrompt'] as String,
      imageUrl: json['imageUrl'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      status: json['status'] as String,
      source: json['source'] as String? ?? 'both',
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'slug': slug,
      'excerpt': excerpt,
      'content': content,
      'tags': tags,
      'imagePrompt': imagePrompt,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'status': status,
      'source': source,
    };
  }

  // Helper to generate slug from title
  static String generateSlug(String title) {
    return title
        .toLowerCase()
        .replaceAll(RegExp(r'[áàäâ]'), 'a')
        .replaceAll(RegExp(r'[éèëê]'), 'e')
        .replaceAll(RegExp(r'[íìïî]'), 'i')
        .replaceAll(RegExp(r'[óòöô]'), 'o')
        .replaceAll(RegExp(r'[úùüû]'), 'u')
        .replaceAll(RegExp(r'[ñ]'), 'n')
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
  }

  // CopyWith for updates
  PostDraft copyWith({
    String? title,
    String? slug,
    String? excerpt,
    String? content,
    List<String>? tags,
    String? imagePrompt,
    String? imageUrl,
    DateTime? updatedAt,
    String? status,
    String? source,
  }) {
    return PostDraft(
      id: id,
      title: title ?? this.title,
      slug: slug ?? this.slug,
      excerpt: excerpt ?? this.excerpt,
      content: content ?? this.content,
      tags: tags ?? this.tags,
      imagePrompt: imagePrompt ?? this.imagePrompt,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
      source: source ?? this.source,
    );
  }

  // Create empty draft
  factory PostDraft.empty() {
    final now = DateTime.now();
    return PostDraft(
      id: now.millisecondsSinceEpoch.toString(),
      title: '',
      slug: '',
      excerpt: '',
      content: '',
      tags: [],
      imagePrompt: '',
      imageUrl: '',
      createdAt: now,
      updatedAt: now,
      status: 'draft',
      source: 'both',
    );
  }
}
