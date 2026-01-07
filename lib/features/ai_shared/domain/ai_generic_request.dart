import 'ai_shared_types.dart';

class AiGenericRequest {
  final AiFeatureType type;
  final String prompt;
  final String tone;
  final String? context; // Injected business context
  final Map<String, String>? formData; // User-filled form data for complete documents

  AiGenericRequest({
    required this.type,
    required this.prompt,
    this.tone = 'profesional',
    this.context,
    this.formData,
  });

  Map<String, dynamic> toJson() => {
    'type': type.index,
    'prompt': prompt,
    'tone': tone,
    'context': context,
    'formData': formData,
  };

  factory AiGenericRequest.fromJson(Map<String, dynamic> json) => AiGenericRequest(
    type: AiFeatureType.values[json['type']],
    prompt: json['prompt'],
    tone: json['tone'],
    context: json['context'],
    formData: json['formData'] != null ? Map<String, String>.from(json['formData']) : null,
  );
}
