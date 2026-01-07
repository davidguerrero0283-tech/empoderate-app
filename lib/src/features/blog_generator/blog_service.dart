import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../models/blog_article.dart';

// --- Advanced Blog Models ---

class GeneratedArticleData {
  final String title;
  final String subtitle;
  final String category;
  final String date;
  final String coverImage;
  final List<String> keywords;
  final List<ArticleSection> sections;
  final SeoData seo;
  final String summary;
  final List<String> related;

  GeneratedArticleData({
    required this.title,
    required this.subtitle,
    required this.category,
    required this.date,
    required this.coverImage,
    required this.keywords,
    required this.sections,
    required this.seo,
    required this.summary,
    required this.related,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'subtitle': subtitle,
        'category': category,
        'date': date,
        'coverImage': coverImage,
        'keywords': keywords,
        'sections': sections.map((s) => s.toJson()).toList(),
        'seo': seo.toJson(),
        'summary': summary,
        'related': related,
      };
}

class ArticleSection {
  final String title;
  final String text;
  final List<String>? items;

  ArticleSection({required this.title, required this.text, this.items});

  Map<String, dynamic> toJson() => {
        'title': title,
        'text': text,
        if (items != null) 'items': items,
      };
}

class SeoData {
  final String metaTitle;
  final String metaDescription;
  final List<String> keywords;
  final String slug;

  SeoData({
    required this.metaTitle,
    required this.metaDescription,
    required this.keywords,
    required this.slug,
  });

  Map<String, dynamic> toJson() => {
        'metaTitle': metaTitle,
        'metaDescription': metaDescription,
        'keywords': keywords,
        'slug': slug,
      };
}

// --- Blog Generator Service ---

class BlogGeneratorService {
  // 1. GENERADOR AUTOMÁTICO DE ARTÍCULOS (Simulado con lógica determinista por ahora)
  GeneratedArticleData generateArticleAI(String topic, String category) {
    // En un caso real, esto llamaría a una API de LLM. Aquí simulamos la estructura.
    final title = 'Guía completa sobre $topic en Panamá';
    final subtitle = 'Estrategias clave para el éxito empresarial';
    final date = DateTime.now().toIso8601String();
    
    final keywords = _extractSmartKeywords(topic, category);
    final slug = _generateSlug(title, category);
    
    final sections = [
      ArticleSection(
        title: 'Introducción',
        text: 'En el dinámico entorno empresarial de Panamá, dominar el arte de $topic es fundamental para cualquier emprendedor. Esta guía explora los conceptos esenciales...',
      ),
      ArticleSection(
        title: 'Explicación Detallada',
        text: 'Para comprender a fondo $topic, debemos analizar sus componentes principales. En primer lugar...',
      ),
      ArticleSection(
        title: 'Ejemplos Prácticos',
        text: 'Veamos cómo empresas locales aplican esto:',
        items: [
          'Caso de éxito en Retail: Optimización de $topic.',
          'Aplicación en Servicios: Mejora del flujo de trabajo.',
          'Startups tecnológicas: Innovando con $topic.'
        ],
      ),
      ArticleSection(
        title: 'Pasos para aplicar en tu negocio',
        text: 'Sigue estos pasos prácticos:',
        items: [
          'Realiza un diagnóstico actual.',
          'Define objetivos claros relacionados con $topic.',
          'Implementa herramientas de medición.',
          'Capacita a tu equipo.',
          'Revisa y ajusta mensualmente.'
        ],
      ),
    ];

    final summary = _generateSummary(sections);
    
    final seo = SeoData(
      metaTitle: '$title | Blog Empodérate',
      metaDescription: 'Descubre todo sobre $topic en Panamá. Guía práctica para emprendedores con ejemplos y pasos a seguir.',
      keywords: keywords,
      slug: slug,
    );

    return GeneratedArticleData(
      title: title,
      subtitle: subtitle,
      category: category,
      date: date,
      coverImage: 'https://images.unsplash.com/photo-1519389950473-47ba0277781c', // Placeholder smart
      keywords: keywords,
      sections: sections,
      seo: seo,
      summary: summary,
      related: [], // Se llenaría con el motor de relacionados
    );
  }

