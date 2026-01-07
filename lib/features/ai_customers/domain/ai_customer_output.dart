import 'ai_customer_request.dart';

class AiCustomerOutput {
  final String id;
  final DateTime createdAt;
  final AiCustomerRequest request;
  final String buyerPersona; // Perfil detallado
  final String strategy;     // Plan de fidelización/comunicación
  final String empathyMap;   // Mapa de empatía
  final String suggestedAction;

  AiCustomerOutput({
    required this.id,
    required this.createdAt,
    required this.request,
    required this.buyerPersona,
    required this.strategy,
    required this.empathyMap,
    required this.suggestedAction,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'createdAt': createdAt.toIso8601String(),
    'request': request.toJson(),
    'buyerPersona': buyerPersona,
    'strategy': strategy,
    'empathyMap': empathyMap,
    'suggestedAction': suggestedAction,
  };

  factory AiCustomerOutput.fromJson(Map<String, dynamic> json) => AiCustomerOutput(
    id: json['id'],
    createdAt: DateTime.parse(json['createdAt']),
    request: AiCustomerRequest.fromJson(json['request']),
    buyerPersona: json['buyerPersona'],
    strategy: json['strategy'],
    empathyMap: json['empathyMap'],
    suggestedAction: json['suggestedAction'],
  );
}
