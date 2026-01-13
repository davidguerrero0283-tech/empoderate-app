// SEO Blog Generator V2 - Reads from initial_articles.dart (text parsing)
// Run with: dart run tools/generate_seo_blog_smart.dart

import 'dart:io';
import 'dart:convert';

// ============================================
// CONFIGURACIÓN - App en Firebase, Blog en Hostinger
// ============================================
// App Flutter en Firebase (subdominio)
const appUrl = 'https://app.empoderate.com';

// Blog en Hostinger (dominio principal - mejor para SEO)
const blogBaseUrl = 'https://empoderate.com/blog';

// ============================================


// Simple article data structure
class ArticleData {
  final String id;
  final String title;
  final String description;
  final String category;
  final String imageUrl;
  final String metaTitle;
  final String metaDescription;
  final List<String> keywords;
  final String contentRaw;
  
  ArticleData({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.imageUrl,
    required this.metaTitle,
    required this.metaDescription,
    required this.keywords,
    required this.contentRaw,
  });
}

// Parse initial_articles.dart file
Future<List<ArticleData>> parseArticlesFile() async {
  final file = File('lib/src/features/blog/data/initial_articles.dart');
  final content = await file.readAsString();
  
  final articles = <ArticleData>[];
  final articlesPattern = RegExp(
    r"BlogArticle\(([\s\S]+?)\n  \),",
    multiLine: true,
  );
  
  for (final match in articlesPattern.allMatches(content)) {
    final articleBlock = match.group(1)!;
    
    // Extract fields using regex
    String extractField(String fieldName) {
      final pattern = RegExp("$fieldName: '([^']+)'");
      final match = pattern.firstMatch(articleBlock);
      return match?.group(1) ?? '';
    }
    
    String extractMultilineField(String fieldName) {
      final pattern = RegExp("$fieldName: '''([\\s\\S]+?)'''", multiLine: true);
      final match = pattern.firstMatch(articleBlock);
      return match?.group(1)?.trim() ?? '';
    }
    
    List<String> extractKeywords() {
      final pattern = RegExp(r"keywords: \[(.*?)\]", dotAll: true);
      final match = pattern.firstMatch(articleBlock);
      if (match == null) return [];
      
      final keywordsStr = match.group(1)!;
      return keywordsStr
          .split(',')
          .map((k) => k.trim().replaceAll("'", ''))
          .where((k) => k.isNotEmpty)
          .toList();
    }
    
    final contentRaw = extractMultilineField('contentRaw');
    if (contentRaw.isEmpty) continue; // Skip if no content
    
    articles.add(ArticleData(
      id: extractField('id'),
      title: extractField('title'),
      description: extractField('description'),
      category: extractField('category'),
      imageUrl: extractField('imageUrl'),
      metaTitle: extractField('metaTitle'),
      metaDescription: extractField('metaDescription'),
      keywords: extractKeywords(),
      contentRaw: contentRaw,
    ));
  }
  
  return articles;
}

// Convert Markdown to HTML
String markdownToHtml(String markdown) {
  var html = markdown;
  
  // Headers (must be done in order h3 -> h2 -> h1)
  html = html.replaceAllMapped(RegExp(r'^### (.+)$', multiLine: true), (m) => '<h3>${m[1]}</h3>');
  html = html.replaceAllMapped(RegExp(r'^## (.+)$', multiLine: true), (m) => '<h2>${m[1]}</h2>');
  
  // Bold and links before paragraphs
  html = html.replaceAllMapped(RegExp(r'\*\*(.+?)\*\*'), (m) => '<strong>${m[1]}</strong>');
  html = html.replaceAllMapped(RegExp(r'\[(.+?)\]\((.+?)\)'), (m) => '<a href="${m[2]}" target="_blank">${m[1]}</a>');
  html = html.replaceAllMapped(RegExp(r'`(.+?)`'), (m) => '<code>${m[1]}</code>');
  
  // Process lists
  final lines = html.split('\n');
  final processed = <String>[];
  bool inList = false;
  
  for (var line in lines) {
    final trimmed = line.trim();
    
    if (trimmed.startsWith('- ')) {
      if (!inList) {
        processed.add('<ul>');
        inList = true;
      }
      processed.add('<li>${trimmed.substring(2)}</li>');
    } else {
      if (inList) {
        processed.add('</ul>');
        inList = false;
      }
      
      if (trimmed.isEmpty) {
        processed.add('');
      } else if (!trimmed.startsWith('<h')) {
        processed.add('<p>$trimmed</p>');
      } else {
        processed.add(trimmed);
      }
    }
  }
  
  if (inList) processed.add('</ul>');
  
  return processed.join('\n');
}

// Create URL-friendly slug
String slugify(String title) {
  return title
      .toLowerCase()
      .replaceAll(RegExp(r'[áàäâ]'), 'a')
      .replaceAll(RegExp(r'[éèëê]'), 'e')
      .replaceAll(RegExp(r'[íìïî]'), 'i')
      .replaceAll(RegExp(r'[óòöô]'), 'o')
      .replaceAll(RegExp(r'[úùüû]'), 'u')
      .replaceAll('ñ', 'n')
      .replaceAll(RegExp(r'[¿?¡!]'), '')
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'-+'), '-')
      .replaceAll(RegExp(r'^-|-$'), '');
}

