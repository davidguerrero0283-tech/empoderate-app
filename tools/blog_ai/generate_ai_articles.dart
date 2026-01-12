/// Blog AI Article Generator
/// 
/// Generates SEO-optimized blog articles using Gemini API
/// 
/// Usage:
///   $env:GEMINI_API_KEY="your-key"
///   dart run tools/blog_ai/generate_ai_articles.dart --count=1

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'gemini_client.dart';
import 'article_prompt.dart';

void main(List<String> args) async {
  print('''
╔══════════════════════════════════════════════════════════════╗
║     EMPODÉRATE - Blog AI Article Generator (Gemini)          ║
╚══════════════════════════════════════════════════════════════╝
''');

  // Parse arguments with robust parser
  final List<String> cleanArgs = args.where((arg) => arg != '--').toList();
  final count = _parseCount(cleanArgs);
  final dryRun = cleanArgs.contains('--dry-run');
  
  if (cleanArgs.contains('--help') || cleanArgs.contains('-h')) {
    _printHelp();
    return;
  }

  // Fixed topics path relative to project root
  final topicsPath = 'tools/blog_ai/topics_seed.json';
  final topicsFile = File(topicsPath);
  
  try {
    // Validate topics file exists
    if (!topicsFile.existsSync()) {
      throw Exception('''
❌ topics_seed.json NOT FOUND!
   Expected at: ${topicsFile.absolute.path}
''');
    }

    // Load and validate topics
    final topicsContent = topicsFile.readAsStringSync();
    if (topicsContent.trim().isEmpty) throw Exception('topics_seed.json is EMPTY!');
    
    final topicsJson = jsonDecode(topicsContent) as List;
    if (topicsJson.isEmpty) throw Exception('topics_seed.json has 0 topics!');
    
    final topics = topicsJson.cast<Map<String, dynamic>>();
    
    // Create output directory
    final draftsDir = Directory('blog_drafts');
    draftsDir.createSync(recursive: true);

    // Initialize Gemini client (will throw if no API key)
    GeminiClient? client;
    if (!dryRun) {
      try {
        client = GeminiClient();
        await client.init();
      } catch (e) {
        print('   ⚠️ Gemini init failed (missing key or network). Switching to FALLBACK mode.');
        client?.close();
        client = null;
      }
    }

    // ═══════════════════════════════════════════════════════════════
    // DIAGNOSTIC OUTPUT
    // ═══════════════════════════════════════════════════════════════
    print('┌─────────────────────────────────────────────────────────────┐');
    print('│ DIAGNOSTIC INFO                                             │');
    print('├─────────────────────────────────────────────────────────────┤');
    print('│ GEMINI_MODEL (env): ${Platform.environment['GEMINI_MODEL'] ?? "(not set)"}');
    print('│ GEMINI_MAX_OUTPUT_TOKENS (env): ${Platform.environment['GEMINI_MAX_OUTPUT_TOKENS'] ?? "(not set)"}');
    print('│ count_final: $count');
    print('│ dry_run: $dryRun');
    if (client != null) {
      print('│ selected_model: ${client.model}');
      print('│ max_tokens: ${client.maxOutputTokens}');
    }
    print('│ output_dir: ${draftsDir.absolute.path}');
    print('└─────────────────────────────────────────────────────────────┘');
    print('');

    // Track generated articles for index
    final generatedArticles = <Map<String, dynamic>>[];
    final _rand = Random();
    
    // 1. Shuffle topics for variety
    topics.shuffle(_rand);
    
    // Load existing index to check for duplicates
    final indexFile = File('blog_drafts/_index.json');
    List<Map<String, dynamic>> existingIndex = [];
    if (indexFile.existsSync()) {
      try {
        existingIndex = (jsonDecode(indexFile.readAsStringSync()) as List).cast<Map<String, dynamic>>();
      } catch (_) {}
    }

    print('📝 Generating $count article(s)...');
    if (dryRun) print('   (DRY RUN - no API calls)');
    print('');
    
    // Topics usage tracking for this run
    final Set<String> usedTopicIds = {};
    
    for (var i = 0; i < count; i++) {
        // 2. Round-robin selection
        final topicIndex = i % topics.length;
        final topic = topics[topicIndex];
        final topicTitle = topic['topic'] as String;
        final topicId = topic['primary_keyword'] as String? ?? topicTitle; // Use primary keyword as ID or title

        // 3. Skip if we have enough topics but this one was already used in this run?
        // Actually, if count > topics.length we MUST reuse. 
        // But if count < topics.length we shouldn't reuse. Shuffle guarantees that for the first N.
        
        print('─' * 60);
        print('📝 [${i + 1}/$count] Generating: $topicTitle');
        if (topicIndex != i) print('   (Reusing topic #${topicIndex + 1})');

        // 4. Generate Unique Slug
        var slug = _generateSlug(topicTitle, 0); // Start with clean slug
        int suffix = 1;
        while (_slugExists(slug, existingIndex, generatedArticles)) {
             slug = _generateSlug(topicTitle, suffix++);
        }
        print('   🔑 Slug: $slug');

        Map<String, dynamic> articleData = {};
        bool usedFallback = false;

        if (dryRun) {
            final pk = topic['primary_keyword'] as String? ?? topicTitle;
            final sk = (topic['secondary_keywords'] as List?)?.cast<String>() ?? [];
            
            articleData = _buildFallbackArticle(
              topic: topicTitle,
              primaryKeyword: pk,
              secondaryKeywords: sk,
              slugOverride: slug,
            );
            articleData['source'] = 'fallback'; // Mock source
        } else {
            // ... API CALL LOGIC ...
             // Initial throttle for first item or previous cooldown
            if (i == 0) {
                print('   ⏳ Initial throttle (1s)...');
                await Future.delayed(const Duration(milliseconds: 1000));
            }

            final currentPrompt = ArticlePromptBuilder.buildPrompt(
                topic: topicTitle,
                audience: topic['audience'] as String? ?? 'emprendedores',
                primaryKeyword: topic['primary_keyword'] as String? ?? topicTitle,
                secondaryKeywords: (topic['secondary_keywords'] as List?)?.cast<String>() ?? [],
            );
            
            if (client != null) {
                print('   ⏳ Requesting Gemini content... (Model: ${client.model})');
                try {
                final response = await client.generateContent(currentPrompt);
                articleData = ArticlePromptBuilder.parseArticleResponse(response) ?? {};
                
                // Retry if failed parsing
                if (articleData.isEmpty || articleData['content'] == null) {
                    print('   ⚠️ JSON parsing failed. Retrying with stricter instructions...');
                    final stricterPrompt = currentPrompt + "\n\nCRITICAL: Return ONLY the JSON object. No markdown blocks.";
                    final secondResponse = await client.generateContent(stricterPrompt);
                    articleData = ArticlePromptBuilder.parseArticleResponse(secondResponse) ?? {};
                }
                
                if (articleData.isNotEmpty && articleData['content'] != null) {
                     print('   ✅ Gemini Success');
                     articleData['source'] = 'gemini';
                }
                } catch (e) {
                    print('   ❌ API Final Failure: $e');
                }
            } else {
                 print('   ⚠️ No Gemini client available. Skipping API call.');
            }
            
            // Check fallback need
            if (articleData.isEmpty || (articleData['content_markdown'] == null && articleData['content'] == null) || 
                ((articleData['content_markdown'] ?? articleData['content'] ?? '') as String).length < 100) {
                print('   ⚠️ Using FALLBACK SEO PREMIUM template');
                usedFallback = true;
                
                final pk = topic['primary_keyword'] as String? ?? topicTitle;
                final sk = (topic['secondary_keywords'] as List?)?.cast<String>() ?? [];
                
                articleData = _buildFallbackArticle(
                    topic: topicTitle,
                    primaryKeyword: pk,
                    secondaryKeywords: sk,
                    slugOverride: slug,
                );
                articleData['source'] = 'fallback';
            }
        }
        
        // Finalize Data
        final finalContent = articleData['content_markdown'] ?? articleData['content'] ?? '';
        articleData['content'] = finalContent;
        articleData['slug'] = slug; // Force unique slug
        articleData['topicId'] = topicId;
        articleData['imported'] = false;
        
        _saveArticle(articleData, slug, topicTitle, generatedArticles, usedFallback: usedFallback);
        usedTopicIds.add(topicId);

        // Cooldown between articles: 1500-2500ms
        if (!dryRun && i < count - 1) {
            final waitMs = 1500 + _rand.nextInt(1001);
            print('   ⏳ Cooldown: ${waitMs}ms...');
            await Future.delayed(Duration(milliseconds: waitMs));
        }
    }

    _updateIndex(generatedArticles);
    client?.close();

    print('\n✅ Done! Check blog_drafts/ for results.\n');

  } catch (e) {
    print('\n❌ Fatal error: $e');
    exit(1);
  }
}

