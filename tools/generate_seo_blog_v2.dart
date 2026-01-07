// SEO Blog Generator V2 - Reads from initial_articles.dart
// Run with: dart run tools/generate_seo_blog_v2.dart

import 'dart:io';
import '../lib/src/features/blog/initial_articles.dart';
import '../lib/src/models/blog_article.dart';

// Convert Markdown to HTML
String markdownToHtml(String markdown) {
  var html = markdown;
  
  // Headers
  html = html.replaceAllMapped(RegExp(r'^### (.+)$', multiLine: true), (m) => '<h3>${m[1]}</h3>');
  html = html.replaceAllMapped(RegExp(r'^## (.+)$', multiLine: true), (m) => '<h2>${m[1]}</h2>');
  html = html.replaceAllMapped(RegExp(r'^# (.+)$', multiLine: true), (m) => '<h1>${m[1]}</h1>');
  
  // Bold and italic
  html = html.replaceAllMapped(RegExp(r'\*\*(.+?)\*\*'), (m) => '<strong>${m[1]}</strong>');
  html = html.replaceAllMapped(RegExp(r'\*(.+?)\*'), (m) => '<em>${m[1]}</em>');
  
  // Code blocks
  html = html.replaceAllMapped(RegExp(r'`(.+?)`'), (m) => '<code>${m[1]}</code>');
  
  // Links
  html = html.replaceAllMapped(RegExp(r'\[(.+?)\]\((.+?)\)'), (m) => '<a href="${m[2]}" target="_blank">${m[1]}</a>');
  
  // Lists - Process bullet points
  html = html.replaceAllMapped(RegExp(r'^- (.+)$', multiLine: true), (m) => '<li>${m[1]}</li>');
  html = html.replaceAll(RegExp(r'(<li>.+</li>\n)+'), (match) => '<ul>\n$match</ul>\n');
  
  // Paragraphs - wrap standalone lines
  final lines = html.split('\n');
  final processedLines = <String>[];
  bool inList = false;
  bool inHeading = false;
  
  for (var line in lines) {
    line = line.trim();
    if (line.isEmpty) {
      processedLines.add('');
      continue;
    }
    
    if (line.startsWith('<h') || line.startsWith('<ul') || line.startsWith('</ul') || 
        line.startsWith('<li') || line.startsWith('</li') || line.startsWith('<code')) {
      processedLines.add(line);
    } else if (!line.startsWith('<')) {
      processedLines.add('<p>$line</p>');
    } else {
      processedLines.add(line);
    }
  }
  
  return processedLines.join('\n');
}

// Generate sidebar HTML
String generateSidebar(BlogArticle currentArticle, List<BlogArticle> allArticles) {
  final relatedArticles = allArticles
      .where((a) => a.id != currentArticle.id && a.status == 'published')
      .take(5)
      .toList();
  
  return relatedArticles.map((a) => '''
        <a href="${_slugify(a.title)}.html" class="sidebar-article">
            <img src="${a.imageUrl}" alt="${a.title}">
            <div>
                <span class="sidebar-category">${a.category}</span>
                <h4>${a.title}</h4>
            </div>
        </a>
  ''').join('\n');
}

// Create URL-friendly slug
String _slugify(String title) {
  return title
      .toLowerCase()
      .replaceAll(RegExp(r'[áàäâ]'), 'a')
      .replaceAll(RegExp(r'[éèëê]'), 'e')
      .replaceAll(RegExp(r'[íìïî]'), 'i')
      .replaceAll(RegExp(r'[óòöô]'), 'o')
      .replaceAll(RegExp(r'[úùüû]'), 'u')
      .replaceAll('ñ', 'n')
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'-+'), '-')
      .replaceAll(RegExp(r'^-|-$'), '');
}

