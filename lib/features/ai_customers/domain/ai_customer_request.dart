class AiCustomerRequest {
  final String? prompt; // Magic Idea
  final String? businessType;
  final String? targetSegment;
  final String tone; // profesional, persuasivo, empático
  final String language;

  AiCustomerRequest({
    this.prompt,
    this.businessType,
    this.targetSegment,
    this.tone = 'profesional',
    this.language = 'es',
  });

  Map<String, dynamic> toJson() => {
    'prompt': prompt,
    'businessType': businessType,
    'targetSegment': targetSegment,
    'tone': tone,
    'language': language,
  };

  factory AiCustomerRequest.fromJson(Map<String, dynamic> json) => AiCustomerRequest(
    prompt: json['prompt'],
    businessType: json['businessType'],
    targetSegment: json['targetSegment'],
    tone: json['tone'] ?? 'profesional',
    language: json['language'] ?? 'es',
  );
}
