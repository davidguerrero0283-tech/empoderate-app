import 'dart:convert';

/// Builds SEO-optimized prompts for blog article generation
/// 
/// Configures Gemini to produce long-form content (1200-2000 words)
/// with proper structure, keywords, and guardrails
class ArticlePromptBuilder {
  
  /// Build the main article generation prompt
  static String buildPrompt({
    required String topic,
    required String audience,
    required String primaryKeyword,
    required List<String> secondaryKeywords,
  }) {
    final keywordsList = secondaryKeywords.join(', ');
    
    return '''
Eres un experto en creación de contenido SEO de tipo "Pillar Content" (Contenido Pilar) para emprendedores en Panamá. Tu objetivo es generar la guía definitiva sobre el tema propuesto.

=== TEMA ===
$topic

=== AUDIENCIA ===
$audience

=== PALABRAS CLAVE ===
Principal: $primaryKeyword
Secundarias: $keywordsList

=== REQUISITOS TÉCNICOS DE SALIDA ===
Debes devolver EXACTAMENTE un objeto JSON con esta estructura (sin texto adicional):
{
  "title": "Título SEO (máx 60 chars, incluye palabra clave principal)",
  "slug": "slug-url-limpio-sin-tildes-con-guiones",
  "meta_description": "Descripción meta SEO de 155-160 caracteres con palabra clave principal",
  "keywords": ["palabra1", "palabra2", "..."],
  "content_markdown": "Contenido completo en Markdown"
}

=== REGLAS DE CONTENIDO (Pillar Content) ===
1. Longitud: 2200-2800 palabras (Mínimo absoluto: 1800).
2. Estructura H2: Mínimo 10 secciones con encabezados H2.
3. Estructura H3: Al menos 4 sub-secciones internas con encabezados H3.
4. Tablas: Incluir al menos 2 tablas en formato Markdown (ej: comparativa de costos, pasos vs tiempo, requisitos por tipo).
5. Listas: Al menos 2 listas numeradas detalladas de pasos.
6. Errores Comunes: Una sección dedicada a "Errores comunes a evitar".
7. Checklist: Una sección de "Checklist descargable/ejecutable" usando sintaxis de casillas Markdown (- [ ]).
8. FAQ: Una sección de "Preguntas Frecuentes" con exactamente 6 preguntas y respuestas claras.
9. Enlazado Interno: Al final del artículo, añade una sección "Enlaces recomendados de Empodérate" sugiriendo 3-6 rutas internas como: /rrhh, /contabilidad, /tramites, /blog, /herramientas (basado en la relevancia del tema).

=== SEO ON-PAGE ===
- Palabra clave principal en: Título, primer párrafo, al menos 3 encabezados H2 y conclusión.
- Incluir "Panamá" de forma natural en el contexto.
- Meta description persuasiva de 155-160 caracteres.

=== GUARDRAILS & CALIDAD ===
- NO inventar leyes exactas ni artículos del Código de Trabajo si no tienes la fuente confirmada.
- Usar lenguaje general tipo "según requisitos vigentes" o "consulta fuentes oficiales" para temas sensibles.
- Tono: Profesional, experto, pero accesible.
- TODO el contenido debe ser relevante para el contexto de Panamá.
''';
  }

  /// Parse the JSON response from Gemini
  static Map<String, dynamic>? parseArticleResponse(String response) {
    try {
      // Try to extract JSON from response (in case there's extra text)
      final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(response);
      if (jsonMatch == null) return null;
      
      final jsonStr = jsonMatch.group(0)!;
      return Map<String, dynamic>.from(
        const JsonDecoder().convert(jsonStr) as Map
      );
    } catch (e) {
      print('Error parsing article JSON: $e');
      return null;
    }
  }
}

