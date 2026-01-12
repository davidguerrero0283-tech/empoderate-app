import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../models/blog_article.dart';
import '../components/safe_async_screen.dart';
import '../components/neon_widgets.dart';
import '../features/blog/blog_data_service.dart';
import '../features/blog/components/blog_card.dart';

class BlogMainScreen extends StatefulWidget {
  const BlogMainScreen({Key? key}) : super(key: key);

  @override
  State<BlogMainScreen> createState() => _BlogMainScreenState();
}

class _BlogMainScreenState extends State<BlogMainScreen> {
  final _dataService = BlogDataService();
  String _searchQuery = '';
  String _selectedCategory = 'Todas';

  final List<String> _categories = [
    'Todas',
    'Contabilidad & Finanzas',
    'Recursos Humanos',
    'Marketing & Ventas',
    'Legal & Trámites',
    'Gestión Empresarial',
  ];

  Future<List<BlogArticle>> _loadArticles() async {
    // Ensure service is ready if needed, though it's init in main
    return _dataService.getPublishedArticles();
  }

  @override
  Widget build(BuildContext context) {
    return SafeAsyncScreen<List<BlogArticle>>(
      title: 'BLOG EMPODÉRATE',
      futureBuilder: _loadArticles,
      emptyCheck: (articles) => articles.isEmpty,
      emptyMessage: 'No hay artículos publicados aún',
      emptyIcon: 'document',
      builder: (context, allArticles) {
        final filteredArticles = allArticles.where((a) {
          final matchesQuery = a.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              a.keywords.any((k) => k.toLowerCase().contains(_searchQuery.toLowerCase()));
          final matchesCategory = _selectedCategory == 'Todas' || a.category == _selectedCategory;
          return matchesQuery && matchesCategory;
        }).toList();

        final featuredArticles = allArticles.where((a) => a.isFeatured).toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const NeonSectionTitle(title: 'Blog y Actualizaciones', color: Color(0xFFD4AF37)),
              Text(
                'Mantente informado con lo último para emprendedores',
                style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 24),
              // Search bar
              NeonInput(
                label: 'Buscar artículos…',
                isNumber: false,
                onChanged: (v) => setState(() => _searchQuery = v),
              ),
              const SizedBox(height: 16),
              // Category filter
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    final selected = cat == _selectedCategory;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCategory = cat),
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: selected ? const Color(0xFF001225).withOpacity(0.8) : Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
                          boxShadow: selected
                              ? [BoxShadow(color: const Color(0xFFD4AF37).withOpacity(0.6), blurRadius: 8, offset: const Offset(0, 2))]
                              : [],
                        ),
                        child: Center(
                          child: Text(
                            cat,
                            style: GoogleFonts.outfit(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              
              if (featuredArticles.isNotEmpty && _selectedCategory == 'Todas' && _searchQuery.isEmpty) ...[
                const NeonSectionTitle(title: 'Destacados de la Semana', color: Color(0xFFD4AF37)),
                const SizedBox(height: 12),
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: featuredArticles.length,
                    itemBuilder: (context, index) {
                      final article = featuredArticles[index];
                      return BlogCard(
                        article: article,
                        isFeatured: true,
                        onTap: () => context.push('/blog_article?id=${Uri.encodeComponent(article.id)}', extra: article),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 32),
              ],

              const NeonSectionTitle(title: 'Todos los artículos', color: Color(0xFFD4AF37)),
              const SizedBox(height: 12),
              if (filteredArticles.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Column(
                      children: [
                        const Icon(Icons.search_off, size: 60, color: Colors.white24),
                        const SizedBox(height: 16),
                        Text(
                          'No se encontraron artículos que coincidan',
                          style: GoogleFonts.outfit(color: Colors.white38),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredArticles.length,
                  itemBuilder: (context, index) {
                    final article = filteredArticles[index];
                    return BlogCard(
                      article: article,
                      isFeatured: false,
                      onTap: () => context.push('/blog_article?id=${Uri.encodeComponent(article.id)}', extra: article),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}