int _parseCount(List<String> args) {
  for (var i = 0; i < args.length; i++) {
    final arg = args[i];
    if (arg.startsWith('--count=')) return int.tryParse(arg.substring(8)) ?? 1;
    if (arg == '--count' && i + 1 < args.length) return int.tryParse(args[i + 1]) ?? 1;
  }
  return 1;
}

String _generateSlug(String topic, int index) {
  final baseSlug = topic.toLowerCase()
      .replaceAll(RegExp(r'[áàäâ]'), 'a').replaceAll(RegExp(r'[éèëê]'), 'e')
      .replaceAll(RegExp(r'[íìïî]'), 'i').replaceAll(RegExp(r'[óòöô]'), 'o')
      .replaceAll(RegExp(r'[úùüû]'), 'u').replaceAll(RegExp(r'ñ'), 'n')
      .replaceAll(RegExp(r'[^a-z0-9\s]'), '').replaceAll(RegExp(r'\s+'), '-')
      .replaceAll(RegExp(r'-+'), '-').replaceAll(RegExp(r'^-|-$'), '');
  return '${baseSlug.length > 50 ? baseSlug.substring(0, 50) : baseSlug}-${index + 1}';
}

bool _slugExists(String slug, List<Map<String, dynamic>> existingIndex, List<Map<String, dynamic>> currentRun) {
  if (existingIndex.any((a) => a['slug'] == slug)) return true;
  if (currentRun.any((a) => a['slug'] == slug)) return true;
  return false;
}

