import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../components/neon_widgets.dart';
import '../../../components/how_to_use_card.dart';
import '../../../features/blog/services/content_service.dart';
import '../../../features/blog/models/post_draft_model.dart';
import '../../../navigation/app_routes.dart';

class ExternalBlogScreen extends StatefulWidget {
  const ExternalBlogScreen({Key? key}) : super(key: key);

  @override
  State<ExternalBlogScreen> createState() => _ExternalBlogScreenState();
}

class _ExternalBlogScreenState extends State<ExternalBlogScreen> {
  final ContentService _service = ContentService.instance;
  bool _isLoading = true;
  List<PostDraft> _exportedPosts = [];
  DateTime? _lastExport;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await _service.init();
    final allPosts = _service.getAllDrafts();
    
    // Filter posts that are published and have source external or both
    _exportedPosts = allPosts.where((p) => 
      p.status == 'published' && (p.source == 'external' || p.source == 'both')
    ).toList();
    
    // Mock last export time
    _lastExport = DateTime.now().subtract(const Duration(minutes: 35));

    setState(() => _isLoading = false);
  }

  Future<void> _generateIndex() async {
    await _simulateAsyncTask('Generando index.html...');
    final html = _service.generateIndexHTML(_exportedPosts);
    // In real app: File('/web/blog/index.html').writeAsString(html);
    _showSuccess('index.html generado exitosamente (${html.length} bytes)');
  }

  Future<void> _generateSitemap() async {
    await _simulateAsyncTask('Generando sitemap.xml...');
    final xml = _service.generateSitemapXML(_exportedPosts);
    // In real app: File('/web/blog/sitemap.xml').writeAsString(xml);
    _showSuccess('sitemap.xml generado con ${_exportedPosts.length + 1} URLs');
  }

  Future<void> _openFolder() async {
    // Show dialog with instructions since we can't open local folder from browser easily in all envs
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF001220),
        title: const Text('Carpeta de Salida', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ruta local de archivos generados:',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white24),
              ),
              child: const Row(
                children: [
                  Icon(Icons.folder, color: Colors.amber, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '/web/blog/',
                      style: TextStyle(color: Colors.greenAccent, fontFamily: 'monospace'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Instrucciones para Hostinger:',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              '1. Sube el contenido de esta carpeta a /public_html/blog/ en tu FTP.\n'
              '2. Asegúrate de incluir la carpeta de imágenes si aplica.\n'
              '3. Verifica que index.html sea accesible.',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  Future<void> _simulateAsyncTask(String message) async {
    setState(() => _isLoading = true);
    if (mounted) {
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), duration: const Duration(milliseconds: 800)));
    }
    await Future.delayed(const Duration(milliseconds: 800)); // Mock processing
    setState(() {
      _lastExport = DateTime.now();
      _isLoading = false;
    });
  }

  void _showSuccess(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ $msg'), backgroundColor: Colors.green),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF001220),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text('Blog Externo (Hostinger)', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [const Color(0xFF00E676).withOpacity(0.1), const Color(0xFF00E5FF).withOpacity(0.1)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF00E676).withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.public, color: Color(0xFF00E676), size: 32),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Estado de Exportación', style: GoogleFonts.outfit(color: Colors.white54, fontSize: 13)),
                            const SizedBox(height: 4),
                            Text('Listo para Subir', style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                            Text(
                              'Última generación: ${_lastExport != null ? "${_lastExport!.hour}:${_lastExport!.minute}" : "N/A"}',
                              style: GoogleFonts.outfit(color: Colors.white38, fontSize: 12),
                            ),
                          ],
                        ),
                        const Spacer(),
                        ElevatedButton.icon(
                          onPressed: _openFolder,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white10,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            side: const BorderSide(color: Colors.white24),
                          ),
                          icon: const Icon(Icons.folder_open, size: 18),
                          label: const Text('Abrir Carpeta'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Actions Grid
                  Row(
                    children: [
                      Expanded(
                        child: NeonButton(
                          text: 'Regenerar Índice',
                          icon: Icons.list_alt,
                          onTap: _generateIndex,
                          color: Colors.orangeAccent,
                          primary: false,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: NeonButton(
                          text: 'Generar Sitemap',
                          icon: Icons.map,
                          onTap: _generateSitemap,
                          color: Colors.purpleAccent,
                          primary: false,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),

                  // Info Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.info_outline, color: Colors.blueAccent, size: 20),
                            const SizedBox(width: 8),
                            Text('Guía para Hostinger', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Genera el índice y el sitemap después de publicar nuevos artículos. Sube todos los archivos generados en /web/blog/ a tu servidor FTP manual o automáticamente.',
                          style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                  NeonSectionTitle(
                    title: 'Archivos Generados (${_exportedPosts.isEmpty ? 0 : _exportedPosts.length + 2})', 
                    color: Colors.white
                  ),
                  const SizedBox(height: 16),

                  if (_exportedPosts.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40.0),
                        child: Text(
                          'No hay posts para exportar aún.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(color: Colors.white54),
                        ),
                      ),
                    )
                  else
                    Column(
                      children: [
                         // Static Files
                        _buildFileItem('index.html', 'Página Principal', Colors.orange),
                        _buildFileItem('sitemap.xml', 'Mapa del Sitio', Colors.purple),
                        const Divider(color: Colors.white10),
                        // Posts
                        ..._exportedPosts.map((post) => _buildExportItem(post)),
                      ],
                    ),

                  const SizedBox(height: 80),
                ],
              ),
      ),
    );
  }
  
  Widget _buildFileItem(String filename, String desc, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Icon(Icons.description, color: color, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  filename,
                  style: GoogleFonts.robotoMono(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Text(
                  desc,
                  style: GoogleFonts.outfit(color: Colors.white54, fontSize: 11),
                ),
              ],
            ),
          ),
          const Icon(Icons.check_circle, color: Colors.greenAccent, size: 16),
        ],
      ),
    );
  }

  Widget _buildExportItem(PostDraft post) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          const Icon(Icons.html, color: Colors.blueGrey, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${post.slug}.html',
                  style: GoogleFonts.robotoMono(color: Colors.white70),
                ),
                Text(
                  post.title,
                  style: GoogleFonts.outfit(color: Colors.white38, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
