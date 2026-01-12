import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/blog_article.dart';
import 'initial_articles.dart'; 

class BlogDataService {
  // Singleton pattern
  static final BlogDataService _instance = BlogDataService._internal();
  static BlogDataService get instance => _instance; // Accessor

  factory BlogDataService() => _instance;
  
  BlogDataService._internal();

  final List<BlogArticle> _articles = [];
  late SharedPreferences _prefs;
  static const String _storageKey = 'blog_articles';

  /// Initialize the service (load data)
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadFromPrefs();
    _ensureSeedData(); // Ensure standard articles exist
  }

  void _loadFromPrefs() {
    final String? jsonString = _prefs.getString(_storageKey);
    if (jsonString != null && jsonString.isNotEmpty) {
      try {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        _articles.clear();
        _articles.addAll(jsonList.map((e) => BlogArticle.fromJson(e)).toList());
      } catch (e) {
        print('Error loading blog articles: $e');
        _initMockData(); // Fallback
      }
    } else {
      _initMockData(); // First run
      _saveToPrefs();
    }
  }

  // Merges seed articles if they are missing (prevents duplicates by ID)
  void _ensureSeedData() {
    print('BLOG: seedArticles=${initialBlogArticles.length}, currentLoaded=${_articles.length}');
    
    // 1. Sanitize current articles (remove empty/invalid)
    _articles.removeWhere((a) => (a.title.trim().isEmpty) || (a.content.trim().isEmpty && a.contentRaw.trim().isEmpty));

    bool changed = false;
    for (var seed in initialBlogArticles) {
      // Check if ID exists
      final existingIndex = _articles.indexWhere((a) => a.id == seed.id);
      
      if (existingIndex == -1) {
        // New article from seed (e.g. imported)
        print('BLOG: Adding new seed article: ${seed.id}');
        _articles.add(seed);
        changed = true;
      } else {
        // OPTIONAL: Update existing if seed is "newer" or we want to force update?
        // For now, we trust local edits over seed, UNLESS it was a "ghost" (empty content)
        final existing = _articles[existingIndex];
        if (existing.content.isEmpty && seed.content.isNotEmpty) {
           print('BLOG: Fixing empty content for ${seed.id}');
           _articles[existingIndex] = seed;
           changed = true;
        }
      }
    }
    
    // Also remove old mock data if present (optional cleanup)
    _articles.removeWhere((a) => ['1', '2', '3'].contains(a.id)); 
    
    // Deduplicate by ID just in case
    final ids = <String>{};
    _articles.retainWhere((a) {
      if (ids.contains(a.id)) return false;
      ids.add(a.id);
      return true;
    });

    if (changed) {
       // Sort by date descending
       _articles.sort((a,b) => b.date.compareTo(a.date));
       _saveToPrefs();
    }
    
    // Diagnostic check for images
    for (final a in _articles) {
       if (!_isValidUrl(a.imageUrl)) {
          print('BLOG: invalid imageUrl for slug=${a.id} value="${a.imageUrl}" -> using placeholder');
       }
    }
    
    print('BLOG: Total Articles after merge & filter: ${_articles.length}');
  }

  bool _isValidUrl(String? s) {
    if (s == null) return false;
    final v = s.trim();
    if (v.isEmpty) return false;
    return v.startsWith("http://") || v.startsWith("https://");
  }

  Future<void> _saveToPrefs() async {
    final String jsonString = jsonEncode(_articles.map((e) => e.toJson()).toList());
    await _prefs.setString(_storageKey, jsonString);
  }

  // -- GETTERS --
  List<BlogArticle> getAllArticles() {
    // Return copy, filtered by content validity
    return _articles.where((a) => (a.title.isNotEmpty) && (a.content.isNotEmpty || a.contentRaw.isNotEmpty)).toList();
  }

  List<BlogArticle> getPublishedArticles() {
    return _articles.where((a) => a.status == 'published').toList();
  }
  
  List<BlogArticle> getFeaturedArticles() {
    return _articles.where((a) => a.status == 'published' && a.isFeatured).toList();
  }

  BlogArticle? getArticleById(String id) {
    try {
      return _articles.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }

  // -- ACTIONS --

  // -- ACTIONS --

  void addArticle(BlogArticle article) {
    _articles.insert(0, article); // Add to top
    _saveToPrefs();
  }

  void updateArticle(BlogArticle updatedArticle) {
    final index = _articles.indexWhere((a) => a.id == updatedArticle.id);
    if (index != -1) {
      _articles[index] = updatedArticle;
      _saveToPrefs();
    }
  }

  void deleteArticle(String id) {
    _articles.removeWhere((a) => a.id == id);
    _saveToPrefs();
  }

  void toggleStatus(String id) {
    final article = getArticleById(id);
    if (article != null) {
      final newStatus = article.status == 'published' ? 'draft' : 'published';
      updateArticle(BlogArticle(
        id: article.id,
        title: article.title,
        subtitle: article.subtitle,
        description: article.description,
        category: article.category,
        date: article.date,
        imageUrl: article.imageUrl,
        content: article.content,
        keywords: article.keywords,
        relatedIds: article.relatedIds,
        status: newStatus,
        isFeatured: article.isFeatured,
        metaTitle: article.metaTitle,
        metaDescription: article.metaDescription,
        contentRaw: article.contentRaw,
        tags: article.tags,
        views: article.views,
        likes: article.likes,
        allowComments: article.allowComments,
        comments: article.comments,
        scheduledDate: article.scheduledDate,
        publishedAt: article.publishedAt,
      ));
    }
  }

  void toggleFeatured(String id) {
    final article = getArticleById(id);
    if (article != null) {
      updateArticle(BlogArticle(
        id: article.id,
        title: article.title,
        subtitle: article.subtitle,
        description: article.description,
        category: article.category,
        date: article.date,
        imageUrl: article.imageUrl,
        content: article.content,
        keywords: article.keywords,
        relatedIds: article.relatedIds,
        status: article.status,
        isFeatured: !article.isFeatured,
        metaTitle: article.metaTitle,
        metaDescription: article.metaDescription,
        contentRaw: article.contentRaw,
        tags: article.tags,
        views: article.views,
        likes: article.likes,
        allowComments: article.allowComments,
        comments: article.comments,
        scheduledDate: article.scheduledDate,
        publishedAt: article.publishedAt,
      ));
    }
  }
  
  void checkScheduledPosts() {
    final now = DateTime.now();
    bool changed = false;
    for (var i = 0; i < _articles.length; i++) {
      final a = _articles[i];
      if (a.status == 'scheduled' && a.scheduledDate != null && a.scheduledDate!.isBefore(now)) {
        _articles[i] = BlogArticle(
          id: a.id,
          title: a.title,
          subtitle: a.subtitle,
          description: a.description,
          category: a.category,
          date: now, // Update date to publish time
          imageUrl: a.imageUrl,
          content: a.content,
          keywords: a.keywords,
          relatedIds: a.relatedIds,
          status: 'published',
          isFeatured: a.isFeatured,
          metaTitle: a.metaTitle,
          metaDescription: a.metaDescription,
          contentRaw: a.contentRaw,
          tags: a.tags,
          views: a.views,
          likes: a.likes,
          allowComments: a.allowComments,
          comments: a.comments,
          scheduledDate: a.scheduledDate,
          publishedAt: now,
        );
        changed = true;
      }
    }
    if (changed) _saveToPrefs();
  }

  List<BlogArticle> searchArticles({String query = '', String? category, String? status}) {
    return _articles.where((a) {
      final matchesQuery = query.isEmpty || 
          a.title.toLowerCase().contains(query.toLowerCase()) || 
          a.tags.any((t) => t.toLowerCase().contains(query.toLowerCase()));
      final matchesCategory = category == null || category == 'Todas' || a.category == category;
      final matchesStatus = status == null || status == 'Todos' || 
                            (status == 'Publicados' && a.status == 'published') ||
                            (status == 'Borradores' && a.status == 'draft') ||
                            (status == 'Programados' && a.status == 'scheduled');
      
      return matchesQuery && matchesCategory && matchesStatus;
    }).toList();
  }

  // -- STATS --
  List<BlogArticle> getTopArticlesByViews({int limit = 5}) {
    final sorted = List<BlogArticle>.from(_articles)
      ..sort((a, b) => b.views.compareTo(a.views));
    return sorted.take(limit).toList();
  }

  int getTotalComments() {
    return _articles.fold(0, (sum, a) => sum + a.comments.length);
  }

  // -- MOCK DATA --
  void _initMockData() {
    // We defer to _ensureSeedData to populate from initialBlogArticles safely
    _articles.clear();
  }
}