Map<String, dynamic> _buildFallbackArticle({
  required String topic,
  required String primaryKeyword,
  required List<String> secondaryKeywords,
  String? slugOverride,
}) {
  final slug = slugOverride ?? _generateSlug(topic, 0);
  final meta = 'Guía completa sobre $topic en Panamá. Descubre los pasos esenciales, requisitos y consejos prácticos para optimizar tus resultados hoy mismo.';
  
  final sb = StringBuffer();
  
  // H1
  sb.writeln('# $topic');
  sb.writeln();
  
  // Intro (120-180 words)
  sb.writeln('Bienvenidos a esta guía detallada diseñada específicamente para el contexto empresarial de Panamá. Cuando hablamos de $primaryKeyword, nos referimos a uno de los pilares fundamentales para el crecimiento sostenido de cualquier proyecto en nuestro país. Entender los matices de este tema no solo es una ventaja competitiva, sino una necesidad en el mercado actual.');
  sb.writeln('Muchos emprendedores en Panamá se enfrentan a desafíos al intentar dominar $topic, pero con la información adecuada, el proceso se vuelve mucho más sencillo y eficiente. En las siguientes secciones, exploraremos desde los conceptos básicos hasta las estrategias avanzadas que te permitirán destacar. Nuestro objetivo con Empodérate es ofrecerte las herramientas necesarias para que tu camino sea exitoso y libre de obstáculos innecesarios.');
  sb.writeln('A lo largo de este artículo, desglosaremos cada punto crítico, asegurando que tengas una visión clara de cómo implementar estas recomendaciones hoy mismo.');
  sb.writeln();

  // 8 H2 Sections (180-260 words each)
  final sections = [
    'Importancia de optimizar $primaryKeyword en tu estrategia',
    'Requisitos fundamentales y normativa vigente en Panamá',
    'Estrategias clave para implementar $topic con éxito',
    'Cómo medir el impacto de tus acciones empresariales',
    'Herramientas recomendadas para la gestión de $topic',
    'Aspectos financieros y operativos a considerar',
    'Casos de éxito y mejores prácticas locales',
    'Futuro y tendencias de $topic en el mercado panameño',
  ];

  for (final sectionTitle in sections) {
    sb.writeln('## $sectionTitle');
    sb.writeln('Para profundizar en $sectionTitle, es vital reconocer que el mercado de Panamá tiene particularidades que no podemos ignorar. La implementación efectiva de $topic requiere una planificación meticulosa y un conocimiento profundo del entorno local. Al considerar $primaryKeyword, debemos evaluar no solo el costo inmediato, sino el valor a largo plazo que aporta a nuestra organización.');
    sb.writeln('Existen múltiples factores que influyen en cómo se percibe y se ejecuta este proceso. Por ejemplo, el uso de ${secondaryKeywords.isNotEmpty ? secondaryKeywords[0] : 'estrategias locales'} permite una mejor adaptación a las necesidades de nuestros clientes. Además, la capacitación constante del equipo asegura que los estándares de calidad se mantengan siempre en los niveles más altos exigidos por las autoridades y el público general.');
    sb.writeln('No podemos olvidar que la tecnología juega un papel crucial. Herramientas digitales modernas facilitan la automatización de tareas relacionadas con $topic, permitiendo que el emprendedor se enfoque en lo que realmente importa: escalar su negocio. La integración de sistemas eficientes reduce el margen de error y optimiza el uso de recursos, algo fundamental en el competitivo clima de negocios actual en ciudades como Panamá y el resto de las provincias.');
    sb.writeln('Finalmente, es recomendable mantener una comunicación abierta con expertos en la materia. Las tendencias cambian y estar actualizado te permitirá pivotar rápidamente ante cualquier imprevisto del mercado.');
    sb.writeln();
  }

  // 2-3 Numbered Lists
  sb.writeln('## Pasos prácticos para comenzar hoy mismo');
  sb.writeln('Sigue esta lista paso a paso para asegurar una implementación sin errores:');
  sb.writeln('1. **Evaluación inicial**: Analiza tu situación actual respecto a $topic.');
  sb.writeln('2. **Recopilación de requisitos**: Asegúrate de tener toda la documentación necesaria según las leyes de Panamá.');
  sb.writeln('3. **Definición de objetivos**: Establece metas claras y medibles para tu estrategia de $primaryKeyword.');
  sb.writeln('4. **Ejecución controlada**: Comienza con pruebas pequeñas antes de un despliegue total.');
  sb.writeln('5. **Monitoreo y ajuste**: Revisa los resultados y ajusta tácticas según sea necesario.');
  sb.writeln();

  sb.writeln('## Optimización de procesos internos');
  sb.writeln('Para maximizar el rendimiento, considera estos puntos adicionales:');
  sb.writeln('1. Capacitar a tu personal en el manejo de $topic.');
  sb.writeln('2. Utilizar plataformas digitales para el seguimiento de $primaryKeyword.');
  sb.writeln('3. Realizar auditorías periódicas para detectar cuellos de botella.');
  sb.writeln();

  // Common Errors
  sb.writeln('## Errores comunes a evitar');
  sb.writeln('A continuación, enumeramos los fallos más frecuentes que cometen los emprendedores en el país:');
  sb.writeln('- **Falta de documentación**: No tener los registros al día puede acarrear multas innecesarias.');
  sb.writeln('- **Ignorar la competencia**: No observar cómo otros manejan $topic te quita perspectiva de mercado.');
  sb.writeln('- **Mala gestión del tiempo**: Subestimar los plazos de respuesta de las entidades oficiales en Panamá.');
  sb.writeln('- **No usar herramientas adecuadas**: Seguir procesos manuales cuando existen soluciones digitales eficientes.');
  sb.writeln();

  // Rapid Checklist
  sb.writeln('## Checklist rápida para tu negocio');
  sb.writeln('- [ ] ¿Tienes claros los objetivos de $topic?');
  sb.writeln('- [ ] ¿Cuentas con las palabras clave secundarias como ${secondaryKeywords.length > 1 ? secondaryKeywords[1] : 'referencias'} listas?');
  sb.writeln('- [ ] ¿Has consultado las fuentes oficiales panameñas?');
  sb.writeln('- [ ] ¿El equipo conoce sus responsabilidades en este proceso?');
  sb.writeln('- [ ] ¿Tienes una copia de seguridad de toda tu información crítica?');
  sb.writeln();

  // FAQ (5 questions)
  sb.writeln('## Preguntas frecuentes (FAQ)');
  sb.writeln('### ¿Es obligatorio cumplir con todos los requisitos de $topic?');
  sb.writeln('Sí, para operar de manera legal y segura en Panamá, es fundamental seguir la normativa vigente.');
  sb.writeln('### ¿Cuánto tiempo toma ver resultados con $primaryKeyword?');
  sb.writeln('Depende del sector, pero por lo general se observan mejoras significativas tras los primeros 3 a 6 meses de aplicación constante.');
  sb.writeln('### ¿Necesito un experto para manejar mi estrategia de $topic?');
  sb.writeln('Aunque puedes iniciar solo, contar con asesoría profesional siempre reduce riesgos y acelera el crecimiento.');
  sb.writeln('### ¿Dónde puedo encontrar más información oficial?');
  sb.writeln('Recomendamos visitar los portales web de las instituciones gubernamentales correspondientes en Panamá.');
  sb.writeln('### ¿Empodérate me ayuda con la gestión de mi negocio?');
  sb.writeln('Absolutamente, nuestra plataforma está diseñada para simplificar todos estos procesos para los emprendedores panameños.');
  sb.writeln();

  // Conclusion
  sb.writeln('## Conclusión');
  sb.writeln('Dominar $topic es un viaje que requiere paciencia y dedicación. Sin embargo, los frutos de una gestión adecuada de $primaryKeyword se verán reflejados en la solidez y rentabilidad de tu empresa. No dejes para mañana lo que puedes empezar a optimizar hoy con las herramientas correctas.');
  sb.writeln('Te invitamos a explorar más recursos en **Empodérate**, tu aliado estratégico en el camino del emprendimiento en Panamá. Juntos, haremos que tu negocio alcance un nuevo nivel de excelencia.');
  sb.writeln();

  // Disclaimer
  sb.writeln('---');
  sb.writeln('*Nota: Este artículo es informativo y no constituye asesoría legal, contable o profesional definitiva. Se recomienda siempre consultar con fuentes oficiales y profesionales calificados en Panamá para casos específicos.*');

  return {
    'title': topic,
    'slug': slug,
    'meta_description': meta,
    'keywords': [primaryKeyword, ...secondaryKeywords],
    'category': 'General',
    'tags': ['Panamá', 'Emprendimiento'],
    'readTime': 12,
    'content_markdown': sb.toString(),
  };
}

