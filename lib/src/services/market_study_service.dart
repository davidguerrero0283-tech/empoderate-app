import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'gemini_service.dart';

/// Model for Market Study results
class MarketStudy {
  final String rubroId;
  final String rubroName;
  final DateTime generatedAt;
  final String competitionAnalysis;
  final String opportunities;
  final String risks;
  final String recommendations;
  final String targetAudience;
  final String pricingStrategy;

  MarketStudy({
    required this.rubroId,
    required this.rubroName,
    required this.generatedAt,
    required this.competitionAnalysis,
    required this.opportunities,
    required this.risks,
    required this.recommendations,
    required this.targetAudience,
    required this.pricingStrategy,
  });

  Map<String, dynamic> toJson() => {
    'rubroId': rubroId,
    'rubroName': rubroName,
    'generatedAt': generatedAt.toIso8601String(),
    'competitionAnalysis': competitionAnalysis,
    'opportunities': opportunities,
    'risks': risks,
    'recommendations': recommendations,
    'targetAudience': targetAudience,
    'pricingStrategy': pricingStrategy,
  };

  factory MarketStudy.fromJson(Map<String, dynamic> json) => MarketStudy(
    rubroId: json['rubroId'] ?? '',
    rubroName: json['rubroName'] ?? '',
    generatedAt: DateTime.parse(json['generatedAt']),
    competitionAnalysis: json['competitionAnalysis'] ?? '',
    opportunities: json['opportunities'] ?? '',
    risks: json['risks'] ?? '',
    recommendations: json['recommendations'] ?? '',
    targetAudience: json['targetAudience'] ?? '',
    pricingStrategy: json['pricingStrategy'] ?? '',
  );
}

/// Service for generating and caching market studies
class MarketStudyService {
  final GeminiService _gemini = GeminiService();
  static const String _cachePrefix = 'market_study_cache_';

  /// Get cached study or null if not exists
  Future<MarketStudy?> getCachedStudy(String rubroId) async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString('$_cachePrefix$rubroId');
    if (cached != null) {
      try {
        return MarketStudy.fromJson(jsonDecode(cached));
      } catch (e) {
        return null;
      }
    }
    return null;
  }



  /// Clear cached study for a rubro
  Future<void> clearCache(String rubroId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_cachePrefix$rubroId');
  }

  /// Generate a complete market study for a business type
  Future<MarketStudy> generateStudy(String rubroId, String rubroName, {String? location, bool forceRefresh = false}) async {
    // Check cache first (include location in cache key if present)
    final cacheKey = location != null && location.isNotEmpty 
        ? '${rubroId}_${location.toLowerCase().replaceAll(RegExp(r'\s+'), '_')}'
        : rubroId;

    if (!forceRefresh) {
      final cached = await getCachedStudy(cacheKey);
      if (cached != null) {
        // Use cache if less than 7 days old
        final age = DateTime.now().difference(cached.generatedAt);
        if (age.inDays < 7) {
          return cached;
        }
      }
    }

    // Generate new study using Gemini
    final prompt = _buildPrompt(rubroName, location);
    final response = await _gemini.generateContent(prompt, maxTokens: 3500); // Increased tokens for more detail
    
    // Parse response into sections
    final study = _parseResponse(rubroId, rubroName, response);
    
    // Cache the result
    await _cacheStudy(study, cacheKey);
    
    return study;
  }

  Future<void> _cacheStudy(MarketStudy study, String cacheKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_cachePrefix$cacheKey', jsonEncode(study.toJson()));
  }

  String _buildPrompt(String rubroName, String? location) {
    String locationContext = "Panamá";
    String locationInstruction = "Sé específico para el mercado panameño en general.";
    
    if (location != null && location.trim().isNotEmpty) {
      locationContext = "$location, Panamá";
      locationInstruction = "IMPORTANTE: Enfoca TODO el análisis específicamente en la zona de $location. Considera el nivel socioeconómico, tráfico, competencia y estilo de vida de ESTE barrio/zona específica.";
    }

    return '''
Eres un experto consultor de negocios y analista de mercado en Panamá. Genera un estudio de mercado ESTRATÉGICO y DETALLADO para un negocio de tipo: "$rubroName" ubicado en: "$locationContext".

$locationInstruction

Responde SOLO con este JSON exacto (sin texto adicional):

{
  "competitionAnalysis": "Análisis de la competencia en $locationContext. ¿Quiénes son los líderes en esta zona? ¿Está saturado el mercado ahí? ¿Qué falta en esa área?",
  "opportunities": "Oportunidades únicas en $locationContext. ¿Qué busca la gente de esta zona que no encuentra? ¿Hay horarios o servicios desatendidos?",
  "risks": "Riesgos específicos de $locationContext. (Ej. Alquileres altos, falta de estacionamiento, seguridad, saturación, poder adquisitivo bajo/alto).",
  "recommendations": "5 acciones concretas para triunfar en $locationContext. ¿Qué marketing funciona ahí? ¿Qué imagen debe tener el local?",
  "targetAudience": "Perfil del cliente de $locationContext. ¿Son familias, oficinistas, turistas? ¿Cuál es su presupuesto promedio?",
  "pricingStrategy": "Precios sugeridos para $locationContext. ¿Deben ser económicos, medios o premium? Da rangos de precios específicos en USD."
}
''';
  }

  MarketStudy _parseResponse(String rubroId, String rubroName, String response) {
    try {
      // Try to extract JSON from response
      String jsonStr = response;
      
      // If response has markdown code blocks, extract JSON
      if (response.contains('```json')) {
        final start = response.indexOf('```json') + 7;
        final end = response.indexOf('```', start);
        jsonStr = response.substring(start, end).trim();
      } else if (response.contains('```')) {
        final start = response.indexOf('```') + 3;
        final end = response.indexOf('```', start);
        jsonStr = response.substring(start, end).trim();
      }
      
      // Find JSON object in response
      final jsonStart = jsonStr.indexOf('{');
      final jsonEnd = jsonStr.lastIndexOf('}');
      if (jsonStart != -1 && jsonEnd != -1) {
        jsonStr = jsonStr.substring(jsonStart, jsonEnd + 1);
      }

      final data = jsonDecode(jsonStr);
      
      return MarketStudy(
        rubroId: rubroId,
        rubroName: rubroName,
        generatedAt: DateTime.now(),
        competitionAnalysis: data['competitionAnalysis'] ?? 'No disponible',
        opportunities: data['opportunities'] ?? 'No disponible',
        risks: data['risks'] ?? 'No disponible',
        recommendations: data['recommendations'] ?? 'No disponible',
        targetAudience: data['targetAudience'] ?? 'No disponible',
        pricingStrategy: data['pricingStrategy'] ?? 'No disponible',
      );
    } catch (e) {
      // If parsing fails, create study from raw text
      return MarketStudy(
        rubroId: rubroId,
        rubroName: rubroName,
        generatedAt: DateTime.now(),
        competitionAnalysis: response,
        opportunities: 'Ver análisis principal',
        risks: 'Ver análisis principal',
        recommendations: 'Ver análisis principal',
        targetAudience: 'Ver análisis principal',
        pricingStrategy: 'Ver análisis principal',
      );
    }
  }
}
