class AiTextRequest {
  final String format; // post_ig, caption, reels_script, blog_short, web_about, whatsapp_broadcast
  final String? prompt; // New: Magic Idea
  final String? businessType; // Now Optional
  final String? audience;     // Now Optional
  final String? goal;         // Now Optional
  final String tone;          // Defaults to "professional" or inferred
  final String language;
  
  // Advanced / Optional
  final String lengthHint;
  final List<String> keywords;
  final String? callToAction;
  final String? offer;
  final String? brandName;
  final String? extraConstraints;

  AiTextRequest({
    required this.format,
    this.prompt,
    this.businessType,
    this.audience,
    this.goal,
    this.tone = 'profesional',
    this.language = 'es',
    this.lengthHint = 'balanced',
    this.keywords = const [],
    this.callToAction,
    this.offer,
    this.brandName,
    this.extraConstraints,
  });

  Map<String, dynamic> toJson() => {
    'format': format,
    'prompt': prompt,
    'businessType': businessType,
    'audience': audience,
    'goal': goal,
    'tone': tone,
    'language': language,
    'lengthHint': lengthHint,
    'keywords': keywords,
    'callToAction': callToAction,
    'offer': offer,
    'brandName': brandName,
    'extraConstraints': extraConstraints,
  };

  factory AiTextRequest.fromJson(Map<String, dynamic> json) => AiTextRequest(
    format: json['format'],
    prompt: json['prompt'],
    businessType: json['businessType'],
    audience: json['audience'],
    goal: json['goal'],
    tone: json['tone'] ?? 'profesional',
    language: json['language'] ?? 'es',
    lengthHint: json['lengthHint'] ?? 'balanced',
    keywords: List<String>.from(json['keywords'] ?? []),
    callToAction: json['callToAction'],
    offer: json['offer'],
    brandName: json['brandName'],
    extraConstraints: json['extraConstraints'],
  );
}