void _saveArticle(Map<String, dynamic> data, String slug, String source, List<Map<String, dynamic>> list, {bool usedFallback = false}) {
  final title = data['title'] as String? ?? source;
  final now = DateTime.now().toIso8601String();
  final content = data['content_markdown'] ?? data['content'] ?? '';
  // New fields
  final topicId = data['topicId'] ?? '';
  final src = data['source'] ?? 'unknown';
  final imported = data['imported'] ?? false;
  
  File('blog_drafts/$slug.md').writeAsStringSync('''---
title: "$title"
slug: "$slug"
status: draft
generated_at: "$now"
used_fallback: $usedFallback
topic_id: "$topicId"
source: "$src"
imported: $imported
---

$content
''');

  final jsonData = {
      ...data, 
      'status': 'draft', 
      'generatedAt': now, 
      'usedFallback': usedFallback,
      'topicId': topicId,
      'source': src,
      'imported': imported,
  };

  File('blog_drafts/$slug.json').writeAsStringSync(const JsonEncoder.withIndent('  ').convert(jsonData));
  
  list.add({'slug': slug, 'title': title, 'status': 'draft', 'usedFallback': usedFallback, 'topicId': topicId, 'imported': imported});
  print('   ✅ Saved: blog_drafts/$slug.md');
}

void _updateIndex(List<Map<String, dynamic>> news) {
  final file = File('blog_drafts/_index.json');
  List<Map<String, dynamic>> index = [];
  if (file.existsSync()) {
    try {
      index = (jsonDecode(file.readAsStringSync()) as List).cast<Map<String, dynamic>>();
    } catch (_) {}
  }

  for (final n in news) {
    final existingIdx = index.indexWhere((a) => a['slug'] == n['slug']);
    if (existingIdx != -1) {
      // Update existing entry
      index[existingIdx] = {...index[existingIdx], ...n, 'status': 'draft'};
    } else {
      // Add new entry
      index.add(n);
    }
  }

  file.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(index));
  print('📋 Updated index: blog_drafts/_index.json');
}

void _printHelp() {
  print('Usage: dart run tools/blog_ai/generate_ai_articles.dart [--count=N] [--dry-run]');
}