// Generate sidebar
String generateSidebar(ArticleData current, List<ArticleData> all) {
  final others = all.where((a) => a.id != current.id).take(5).toList();
  return others.map((a) => '''
        <a href="${slugify(a.title)}.html" class="sidebar-article">
            <img src="${a.imageUrl}" alt="${a.title}">
            <div>
                <span class="sidebar-category">${a.category}</span>
                <h4>${a.title}</h4>
            </div>
        </a>
  ''').join('\n');
}

// Generate article page (same HTML template as before)
String generateArticlePage(ArticleData article, List<ArticleData> allArticles) {
  final content = markdownToHtml(article.contentRaw);
  final sidebarHtml = generateSidebar(article, allArticles);
  final keywords = article.keywords.join(', ');
  
  return '''<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${article.metaTitle} | Empodérate Blog</title>
    <meta name="description" content="${article.metaDescription}">
    <meta name="keywords" content="$keywords">
    <meta name="robots" content="index, follow">
    <meta property="og:title" content="${article.metaTitle}">
    <meta property="og:description" content="${article.metaDescription}">
    <meta property="og:image" content="${article.imageUrl}">
    <script type="application/ld+json">
    {"@context": "https://schema.org", "@type": "Article", "headline": "${article.title}", "description": "${article.metaDescription}"}
    </script>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Outfit', sans-serif; background: linear-gradient(135deg, #001220 0%, #0a1628 100%); color: #e0e0e0; line-height: 1.7; }
        header { background: rgba(0, 12, 32, 0.95); border-bottom: 1px solid rgba(0, 229, 255, 0.2); padding: 16px 24px; position: sticky; top: 0; z-index: 100; }
        .header-content { max-width: 1200px; margin: 0 auto; display: flex; justify-content: space-between; align-items: center; }
        .logo { font-size: 24px; font-weight: 700; color: #00E5FF; text-decoration: none; }
        .cta-button { background: linear-gradient(135deg, #D4AF37, #F4D35E); color: #001220; padding: 10px 24px; border-radius: 25px; text-decoration: none; font-weight: 600; }
        .hero { height: 300px; background: url('${article.imageUrl}') center/cover; position: relative; }
        .hero::after { content: ''; position: absolute; inset: 0; background: linear-gradient(to bottom, transparent 0%, #001220 100%); }
        .hero-content { position: absolute; bottom: 30px; left: 50%; transform: translateX(-50%); width: 100%; max-width: 1200px; padding: 0 24px; z-index: 10; }
        .category { display: inline-block; background: rgba(212, 175, 55, 0.2); border: 1px solid rgba(212, 175, 55, 0.5); color: #D4AF37; padding: 4px 12px; border-radius: 20px; font-size: 12px; margin-bottom: 12px; }
        h1 { font-size: 32px; color: #fff; }
        .container { max-width: 1200px; margin: 0 auto; padding: 40px 24px; display: grid; grid-template-columns: 1fr 320px; gap: 40px; }
        main { min-width: 0; }
        article h2 { color: #00E5FF; margin: 32px 0 16px; font-size: 24px; }
        article h3 { color: #D4AF37; margin: 24px 0 12px; font-size: 18px; }
        article p { margin-bottom: 16px; color: #c0c0c0; }
        article ul { margin: 16px 0; padding-left: 24px; }
        article li { margin-bottom: 8px; color: #c0c0c0; }
        article strong { color: #fff; }
        article code { background: rgba(0, 229, 255, 0.1); padding: 2px 8px; border-radius: 4px; color: #00E5FF; }
        article a { color: #00E5FF; }
        .cta-box { background: linear-gradient(135deg, rgba(212, 175, 55, 0.1), rgba(244, 211, 94, 0.1)); border: 2px solid #D4AF37; border-radius: 16px; padding: 32px; text-align: center; margin: 48px 0; }
        aside { position: sticky; top: 100px; align-self: start; }
        .sidebar-title { color: #00E5FF; font-size: 18px; margin-bottom: 16px; }
        .sidebar-article { display: flex; gap: 12px; padding: 12px; background: #151C2B; border-radius: 12px; margin-bottom: 12px; text-decoration: none; transition: all 0.3s; }
        .sidebar-article:hover { border: 1px solid #D4AF37; transform: translateX(4px); }
        .sidebar-article img { width: 70px; height: 70px; object-fit: cover; border-radius: 8px; }
        .sidebar-category { background: rgba(212, 175, 55, 0.15); color: #D4AF37; padding: 2px 6px; border-radius: 4px; font-size: 9px; }
        .sidebar-article h4 { color: #fff; font-size: 13px; margin: 6px 0 0; }
        footer { background: rgba(0, 12, 32, 0.95); padding: 32px 24px; text-align: center; color: #888; }
        @media (max-width: 900px) { .container { grid-template-columns: 1fr; } aside { position: static; } }
    </style>
</head>
<body>
    <header>
        <div class="header-content">
            <a href="../index.html" class="logo">EMPODÉRATE</a>
            <a href="../index.html" class="cta-button">🚀 Usar App Gratis</a>
        </div>
    </header>
    <div class="hero">
        <div class="hero-content">
            <span class="category">${article.category}</span>
            <h1>${article.title}</h1>
        </div>
    </div>
    <div class="container">
        <main>
            <article>$content</article>
            <div class="cta-box">
                <h3>📱 ¿Te fue útil este artículo?</h3>
                <p>Empodérate tiene herramientas gratuitas: calculadoras, chatbot IA, checklist de trámites y más.</p>
                <a href="$appUrl/" class="cta-button">Probar Empodérate Gratis →</a>
            </div>
        </main>
        <aside>
            <h3 class="sidebar-title">📚 Más Artículos</h3>
            $sidebarHtml
            <a href="index.html" class="cta-button" style="display: block; text-align: center; margin-top: 20px;">Ver Todos →</a>
        </aside>
    </div>
    <footer><p>© 2024 Empodérate · <a href="$appUrl/" style="color: #00E5FF;">Ir a la App</a></p></footer>
</body>
</html>''';
}

