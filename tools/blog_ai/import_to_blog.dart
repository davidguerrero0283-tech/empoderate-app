/// Blog Draft Importer
/// 
/// Imports approved drafts from blog_drafts/ into the blog system
/// 
/// Usage:
///   dart run tools/blog_ai/import_to_blog.dart --slug=article-slug
///   dart run tools/blog_ai/import_to_blog.dart --all-approved

import 'dart:convert';
import 'dart:io';

void main(List<String> args) async {
  print('''
╔══════════════════════════════════════════════════════════════╗
║     EMPODÉRATE - Blog Draft Importer                         ║
╚══════════════════════════════════════════════════════════════╝
''');

  // Parse arguments
  String? targetSlug;
  bool importAllApproved = false;
  bool listOnly = false;
  
  if (args.isEmpty) {
     print('ℹ️ No arguments provided. Defaulting to --all-approved');
     importAllApproved = true;
  }
  
  for (final arg in args) {
    if (arg.startsWith('--slug=')) {
      targetSlug = arg.substring(7);
    }
    if (arg == '--all-approved') {
      importAllApproved = true;
    }
    if (arg == '--list') {
      listOnly = true;
    }
    if (arg == '--help' || arg == '-h') {
      _printHelp();
      return;
    }
  }

  // Load index
  final indexFile = File('blog_drafts/_index.json');
  if (!indexFile.existsSync()) {
    print('❌ No drafts found. Run generate_ai_articles.dart first.');
    exit(1);
  }

  final rawJson = jsonDecode(indexFile.readAsStringSync());
  List<Map<String, dynamic>> index;
  
  if (rawJson is List) {
     index = rawJson.cast<Map<String, dynamic>>();
  } else {
     index = (rawJson['articles'] as List).cast<Map<String, dynamic>>();
  }

  print('📋 Found ${index.length} draft(s) in index\n');

  // List mode
  if (listOnly) {
    print('DRAFTS:');
    print('─' * 60);
    for (final article in index) {
      final status = article['status'] ?? 'draft';
      final statusIcon = status == 'approved' ? '✅' : (status == 'published' ? '📤' : '📝');
      print('$statusIcon [${status.toUpperCase().padRight(9)}] ${article['slug']}');
      print('   ${article['title']}');
      print('');
    }
    return;
  }

  // Find articles to import
  List<Map<String, dynamic>> toImport = [];
  
  if (targetSlug != null) {
    // Only import specific slug
    final article = index.firstWhere(
      (a) => a['slug'] == targetSlug,
      orElse: () => <String, dynamic>{},
    );
    if (article.isEmpty) {
      print('❌ Article with slug "$targetSlug" not found');
      exit(1);
    }
    toImport = [article];
  } else if (importAllApproved) {
    // Filter by status=approved AND imported!=true
    toImport = index.where((a) => a['status'] == 'approved' && (a['imported'] != true)).toList();
    
    // Also include 'status=published' if imported is false (legacy state fix)
    // Actually, 'published' implies it was imported, but let's stick to explicit 'imported' flag if present, 
    // or assume if status is 'published' it might have been imported.
    // The PROMPT says: loop over approved but check imported flag.
    
    if (toImport.isEmpty) {
      print('ℹ️ No new approved articles found (checked "imported: false").');
      print('   To approve, edit the draft and change status: draft → status: approved');
      print('   (Already imported articles are skipped)');
      return;
    }
  } else {
    print('❌ Please specify --slug=<slug> or --all-approved');
    print('   Use --list to see all drafts');
    print('   Use --help for more options');
    exit(1);
  }

  print('📥 Found ${toImport.length} candidate(s) for import...\n');

  final articlesFile = File('lib/src/features/blog/data/initial_articles.dart');
  if (!articlesFile.existsSync()) {
    print('❌ initial_articles.dart not found at ${articlesFile.path}');
    exit(1);
  }

  String articlesContent = articlesFile.readAsStringSync();
  final List<String> importedSlugs = [];
  int skippedCount = 0;

  for (final article in toImport) {
    final slug = article['slug'];
    
    // Deduplication check: Is slug already in the file?
    // We check for "id: 'slug_underscored'" or just strict slug match in comment/title
    // Robust check: 
    if (articlesContent.contains("id: '${slug.replaceAll('-', '_')}'") || articlesContent.contains("slug: '$slug'")) {
       print('   ⏭️ Skipped (Already in initial_articles.dart): $slug');
       
       // Mark as imported in index to avoid checking again
       final indexIdx = index.indexWhere((a) => a['slug'] == slug);
       if (indexIdx != -1) {
          index[indexIdx]['imported'] = true;
          // Ensure status is published if it's there
          if (index[indexIdx]['status'] == 'approved') index[indexIdx]['status'] = 'published';
       }
       skippedCount++;
       continue;
    }

    try {
      final dartCode = _generateArticleCode(article);
      
      if (dartCode == null) continue;

      // Find the last ]; to insert before it
      final lastBracketIndex = articlesContent.lastIndexOf('];');
      if (lastBracketIndex == -1) {
        print('⚠️ Could not find end of list in initial_articles.dart for $slug');
        continue;
      }

      articlesContent = articlesContent.substring(0, lastBracketIndex) + 
          dartCode + 
          '\n' + 
          articlesContent.substring(lastBracketIndex);
      
      importedSlugs.add(slug);
      
      // Update status in index
      final indexIdx = index.indexWhere((a) => a['slug'] == slug);
      if (indexIdx != -1) {
        index[indexIdx]['status'] = 'published';
        index[indexIdx]['imported'] = true;
      }
      
      print('   ✅ Imported: $slug');
    } catch (e) {
      print('   ❌ Error importing ${article['slug']}: $e');
    }
  }

  // Write changes
  if (importedSlugs.isNotEmpty || skippedCount > 0) {
      if (importedSlugs.isNotEmpty) {
        articlesFile.writeAsStringSync(articlesContent);
        print('\n✅ Successfully added ${importedSlugs.length} new articles.');
      }
      
      // Always update index if we changed imported flags
      final newJson = {'articles': index};
      indexFile.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(newJson));
      print('📋 Updated index status (Imported: ${importedSlugs.length}, Skipped: $skippedCount).');
  } else {
    print('\n⚠️ No actions taken.');
  }
}

