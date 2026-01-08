import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/post_draft_model.dart';

class ContentService {
  static final ContentService instance = ContentService._();
  ContentService._();

  static const String _draftsKey = 'blog_drafts';
  List<PostDraft> _drafts = [];

  // Initialize and load drafts
  Future<void> init() async {
    await loadDrafts();
  }

  // Load all drafts from storage
  Future<void> loadDrafts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final draftsJson = prefs.getString(_draftsKey);
      
      if (draftsJson != null) {
        final List<dynamic> decoded = json.decode(draftsJson);
        _drafts = decoded.map((e) => PostDraft.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      print('Error loading drafts: $e');
      _drafts = [];
    }
  }

  // Save all drafts to storage
  Future<void> saveDrafts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = json.encode(_drafts.map((e) => e.toJson()).toList());
      await prefs.setString(_draftsKey, encoded);
    } catch (e) {
      print('Error saving drafts: $e');
    }
  }

  // Get all drafts
  List<PostDraft> getAllDrafts() {
    return List.from(_drafts);
  }

  // Get draft by ID
  PostDraft? getDraftById(String id) {
    try {
      return _drafts.firstWhere((d) => d.id == id);
    } catch (e) {
      return null;
    }
  }

  // Create new draft
  Future<PostDraft> createDraft(PostDraft draft) async {
    _drafts.add(draft);
    await saveDrafts();
    return draft;
  }

  // Update existing draft
  Future<void> updateDraft(PostDraft updated) async {
    final index = _drafts.indexWhere((d) => d.id == updated.id);
    if (index != -1) {
      _drafts[index] = updated.copyWith(updatedAt: DateTime.now());
      await saveDrafts();
    }
  }

  // Delete draft
  Future<void> deleteDraft(String id) async {
    _drafts.removeWhere((d) => d.id == id);
    await saveDrafts();
  }

  // Publish draft
  Future<void> publishDraft(String id) async {
    final draft = getDraftById(id);
    if (draft != null) {
      await updateDraft(draft.copyWith(
        status: 'published',
        updatedAt: DateTime.now(),
      ));
    }
  }

  // Unpublish (revert to draft)
  Future<void> unpublishDraft(String id) async {
    final draft = getDraftById(id);
    if (draft != null) {
      await updateDraft(draft.copyWith(
        status: 'draft',
        updatedAt: DateTime.now(),
      ));
    }
  }

  // Generate mock content based on keyword/theme
  Map<String, String> generateMockContent(String keyword) {
    final title = 'Guía Completa: $keyword para Tu Negocio';
    final slug = PostDraft.generateSlug(title);
    
    final excerpt = 'Descubre cómo $keyword puede transformar tu negocio. '
        'En esta guía completa, exploramos las mejores prácticas y consejos prácticos.';
    
    final content = '''
# $title

## Introducción

$keyword es fundamental para el éxito de cualquier negocio moderno. En esta guía, exploraremos los aspectos clave que necesitas conocer.

## ¿Por qué es importante $keyword?

Los emprendedores exitosos saben que $keyword no es opcional - es esencial. Aquí te explicamos por qué:

- **Mejora la eficiencia operativa**: Optimiza tus procesos
- **Reduce costos**: Ahorra tiempo y dinero
- **Aumenta la competitividad**: Destaca en tu mercado

## Pasos para Implementar $keyword

### 1. Evaluación Inicial
Antes de empezar, evalúa tu situación actual y define objetivos claros.

### 2. Planificación Estratégica
Crea un plan detallado que incluya plazos, recursos y responsables.

### 3. Ejecución
Implementa tu estrategia paso a paso, monitoreando el progreso.

### 4. Medición y Ajuste
Analiza resultados y realiza ajustes según sea necesario.

## Errores Comunes a Evitar

- No planificar adecuadamente
- Ignorar las métricas
- No involucrar al equipo
- Esperar resultados inmediatos

## Conclusión

Implementar $keyword correctamente puede marcar la diferencia entre el éxito y el fracaso. Comienza hoy y verás los resultados.

¿Necesitas ayuda personalizada? En Empodérate estamos para apoyarte en cada paso del camino.
''';

    final imagePrompt = 'Imagen profesional de negocios mostrando $keyword, '
        'estilo moderno, colores corporativos azul y dorado, alta calidad';

    return {
      'title': title,
      'slug': slug,
      'excerpt': excerpt,
      'content': content,
      'imagePrompt': imagePrompt,
    };
  }

  // Export draft to HTML
  String exportToHTML(PostDraft draft) {
    return '''
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="${draft.excerpt}">
    <meta name="keywords" content="${draft.tags.join(', ')}">
    <title>${draft.title} | Empodérate</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            line-height: 1.6;
            color: #333;
            background: #f5f5f5;
        }
        .container {
            max-width: 800px;
            margin: 0 auto;
            padding: 20px;
            background: white;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        header {
            border-bottom: 3px solid #D4AF37;
            padding-bottom: 20px;
            margin-bottom: 30px;
        }
        h1 {
            color: #001220;
            font-size: 2.5em;
            margin-bottom: 10px;
        }
        .meta {
            color: #666;
            font-size: 0.9em;
        }
        .featured-image {
            width: 100%;
            height: 400px;
            object-fit: cover;
            margin: 20px 0;
            border-radius: 8px;
        }
        .content {
            font-size: 1.1em;
        }
        .content h2 {
            color: #001220;
            margin-top: 30px;
            margin-bottom: 15px;
        }
        .content h3 {
            color: #D4AF37;
            margin-top: 20px;
            margin-bottom: 10px;
        }
        .content p {
            margin-bottom: 15px;
        }
        .content ul, .content ol {
            margin-left: 30px;
            margin-bottom: 15px;
        }
        .tags {
            margin-top: 40px;
            padding-top: 20px;
            border-top: 1px solid #eee;
        }
        .tag {
            display: inline-block;
            background: #00E5FF;
            color: white;
            padding: 5px 15px;
            border-radius: 20px;
            margin-right: 10px;
            margin-bottom: 10px;
            font-size: 0.9em;
        }
        footer {
            margin-top: 50px;
            padding-top: 20px;
            border-top: 2px solid #D4AF37;
            text-align: center;
            color: #666;
        }
    </style>
</head>
<body>
    <div class="container">
        <header>
            <h1>${draft.title}</h1>
            <div class="meta">
                Publicado el ${_formatDate(draft.updatedAt)} | Por Empodérate
            </div>
        </header>

        ${draft.imageUrl.isNotEmpty ? '<img src="${draft.imageUrl}" alt="${draft.title}" class="featured-image">' : ''}

        <div class="content">
            ${_markdownToHTML(draft.content)}
        </div>

        ${draft.tags.isNotEmpty ? '''
        <div class="tags">
            ${draft.tags.map((tag) => '<span class="tag">$tag</span>').join('')}
        </div>
        ''' : ''}

        <footer>
            <p>&copy; ${DateTime.now().year} Empodérate. Todos los derechos reservados.</p>
            <p>Visita <a href="https://empoderate.com" style="color: #D4AF37;">empoderate.com</a></p>
        </footer>
    </div>
</body>
</html>
''';
  }

  // Simple markdown to HTML converter
  String _markdownToHTML(String markdown) {
    String html = markdown;
    
    // Headers
    html = html.replaceAllMapped(RegExp(r'^### (.+)$', multiLine: true), (m) => '<h3>${m[1]}</h3>');
    html = html.replaceAllMapped(RegExp(r'^## (.+)$', multiLine: true), (m) => '<h2>${m[1]}</h2>');
    html = html.replaceAllMapped(RegExp(r'^# (.+)$', multiLine: true), (m) => '<h1>${m[1]}</h1>');
    
    // Bold and italic
    html = html.replaceAllMapped(RegExp(r'\*\*(.+?)\*\*'), (m) => '<strong>${m[1]}</strong>');
    html = html.replaceAllMapped(RegExp(r'\*(.+?)\*'), (m) => '<em>${m[1]}</em>');
    
    // Lists
    html = html.replaceAllMapped(RegExp(r'^- (.+)$', multiLine: true), (m) => '<li>${m[1]}</li>');
    html = html.replaceAllMapped(RegExp(r'(<li>.*</li>)', multiLine: true, dotAll: true), (m) => '<ul>${m[0]}</ul>');
    
    // Paragraphs
    html = html.split('\n\n').map((p) {
      if (p.trim().isEmpty || p.startsWith('<h') || p.startsWith('<ul')) return p;
      return '<p>$p</p>';
    }).join('\n');
    
    return html;
  }

  String _formatDate(DateTime date) {
    final months = ['enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
                   'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'];
    return '${date.day} de ${months[date.month - 1]} de ${date.year}';
  }

  // Generate Index HTML for the blog
  String generateIndexHTML(List<PostDraft> posts) {
    // Sort by date desc
    posts.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    final listItems = posts.map((post) => '''
        <article class="post-card">
            ${post.imageUrl.isNotEmpty ? '<img src="${post.imageUrl}" alt="${post.title}" class="card-image">' : ''}
            <div class="card-content">
                <h2><a href="${post.slug}.html">${post.title}</a></h2>
                <div class="meta">${_formatDate(post.updatedAt)}</div>
                <p>${post.excerpt}</p>
                <a href="${post.slug}.html" class="read-more">Leer más &rarr;</a>
            </div>
        </article>
    ''').join('\n');

    return '''
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Blog Empodérate | Recursos para Emprendedores</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: #fdfdfd;
            color: #333;
        }
        nav {
            background: #001220;
            padding: 20px;
            text-align: center;
        }
        nav h1 { color: white; }
        .container {
            max-width: 1000px;
            margin: 40px auto;
            padding: 0 20px;
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            gap: 30px;
        }
        .post-card {
            background: white;
            border-radius: 12px;
            overflow: hidden;
            box-shadow: 0 4px 15px rgba(0,0,0,0.05);
            transition: transform 0.3s;
        }
        .post-card:hover { transform: translateY(-5px); }
        .card-image {
            width: 100%;
            height: 200px;
            object-fit: cover;
        }
        .card-content { padding: 20px; }
        .card-content h2 { font-size: 1.4em; margin-bottom: 10px; }
        .card-content h2 a { text-decoration: none; color: #001220; }
        .meta { color: #888; font-size: 0.9em; margin-bottom: 15px; }
        .read-more {
            display: inline-block;
            margin-top: 15px;
            color: #D4AF37;
            text-decoration: none;
            font-weight: bold;
        }
    </style>
</head>
<body>
    <nav>
        <h1>Blog Empodérate</h1>
    </nav>
    <div class="container">
        $listItems
    </div>
</body>
</html>
''';
  }

  // Generate Sitemap XML
  String generateSitemapXML(List<PostDraft> posts) {
    final urls = posts.map((post) => '''
    <url>
        <loc>https://empoderate.com/blog/${post.slug}.html</loc>
        <lastmod>${post.updatedAt.toIso8601String().split('T')[0]}</lastmod>
        <changefreq>monthly</changefreq>
        <priority>0.8</priority>
    </url>
    ''').join('\n');

    return '''
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
    <url>
        <loc>https://empoderate.com/blog/index.html</loc>
        <changefreq>daily</changefreq>
        <priority>1.0</priority>
    </url>
$urls
</urlset>
''';
  }
}
