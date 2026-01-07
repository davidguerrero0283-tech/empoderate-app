import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../components/gradient_background.dart';
import '../../../components/neon_widgets.dart';
import '../../../components/premium_scaffold.dart';
import '../../../features/blog/blog_data_service.dart';
import '../../../features/blog/categories_list.dart'; // Categories
import '../../../models/blog_article.dart';
import '../../../navigation/app_routes.dart';

class AdminBlogScreen extends StatefulWidget {
  const AdminBlogScreen({Key? key}) : super(key: key);

  @override
  State<AdminBlogScreen> createState() => _AdminBlogScreenState();
}

class _AdminBlogScreenState extends State<AdminBlogScreen> {
  final _dataService = BlogDataService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  List<BlogArticle> _articles = [];
  String _searchQuery = '';
  String _filterCategory = 'Todas';
  String _filterStatus = 'Todos'; // Todos, Publicados, Borradores, Programados

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _articles = _dataService.searchArticles(
        query: _searchQuery,
        category: _filterCategory,
        status: _filterStatus,
      );
    });
  }

  void _handleDelete(String id) {
    showDialog(
      context: context, 
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF001225),
        title: Text('Eliminar artículo', style: GoogleFonts.outfit(color: Colors.white)),
        content: Text('¿Estás seguro de que deseas eliminar este artículo permanentemente?', style: GoogleFonts.outfit(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx), 
            child: Text('Cancelar', style: GoogleFonts.outfit(color: Colors.white54))
          ),
          TextButton(
            onPressed: () {
              _dataService.deleteArticle(id);
              Navigator.pop(ctx);
              _refresh();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Artículo eliminado')));
            }, 
            child: Text('Eliminar', style: GoogleFonts.outfit(color: Colors.redAccent))
          ),
        ],
      )
    );
  }

  void _toggleStatus(String id) {
    _dataService.toggleStatus(id);
    _refresh();
  }

  void _toggleFeatured(String id) {
    _dataService.toggleFeatured(id);
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      // key: _scaffoldKey, // PremiumScaffold builds Scaffold. _scaffoldKey on PremiumScaffold widget wont work for Scaffold methods if passed to super.
      // Wait. `PremiumScaffold` does NOT accept key for the internal Scaffold.
      // But I can pass `key` to `PremiumScaffold`? 
      // If I use `GlobalKey<ScaffoldState>`, I need to attach it to the `Scaffold` returned by `PremiumScaffold`.
      // `PremiumScaffold` does not expose `scaffoldKey`.
      // So I cannot use `_scaffoldKey.currentState.openEndDrawer()`.
      // BUT `Scaffold.of(context)` works if there is a parent Scaffold, which there isn't.
      // `Builder` inside `PremiumScaffold`?
      // `PremiumScaffold` returns `Scaffold`.
      // The `body` of `PremiumScaffold` is inside that Scaffold.
      // So `Scaffold.of(context)` inside `body` refers to `PremiumScaffold`'s Scaffold?
      // Yes.
      // So I can use `Scaffold.of(context).openEndDrawer()` inside the body.
      // So I don't need `_scaffoldKey`.
      
      title: 'Gestión del Blog',
      showBackButton: true,
      endDrawer: _buildFilterDrawer(),
      useScroll: false,
      usePadding: false,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.pushNamed(context, AppRoutes.adminBlogForm);
          _refresh();
        },
        backgroundColor: const Color(0xFFD4AF37),
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: Builder( // Wrap body in Builder to ensure context has access to PremiumScaffold's Scaffold
        builder: (context) {
          return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                   Row(
                     children: [
                       Expanded(
                         child: NeonInput(
                            label: 'Buscar artículo...', 
                            onChanged: (v) {
                              _searchQuery = v;
                              _refresh();
                            },
                          ),
                       ),
                       const SizedBox(width: 8),
                       GestureDetector(
                         onTap: () => Scaffold.of(context).openEndDrawer(),
                         child: Container(
                           padding: const EdgeInsets.all(12),
                           decoration: BoxDecoration(
                             color: const Color(0xFF001220),
                             borderRadius: BorderRadius.circular(12),
                             border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.5)),
                           ),
                           child: const Icon(Icons.filter_list, color: Color(0xFFD4AF37)),
                         ),
                       ),
                     ],
                   ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('Todos', 'Todos'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Publicados', 'Publicados'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Borradores', 'Borradores'),
                         const SizedBox(width: 8),
                        _buildFilterChip('Programados', 'Programados'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _articles.isEmpty 
              ? Center(child: Text('No hay artículos', style: GoogleFonts.outfit(color: Colors.white54)))
              : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                itemCount: _articles.length,
                itemBuilder: (context, index) {
                  final article = _articles[index];
                  return _buildArticleCard(article);
                },
              ),
            ),
          ],
        );
        }
      ),
    );
  }

  Widget _buildFilterDrawer() {
    return Drawer(
      backgroundColor: const Color(0xFF001225),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            Text('Filtros Avanzados', style: GoogleFonts.outfit(color: const Color(0xFFD4AF37), fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Text('Categoría', style: GoogleFonts.outfit(color: Colors.white70)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _filterCategory,
              dropdownColor: const Color(0xFF001225),
              items: ['Todas', ...blogCategories].map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(color: Colors.white)))).toList(),
              onChanged: (v) {
                 setState(() => _filterCategory = v!);
                 _refresh(); // immediate update or wait for button
              },
              decoration: const InputDecoration(
                filled: true,
                fillColor: Color(0xFF001220), 
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
              ),
            ),
            const Spacer(),
            NeonButton(
              text: 'Aplicar Filtros', 
              primary: true, 
              color: const Color(0xFF00E5FF), 
              textColor: Colors.black,
              onTap: () {
                _refresh();
                Navigator.pop(context);
              }
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String status) {
    final selected = _filterStatus == status;
    return GestureDetector(
      onTap: () {
        setState(() => _filterStatus = status);
        _refresh();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFD4AF37).withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? const Color(0xFFD4AF37) : Colors.white24),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            color: selected ? const Color(0xFFD4AF37) : Colors.white54,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildArticleCard(BlogArticle article) {
    Color statusColor = Colors.orangeAccent;
    String statusText = 'BORRADOR';
    if (article.status == 'published') {
      statusColor = Colors.greenAccent;
      statusText = 'PUBLICADO';
    } else if (article.status == 'scheduled') {
      statusColor = const Color(0xFFFF4081);
      statusText = 'PROGRAMADO';
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF001220),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  article.imageUrl, 
                  width: 60, 
                  height: 60, 
                  fit: BoxFit.cover,
                  errorBuilder: (_,__,___) => Container(width: 60, height: 60, color: Colors.grey),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(article.title, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      children: [
                        Text(
                          statusText,
                          style: GoogleFonts.outfit(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '• ${article.category}',
                          style: GoogleFonts.outfit(color: Colors.white54, fontSize: 10),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          // Stats Row
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Icon(Icons.visibility, color: Colors.white30, size: 14),
              const SizedBox(width: 4),
              Text('${article.views}', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12)),
              const SizedBox(width: 16),
              const Icon(Icons.thumb_up, color: Colors.white30, size: 14),
              const SizedBox(width: 4),
              Text('${article.likes}', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12)),
              const SizedBox(width: 16),
              const Icon(Icons.comment, color: Colors.white30, size: 14),
              const SizedBox(width: 4),
              Text('${article.comments.length}', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12)),
            ],
          ),
          
          const Divider(color: Colors.white10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: Icon(article.isFeatured ? Icons.star : Icons.star_border, color: article.isFeatured ? Colors.yellowAccent : Colors.white54),
                onPressed: () => _toggleFeatured(article.id),
                tooltip: 'Destacar',
              ),
               IconButton(
                icon: Icon(article.status == 'published' ? Icons.visibility : Icons.visibility_off, color: Colors.white54),
                onPressed: () => _toggleStatus(article.id),
                tooltip: 'Publicar/Despublicar',
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blueAccent),
                onPressed: () async {
                   await Navigator.pushNamed(context, AppRoutes.adminBlogForm, arguments: article);
                   _refresh();
                },
                tooltip: 'Editar',
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.redAccent),
                onPressed: () => _handleDelete(article.id),
                tooltip: 'Eliminar',
              ),
            ],
          )
        ],
      ),
    );
  }
}
