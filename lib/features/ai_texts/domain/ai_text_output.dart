import 'ai_text_request.dart';

class AiTextOutput {
  final String id;
  final DateTime createdAt;
  final AiTextRequest request;
  final String shortVersion;
  final String mediumVersion;
  final String longVersion;
  final List<String> hashtags;
  final String suggestedCta;

  AiTextOutput({
    required this.id,
    required this.createdAt,
    required this.request,
    required this.shortVersion,
    required this.mediumVersion,
    required this.longVersion,
    required this.hashtags,
    required this.suggestedCta,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'createdAt': createdAt.toIso8601String(),
    'request': request.toJson(),
    'shortVersion': shortVersion,
    'mediumVersion': mediumVersion,
    'longVersion': longVersion,
    'hashtags': hashtags,
    'suggestedCta': suggestedCta,
  };

  factory AiTextOutput.fromJson(Map<String, dynamic> json) => AiTextOutput(
    id: json['id'],
    createdAt: DateTime.parse(json['createdAt']),
    request: AiTextRequest.fromJson(json['request']),
    shortVersion: json['shortVersion'],
    mediumVersion: json['mediumVersion'],
    longVersion: json['longVersion'],
    hashtags: List<String>.from(json['hashtags'] ?? []),
    suggestedCta: json['suggestedCta'],
  );
}