  String generateSmartBlocks(String topic, String objective, String level) {
    // Generate content based on inputs
    StringBuffer buffer = StringBuffer();
    
    buffer.writeln("<!-- Bloques Generados por IA -->");
    buffer.writeln("<!-- Tema: $topic | Objetivo: $objective | Nivel: $level -->\n");

    // Introducción
    buffer.writeln("## Introducción");
    buffer.writeln("En este artículo abordaremos **$topic** con un enfoque **$level**. Nuestro objetivo principal es $objective, brindándote las herramientas necesarias para dominar este aspecto en tu negocio.\n");

    // Desarrollo según nivel
    buffer.writeln("## Conceptos Clave ($level)");
    if (level.toLowerCase() == 'básico') {
      buffer.writeln("Primero, definamos los fundamentos de $topic. Es crucial entender que...");
    } else if (level.toLowerCase() == 'intermedio') {
      buffer.writeln("Profundizando en $topic, analizaremos estrategias que van más allá de lo básico, como...");
    } else {
      buffer.writeln("Para expertos en $topic, las métricas avanzadas y la optimización continua son la clave. Considera implementar...");
    }
    buffer.writeln("");

    // Bloque Checklist/Pasos
    buffer.writeln("## Pasos Prácticos");
    buffer.writeln("1. Realiza un diagnóstico inicial.");
    buffer.writeln("2. Establece KPIs claros para $topic.");
    buffer.writeln("3. Ejecuta la estrategia definida.");
    buffer.writeln("4. Mide y ajusta según resultados.\n");

    // Tips Finales
    buffer.writeln("## Tips de Expertos");
    buffer.writeln("- **Tip 1:** Mantén la consistencia.");
    buffer.writeln("- **Tip 2:** Actualízate constantemente sobre $topic.");
    
    return buffer.toString();
  }

  // 2. SISTEMA SEO INTERNO
  String _generateSlug(String title, String category) {
    String cleanTitle = title.toLowerCase()
        .replaceAll(RegExp(r'[áàäâ]'), 'a')
        .replaceAll(RegExp(r'[éèëê]'), 'e')
        .replaceAll(RegExp(r'[íìïî]'), 'i')
        .replaceAll(RegExp(r'[óòöô]'), 'o')
        .replaceAll(RegExp(r'[úùüû]'), 'u')
        .replaceAll(RegExp(r'ñ'), 'n')
        .replaceAll(RegExp(r'[^a-z0-9\s]'), '') // Elimina caracteres especiales
        .trim()
        .replaceAll(RegExp(r'\s+'), '-'); // Espacios a guiones
    
    String cleanCategory = category.toLowerCase()
        .replaceAll(RegExp(r'\s+&\s+'), '-') // " & " a "-"
        .replaceAll(RegExp(r'\s+'), '-');

    return '/blog/$cleanCategory/$cleanTitle';
  }

  // 3. RESUMEN AUTOMÁTICO
  String _generateSummary(List<ArticleSection> sections) {
    // Toma la introducción y parte de la explicación para un resumen conciso
    String intro = sections.first.text;
    String snippet = intro.length > 150 ? '${intro.substring(0, 150)}...' : intro;
    return 'Resumen: $snippet Descubre los pasos clave y ejemplos prácticos para potenciar tu negocio hoy mismo.';
  }

  // 4. MOTOR DE ARTÍCULOS RELACIONADOS
  List<BlogArticle> getRelatedArticles(BlogArticle currentArticle, List<BlogArticle> allArticles) {
    return allArticles.where((article) {
      if (article.id == currentArticle.id) return false;
      
      bool sameCategory = article.category == currentArticle.category;
      
      // Intersección de keywords (al menos 2 coincidentes)
      var currentKeywordsSet = currentArticle.keywords.map((k) => k.toLowerCase()).toSet();
      var otherKeywordsSet = article.keywords.map((k) => k.toLowerCase()).toSet();
      int commonKeywords = currentKeywordsSet.intersection(otherKeywordsSet).length;

      return sameCategory || commonKeywords >= 2;
    }).take(6).toList(); // Retorna máximo 6
  }

  // 5. PALABRAS CLAVE INTELIGENTES (Extracción simulada)
  List<String> _extractSmartKeywords(String topic, String category) {
    final baseKeywords = ['Panamá', 'Emprendimiento', 'Negocios', 'Pymes'];
    final topicKeywords = topic.split(' ').where((w) => w.length > 3).toList();
    
    // Aquí iría lógica más compleja de TF-IDF o similar
    return [
      ...baseKeywords,
      category,
      ...topicKeywords,
      'Estrategia',
      'Crecimiento'
    ].map((e) => e.toLowerCase()).toSet().toList(); // Unicos
  }
}