// Generate article page
String generateArticlePage(BlogArticle article, List<BlogArticle> allArticles) {
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
    <meta name="author" content="Empodérate">
    <meta name="robots" content="index, follow">
    
    <!-- Open Graph -->
    <meta property="og:title" content="${article.metaTitle}">
    <meta property="og:description" content="${article.metaDescription}">
    <meta property="og:image" content="${article.imageUrl}">
    <meta property="og:type" content="article">
    
    <!-- Schema.org -->
    <script type="application/ld+json">
    {
        "@context": "https://schema.org",
        "@type": "Article",
        "headline": "${article.title}",
        "description": "${article.metaDescription}",
        "image": "${article.imageUrl}",
        "author": {"@type": "Organization", "name": "Empodérate"},
        "publisher": {"@type": "Organization", "name": "Empodérate"}
    }
    </script>
    
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@400;500;600;700&display=swap" rel="stylesheet">
    
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Outfit', sans-serif;
            background: linear-gradient(135deg, #001220 0%, #0a1628 100%);
            color: #e0e0e0;
            min-height: 100vh;
            line-height: 1.7;
        }
        header {
            background: rgba(0, 12, 32, 0.95);
            border-bottom: 1px solid rgba(0, 229, 255, 0.2);
            padding: 16px 24px;
            position: sticky;
            top: 0;
            z-index: 100;
        }
        .header-content {
            max-width: 1200px;
            margin: 0 auto;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .logo {
            font-size: 24px;
            font-weight: 700;
            color: #00E5FF;
            text-decoration: none;
            text-shadow: 0 0 20px rgba(0, 229, 255, 0.5);
        }
        .cta-button {
            background: linear-gradient(135deg, #D4AF37, #F4D35E);
            color: #001220;
            padding: 10px 24px;
            border-radius: 25px;
            text-decoration: none;
            font-weight: 600;
            transition: all 0.3s;
        }
        .cta-button:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(212, 175, 55, 0.4);
        }
        .hero {
            height: 300px;
            background: url('${article.imageUrl}') center/cover;
            position: relative;
        }
        .hero::after {
            content: '';
            position: absolute;
            inset: 0;
            background: linear-gradient(to bottom, transparent 0%, #001220 100%);
        }
        .hero-content {
            position: absolute;
            bottom: 30px;
            left: 50%;
            transform: translateX(-50%);
            width: 100%;
            max-width: 1200px;
            padding: 0 24px;
            z-index: 10;
        }
        .category {
            display: inline-block;
            background: rgba(212, 175, 55, 0.2);
            border: 1px solid rgba(212, 175, 55, 0.5);
            color: #D4AF37;
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
            margin-bottom: 12px;
        }
        h1 {
            font-size: 32px;
            color: #fff;
            text-shadow: 0 2px 20px rgba(0,0,0,0.5);
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 40px 24px;
            display: grid;
            grid-template-columns: 1fr 320px;
            gap: 40px;
        }
        main { min-width: 0; }
        article h2 {
            color: #00E5FF;
            margin: 32px 0 16px;
            font-size: 24px;
        }
        article h3 {
            color: #D4AF37;
            margin: 24px 0 12px;
            font-size: 18px;
        }
        article p {
            margin-bottom: 16px;
            color: #c0c0c0;
        }
        article ul {
            margin: 16px 0;
            padding-left: 24px;
        }
        article li {
            margin-bottom: 8px;
            color: #c0c0c0;
        }
        article strong { color: #fff; }
        article code {
            background: rgba(0, 229, 255, 0.1);
            border: 1px solid rgba(0, 229, 255, 0.3);
            padding: 2px 8px;
            border-radius: 4px;
            color: #00E5FF;
        }
        article a {
            color: #00E5FF;
            text-decoration: underline;
        }
        .cta-box {
            background: linear-gradient(135deg, rgba(212, 175, 55, 0.1), rgba(244, 211, 94, 0.1));
            border: 2px solid #D4AF37;
            border-radius: 16px;
            padding: 32px;
            text-align: center;
            margin: 48px 0;
        }
        .cta-box h3 { color: #D4AF37; margin-bottom: 12px; }
        aside {
            position: sticky;
            top: 100px;
            align-self: start;
        }
        .sidebar-title {
            color: #00E5FF;
            font-size: 18px;
            margin-bottom: 16px;
            font-weight: 600;
        }
        .sidebar-article {
            display: flex;
            gap: 12px;
            padding: 12px;
            background: #151C2B;
            border-radius: 12px;
            border: 1px solid rgba(255,255,255,0.05);
            margin-bottom: 12px;
            text-decoration: none;
            transition: all 0.3s;
        }
        .sidebar-article:hover {
            border-color: #D4AF37;
            transform: translateX(4px);
        }
        .sidebar-article img {
            width: 70px;
            height: 70px;
            object-fit: cover;
            border-radius: 8px;
        }
        .sidebar-category {
            display: inline-block;
            background: rgba(212, 175, 55, 0.15);
            color: #D4AF37;
            padding: 2px 6px;
            border-radius: 4px;
            font-size: 9px;
            font-weight: 600;
        }
        .sidebar-article h4 {
            color: #fff;
            font-size: 13px;
            line-height: 1.3;
            margin: 6px 0 0;
            overflow: hidden;
            text-overflow: ellipsis;
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
        }
        footer {
            background: rgba(0, 12, 32, 0.95);
            border-top: 1px solid rgba(0, 229, 255, 0.2);
            padding: 32px 24px;
            text-align: center;
            color: #888;
        }
        footer a { color: #00E5FF; text-decoration: none; }
        @media (max-width: 900px) {
            .container { grid-template-columns: 1fr; }
            aside { position: static; }
        }
        @media (max-width: 600px) {
            h1 { font-size: 24px; }
            .hero { height: 220px; }
        }
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
            <article>
                $content
            </article>
            
            <div class="cta-box">
                <h3>📱 ¿Te fue útil este artículo?</h3>
                <p>Empodérate tiene herramientas gratuitas para ayudarte a gestionar tu negocio: calculadoras, chatbot con IA, checklist de trámites y más.</p>
                <a href="../index.html" class="cta-button">Probar Empodérate Gratis →</a>
            </div>
        </main>
        
        <aside>
            <h3 class="sidebar-title">📚 Más Artículos</h3>
            $sidebarHtml
            <a href="index.html" class="cta-button" style="display: block; text-align: center; margin-top: 20px;">Ver Todos →</a>
        </aside>
    </div>
    
    <footer>
        <p>© 2024 Empodérate · <a href="../index.html">Ir a la App</a> · <a href="index.html">Ver más artículos</a></p>
    </footer>
</body>
</html>
''';
}

// Generate blog index
String generateBlogIndex(List<BlogArticle> articles) {
  final cards = articles
      .where((a) => a.status == 'published')
      .map((a) => '''
        <a href="${_slugify(a.title)}.html" class="article-card">
            <img src="${a.imageUrl}" alt="${a.title}">
            <div class="card-content">
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
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Blog Empresarial | Empodérate</title>
    <meta name="description" content="Guías, consejos y recursos para emprendedores en Panamá">
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Outfit', sans-serif;
            background: linear-gradient(135deg, #001220 0%, #0a1628 100%);
            color: #e0e0e0;
            min-height: 100vh;
        }
        header {
            background: rgba(0, 12, 32, 0.95);
            border-bottom: 1px solid rgba(0, 229, 255, 0.2);
            padding: 16px 24px;
        }
        .header-content {
            max-width: 1200px;
            margin: 0 auto;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .logo { font-size: 24px; font-weight: 700; color: #00E5FF; text-decoration: none; }
        .cta-button {
            background: linear-gradient(135deg, #D4AF37, #F4D35E);
            color: #001220;
            padding: 10px 24px;
            border-radius: 25px;
            text-decoration: none;
            font-weight: 600;
        }
        main { max-width: 1200px; margin: 0 auto; padding: 48px 24px; }
        h1 { color: #00E5FF; font-size: 36px; margin-bottom: 40px; }
        .articles-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
            gap: 24px;
        }
        .article-card {
            background: #151C2B;
            border-radius: 16px;
            overflow: hidden;
            text-decoration: none;
            border: 1px solid rgba(255,255,255,0.05);
            transition: all 0.3s;
        }
        .article-card:hover {
            transform: translateY(-4px);
            border-color: #D4AF37;
        }
        .article-card img { width: 100%; height: 180px; object-fit: cover; }
        .card-content { padding: 20px; }
        .category {
            display: inline-block;
            background: rgba(212, 175, 55, 0.2);
            color: #D4AF37;
            padding: 4px 10px;
            border-radius: 12px;
            font-size: 11px;
            margin-bottom: 12px;
        }
        .article-card h3 { color: #fff; font-size: 18px; margin-bottom: 8px; }
        .article-card p { color: #888; font-size: 14px; }
        footer { text-align: center; padding: 32px; color: #666; }
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
        <div class="articles-grid">
$cards
        </div>
    </main>
    
    <footer>
        <p>© 2024 Empodérate · <a href="../index.html" style="color: #00E5FF;">Ir a la App</a></p>
    </footer>
</body>
</html>
''';
}

void main() async {
  print('🚀 Generando blog SEO desde initial_articles.dart...\\n');
  
  final blogDir = Directory('web/blog');
  if (!await blogDir.exists()) {
    await blogDir.create(recursive: true);
  }
  
  final publishedArticles = initialBlogArticles.where((a) => a.status == 'published').toList();
  
  // Generate individual article pages
  for (final article in publishedArticles) {
    final slug = _slugify(article.title);
    final html = generateArticlePage(article, initialBlogArticles);
    await File('web/blog/$slug.html').writeAsString(html);
    print('✅ Generado: $slug.html');
  }
  
  // Generate index
  final indexHtml = generateBlogIndex(initialBlogArticles);
  await File('web/blog/index.html').writeAsString(indexHtml);
  print('✅ Generado: index.html');
  
  // Generate sitemap
  final now = DateTime.now().toIso8601String().split('T')[0];
  final sitemapUrls = publishedArticles.map((a) => '''
    <url>
        <loc>https://tudominio.com/blog/${_slugify(a.title)}.html</loc>
        <lastmod>$now</lastmod>
        <changefreq>weekly</changefreq>
        <priority>0.8</priority>
    </url>''').join('\n');
  
  final sitemap = '''<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
    <url>
        <loc>https://tudominio.com/</loc>
        <lastmod>$now</lastmod>
        <priority>1.0</priority>
    </url>
$sitemapUrls
</urlset>
''';
  
  await File('web/sitemap.xml').writeAsString(sitemap);
  print('✅ Generado: sitemap.xml');
  
  print('\n🎉 ¡Blog SEO generado con contenido completo!');
  print('📂 ${publishedArticles.length} artículos extensos listos');
}