String? _generateArticleCode(Map<String, dynamic> article) {
  final slug = article['slug'];
  final draftFile = File('blog_drafts/$slug.md');
  
  if (!draftFile.existsSync()) {
    print('⚠️ Draft file not found: $slug.md');
    return null;
  }

  final content = draftFile.readAsStringSync();
  final parts = content.split('---');
  
  String bodyContent = '';
  if (parts.length >= 3) {
    bodyContent = parts.sublist(2).join('---').trim();
  } else {
    bodyContent = content.trim(); // Fallback if no frontmatter
  }

  final id = slug.replaceAll('-', '_');
  final title = article['title'] ?? slug;
  // Handle both key styles
  final metaDesc = article['meta_description'] ?? article['metaDescription'] ?? '';
  final category = article['category'] ?? 'General';
  final tags = (article['tags'] as List?)?.cast<String>() ?? (article['keywords'] as List?)?.cast<String>() ?? [];
  final keywords = (article['keywords'] as List?)?.cast<String>() ?? tags;

  return '''
  BlogArticle(
    id: '$id',
    title: '$title',
    subtitle: '',
    description: '$metaDesc',
    category: '$category',
    date: DateTime.now(),
    imageUrl: '', // TODO: Add image
    content: \'\'\'
${bodyContent.replaceAll("'''", "\\'\\'\\'")}
\'\'\',
    keywords: ${jsonEncode(keywords)},
    relatedIds: [],
    status: 'published',
    isFeatured: false,
    metaTitle: '$title',
    metaDescription: '$metaDesc',
    contentRaw: '',
    tags: ${jsonEncode(tags)},
    views: 0,
    likes: 0,
    allowComments: true,
    comments: [],
    scheduledDate: null,
    publishedAt: DateTime.now(),
  ),''';
}

void _printHelp() {
  print('''
USAGE:
  dart run tools/blog_ai/import_to_blog.dart [OPTIONS]

OPTIONS:
  --slug=<slug>       Import specific article by slug
  --all-approved      Import all articles with status: approved
  --list              List all drafts with their status
  --help, -h          Show this help

WORKFLOW:
  1. Generate drafts:  dart run tools/blog_ai/generate_ai_articles.dart
  2. Review drafts in blog_drafts/
  3. Change status: draft → status: approved for articles ready to publish
  4. Import: dart run tools/blog_ai/import_to_blog.dart --all-approved

EXAMPLES:
  # List all drafts
  dart run tools/blog_ai/import_to_blog.dart --list

  # Import specific article
  dart run tools/blog_ai/import_to_blog.dart --slug=como-abrir-tienda-online

  # Import all approved
  dart run tools/blog_ai/import_to_blog.dart --all-approved
''');
}