String generateBlogIndex(List<ArticleData> articles) {
  final cards = articles.map((a) => '''
        <a href="${slugify(a.title)}.html" class="article-card">
            <img src="${a.imageUrl}" alt="${a.title}">
            <div>
                <span class="category">${a.category}</span>
                <h3>${a.title}</h3>
                <p>${a.description}</p>
            </div>
        </a>
''').join('\n');

  return '''<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Blog Empresarial | Empodérate</title>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Outfit', sans-serif; background: linear-gradient(135deg, #001220 0%, #0a1628 100%); color: #e0e0e0; }
        header { background: rgba(0, 12, 32, 0.95); padding: 16px 24px; }
        .header-content { max-width: 1200px; margin: 0 auto; display: flex; justify-content: space-between; }
        .logo { font-size: 24px; color: #00E5FF; text-decoration: none; }
        .cta-button { background: linear-gradient(135deg, #D4AF37, #F4D35E); color: #001220; padding: 10px 24px; border-radius: 25px; text-decoration: none; }
        main { max-width: 1200px; margin: 0 auto; padding: 48px 24px; }
        h1 { color: #00E5FF; font-size: 36px; margin-bottom: 40px; }
        .articles-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(320px, 1fr)); gap: 24px; }
        .article-card { background: #151C2B; border-radius: 16px; overflow: hidden; text-decoration: none; }
        .article-card img { width: 100%; height: 180px; object-fit: cover; }
        .article-card div { padding: 20px; }
        .category { background: rgba(212, 175, 55, 0.2); color: #D4AF37; padding: 4px 10px; border-radius: 12px; font-size: 11px; }
        .article-card h3 { color: #fff; font-size: 18px; margin: 12px 0 8px; }
        .article-card p { color: #888; }
    </style>
</head>
<body>
    <header>
        <div class="header-content">
            <a href="../index.html" class="logo">EMPODÉRATE</a>
            <a href="../index.html" class="cta-button">🚀 Usar App Gratis</a>
        </div>
    </header>
    <main>
        <h1>📚 Blog Empresarial</h1>
        <div class="articles-grid">$cards</div>
    </main>
</body>
</html>''';
}

void main() async {
  print('🚀 Generando blog SEO con contenido extenso...\\n');
  
  // Parse articles from file
  print('📖 Leyendo initial_articles.dart...');
  final articles = await parseArticlesFile();
  print('✓ Encontrados ${articles.length} artículos\\n');
  
  // Create blog directory
  final blogDir = Directory('web/blog');
  if (!await blogDir.exists()) await blogDir.create(recursive: true);
  
  // Generate pages
  for (final article in articles) {
    final slug = slugify(article.title);
    final html = generateArticlePage(article, articles);
    await File('web/blog/$slug.html').writeAsString(html);
    print('✅ $slug.html (${article.contentRaw.length} caracteres)');
  }
  
  // Generate index
  await File('web/blog/index.html').writeAsString(generateBlogIndex(articles));
  print('✅ index.html');
  
  // Generate sitemap (dentro de /blog para SEO)
  final now = DateTime.now().toIso8601String().split('T')[0];
  final urls = articles.map((a) => '    <url><loc>$blogBaseUrl/${slugify(a.title)}.html</loc><lastmod>$now</lastmod><priority>0.8</priority></url>').join('\n');
  
  final sitemap = '''<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
    <url>
        <loc>${blogBaseUrl.replaceAll('/blog', '')}/blog/</loc>
        <lastmod>$now</lastmod>
        <priority>1.0</priority>
    </url>
$urls
</urlset>''';
  
  await File('web/blog/sitemap.xml').writeAsString(sitemap);
  print('✅ blog/sitemap.xml');
  
  print('\n🎉 Blog completado con contenido EXTENSO y optimizado para SEO');
  print('📝 Configuración actual:');
  print('   App URL: $appUrl');
  print('   Blog URL: $blogBaseUrl');
  print('\n⚠️  Recuerda actualizar estas URLs antes de desplegar a producción!');
}
