import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../components/neon_widgets.dart';
import '../../components/how_to_use_card.dart';
import '../../features/blog/services/content_service.dart';
import '../../features/blog/models/post_draft_model.dart';
import '../../navigation/app_routes.dart';

class AdminContentScreen extends StatefulWidget {
  const AdminContentScreen({Key? key}) : super(key: key);

  @override
  State<AdminContentScreen> createState() => _AdminContentScreenState();
}

class _AdminContentScreenState extends State<AdminContentScreen> with SingleTickerProviderStateMixin {
  final ContentService _service = ContentService.instance;
  late TabController _tabController;
  bool _isLoading = true;
  List<PostDraft> _drafts = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await _service.init();
    setState(() {
      _drafts = _service.getAllDrafts();
      _isLoading = false;
    });
  }

  void _deleteDraft(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF001220),
        title: const Text('Confirmar', style: TextStyle(color: Colors.white)),
        content: const Text('¿Eliminar este borrador?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _service.deleteDraft(id);
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Borrador eliminado')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final allDrafts = _drafts.where((d) => d.status == 'draft').toList();
    final published = _drafts.where((d) => d.status == 'published').toList();

    return Scaffold(
      backgroundColor: const Color(0xFF001220),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text('Gestor de Contenido (CMS)', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton.icon(
            onPressed: () => context.go(AppRoutes.adminBlog),
            icon: const Icon(Icons.public, color: Colors.greenAccent),
            label: const Text('Blog Externo', style: TextStyle(color: Colors.greenAccent)),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFD4AF37),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          tabs: [
            Tab(text: 'Todos (${_drafts.length})'),
            Tab(text: 'Borradores (${allDrafts.length})'),
            Tab(text: 'Publicados (${published.length})'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)))
          : Column(
              children: [
                // How to Use Card
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: HowToUseCard(
                    title: '¿Cómo gestionar contenido?',
                    icon: Icons.article_outlined,
                    accentColor: Color(0xFFD4AF37),
                    steps: [
                      'Toca "Nuevo Post" para crear contenido con IA o manual.',
                      'Usa las pestañas para filtrar borradores y publicados.',
                      'Edita, exporta o publica desde las acciones de cada post.',
                      'Usa "Blog Externo" para gestionar los archivos HTML exportados.',
                    ],
                  ),
                ),
                // Tab Content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildList(_drafts),
                      _buildList(allDrafts),
                      _buildList(published),
                    ],
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // Navigate to editor for new post
          await context.push('/admin/content/editor');
          await _loadData(); // Refresh list
        },
        backgroundColor: const Color(0xFFD4AF37),
        icon: const Icon(Icons.add, color: Colors.black),
        label: const Text('Nuevo Post', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildList(List<PostDraft> items) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.article_outlined, size: 64, color: Colors.white24),
            const SizedBox(height: 16),
            Text('Sin posts en esta categoría', style: GoogleFonts.outfit(color: Colors.white54)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final post = items[index];
        return _buildPostCard(post);
      },
    );
  }

  Widget _buildPostCard(PostDraft post) {
    final isPublished = post.status == 'published';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPublished ? Colors.greenAccent.withOpacity(0.5) : const Color(0xFFD4AF37).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with status
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: (isPublished ? Colors.greenAccent : const Color(0xFFD4AF37)).withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isPublished ? Colors.greenAccent : const Color(0xFFD4AF37),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isPublished ? 'PUBLICADO' : 'BORRADOR',
                    style: GoogleFonts.outfit(
                      color: Colors.black,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        post.source == 'both' ? Icons.public : post.source == 'external' ? Icons.language : Icons.phone_android,
                        size: 14,
                        color: Colors.white70,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        post.source == 'both' ? 'Blog + App' : post.source == 'external' ? 'Blog' : 'App',
                        style: GoogleFonts.outfit(color: Colors.white70, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  _formatDate(post.updatedAt),
                  style: GoogleFonts.outfit(color: Colors.white38, fontSize: 12),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.title.isEmpty ? '(Sin título)' : post.title,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (post.excerpt.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    post.excerpt,
                    style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (post.tags.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: post.tags.take(3).map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00E5FF).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          tag,
                          style: GoogleFonts.outfit(color: const Color(0xFF00E5FF), fontSize: 11),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),

          // Actions
          const Divider(color: Colors.white10, height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () async {
                    await context.push('/admin/content/editor/${post.id}');
                    await _loadData();
                  },
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Editar'),
                  style: TextButton.styleFrom(foregroundColor: const Color(0xFF00E5FF)),
                ),
                TextButton.icon(
                  onPressed: () => _deleteDraft(post.id),
                  icon: const Icon(Icons.delete, size: 18),
                  label: const Text('Eliminar'),
                  style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) return 'Hoy';
    if (diff.inDays == 1) return 'Ayer';
    if (diff.inDays < 7) return 'Hace ${diff.inDays} días';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
