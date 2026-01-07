import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/blog_article.dart';
import '../models/comment.dart'; // Comment model
import '../features/blog/blog_data_service.dart'; // Service
import '../components/premium_scaffold.dart';
import '../features/analytics/analytics_service.dart';
import '../components/neon_widgets.dart';

class BlogArticleScreen extends StatefulWidget {
  const BlogArticleScreen({Key? key}) : super(key: key);

  @override
  State<BlogArticleScreen> createState() => _BlogArticleScreenState();
}

class _BlogArticleScreenState extends State<BlogArticleScreen> {
  double _fontSize = 16.0;
  final TextEditingController _commentController = TextEditingController();
  final BlogDataService _blogService = BlogDataService();
  late BlogArticle _article;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _article = ModalRoute.of(context)!.settings.arguments as BlogArticle;
      
      // Track read event - leveraging that build is called on navigation
      WidgetsBinding.instance.addPostFrameCallback((_) {
         AnalyticsService().trackAction('leer_articulo_blog', extra: {'articleTitle': _article.title});
         
         // Increment View count
         final updated = BlogArticle(
           id: _article.id,
           title: _article.title,
           subtitle: _article.subtitle,
           description: _article.description,
           category: _article.category,
           date: _article.date,
           imageUrl: _article.imageUrl,
           content: _article.content,
           keywords: _article.keywords,
           relatedIds: _article.relatedIds,
           status: _article.status,
           isFeatured: _article.isFeatured,
           metaTitle: _article.metaTitle,
           metaDescription: _article.metaDescription,
           contentRaw: _article.contentRaw,
           tags: _article.tags,
           views: _article.views + 1,
           likes: _article.likes,
           allowComments: _article.allowComments,
           comments: _article.comments,
           scheduledDate: _article.scheduledDate,
           publishedAt: _article.publishedAt,
         );
         _blogService.updateArticle(updated);
         // Don't setState here to avoid loop, just fire and forget or update local ref
      });
      _initialized = true;
    }
  }

  void _addComment() {
    if (_commentController.text.trim().isEmpty) return;

    final newComment = Comment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userName: 'Usuario Invitado', // Default for MVP
      text: _commentController.text.trim(),
      date: DateTime.now(),
    );

    setState(() {
      _article.comments.add(newComment);
      _blogService.updateArticle(_article);
      _commentController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Comentario publicado')));
  }

  void _toggleLike() {
    setState(() {
      final updatedLikeCount = _article.likes + 1;
      // Update local object mostly for UI, then save
       _article = BlogArticle(
           id: _article.id,
           title: _article.title,
           subtitle: _article.subtitle,
           description: _article.description,
           category: _article.category,
           date: _article.date,
           imageUrl: _article.imageUrl,
           content: _article.content,
           keywords: _article.keywords,
           relatedIds: _article.relatedIds,
           status: _article.status,
           isFeatured: _article.isFeatured,
           metaTitle: _article.metaTitle,
           metaDescription: _article.metaDescription,
           contentRaw: _article.contentRaw,
           tags: _article.tags,
           views: _article.views,
           likes: updatedLikeCount,
           allowComments: _article.allowComments,
           comments: _article.comments,
           scheduledDate: _article.scheduledDate,
           publishedAt: _article.publishedAt,
       );
       _blogService.updateArticle(_article);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) return const SizedBox.shrink(); // Wait for didChangeDependencies

    return PremiumScaffold(
      title: 'Artículo',
      showBackButton: true,
      floatingActionButton: FloatingActionButton.small(
        backgroundColor: const Color(0xFF001225),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0xFFD4AF37))),
        onPressed: () {
          setState(() {
            _fontSize = _fontSize == 16.0 ? 20.0 : 16.0;
          });
          ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text('Tamaño de letra: ${_fontSize == 16.0 ? "Normal" : "Grande"}'), duration: const Duration(seconds: 1)),
          );
        },
        child: const Icon(Icons.text_fields, color: Color(0xFFD4AF37)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header image
            Container(
              height: 200,
              decoration: BoxDecoration(
                image: DecorationImage(image: NetworkImage(_article.imageUrl), fit: BoxFit.cover),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black54, Colors.transparent],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Category usage
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF001225).withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(_article.category, style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12)),
            ),

              const SizedBox(height: 8),
              // Title
              Text(_article.title, style: GoogleFonts.outfit(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(_article.subtitle, style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 8),
              // Meta Row (Date, Read Time, Views)
              Row(
                children: [
                   Icon(Icons.calendar_today, size: 12, color: Colors.white54),
                   const SizedBox(width: 4),
                   Text(DateFormat('dd MMM yyyy').format(_article.date), style: GoogleFonts.outfit(color: Colors.white54, fontSize: 12)),
                   const SizedBox(width: 12),
                   Icon(Icons.schedule, size: 12, color: Colors.white54),
                   const SizedBox(width: 4),
                   Text('${_article.readTime.toStringAsFixed(0)} min lectura', style: GoogleFonts.outfit(color: Colors.white54, fontSize: 12)),
                   const Spacer(),
                   Icon(Icons.visibility, size: 14, color: Colors.white54),
                   const SizedBox(width: 4),
                   Text('${_article.views}', style: GoogleFonts.outfit(color: Colors.white54, fontSize: 12)),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Tags
              if (_article.tags.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _article.tags.map((tag) => Chip(
                    label: Text(tag, style: GoogleFonts.outfit(color: const Color(0xFFD4AF37), fontSize: 10)),
                    backgroundColor: const Color(0xFFD4AF37).withOpacity(0.1),
                    side: BorderSide(color: const Color(0xFFD4AF37).withOpacity(0.3)),
                    padding: EdgeInsets.zero,
                    labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                  )).toList(),
                ),
              if (_article.tags.isNotEmpty) const SizedBox(height: 24),

              // Rich Paragraph Content Rendering
              ..._buildRichContent(_article.contentRaw.isNotEmpty ? _article.contentRaw : _article.content),
              
              const SizedBox(height: 32),
              
              // Like Button Area
              Center(
                child: GestureDetector(
                  onTap: _toggleLike,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4AF37).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: const Color(0xFFD4AF37)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.thumb_up, color: Color(0xFFD4AF37)),
                        const SizedBox(width: 8),
                        Text('Me gusta (${_article.likes})', style: GoogleFonts.outfit(color: const Color(0xFFD4AF37))),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),
              
              // Comments Section
              if (_article.allowComments) ...[
                const NeonSectionTitle(title: 'Comentarios', color: Color(0xFF00E5FF)),
                const SizedBox(height: 16),
                
                // Comment List
                if (_article.comments.isEmpty)
                   Text('Sé el primero en comentar.', style: GoogleFonts.outfit(color: Colors.white54, fontStyle: FontStyle.italic)),
                   
                ..._article.comments.map((comment) => Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       Row(
                         children: [
                           CircleAvatar(
                             radius: 12,
                             backgroundColor: Colors.white10,
                             child: Icon(Icons.person, size: 14, color: Colors.white),
                           ),
                           const SizedBox(width: 8),
                           Text(comment.userName, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
                           const Spacer(),
                           Text(DateFormat('dd/MM/yy').format(comment.date), style: GoogleFonts.outfit(color: Colors.white30, fontSize: 10)),
                         ],
                       ),
                       const SizedBox(height: 8),
                       Text(comment.text, style: GoogleFonts.outfit(color: Colors.white70)),
                    ],
                  ),
                )).toList(),

                const SizedBox(height: 24),
                
                // Comment Form
                Text('Dejar un comentario', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white24),
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(0xFF001220),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          style: GoogleFonts.outfit(color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: 'Escribe tu opinión...',
                            hintStyle: TextStyle(color: Colors.white24),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send, color: Color(0xFF00E5FF)),
                        onPressed: _addComment,
                      ),
                    ],
                  ),
                ),
              ],
              
              const SizedBox(height: 48),
            ],
          ),
        ),
    );
  }

  List<Widget> _buildRichContent(String rawContent) {
    // Simple parser for Markdown-like syntax + HTML tags from editor
    final List<Widget> widgets = [];
    final lines = rawContent.split('\n');
    
    for (String line in lines) {
      String trimmed = line.trim();
      if (trimmed.isEmpty) {
        widgets.add(const SizedBox(height: 12));
        continue;
      }
      
      // Basic HTML tag stripping/handling for this View (advanced render would use flutter_html)
      // Here we just handle basic structure for now.
      
      if (trimmed.startsWith('## ') || trimmed.contains('<h2>')) {
        String text = trimmed.replaceAll('## ', '').replaceAll('<h2>', '').replaceAll('</h2>', '');
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: Text(
            text,
            style: GoogleFonts.outfit(
              color: const Color(0xFF00E5FF),
              fontSize: _fontSize + 4,
              fontWeight: FontWeight.bold,
            ),
          ),
        ));
      } else if (trimmed.startsWith('- ') || trimmed.startsWith('<li>')) {
        String text = trimmed.replaceAll('- ', '').replaceAll('<li>', '').replaceAll('</li>', '');
        widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: 4, left: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('• ', style: TextStyle(color: Color(0xFFD4AF37), fontSize: 16)),
              Expanded(
                child: Text(
                  text,
                  style: GoogleFonts.outfit(color: Colors.white70, fontSize: _fontSize),
                ),
              ),
            ],
          ),
        ));
      } else {
         // Cleanup simple tags for plain text display if package not available
         String text = trimmed.replaceAll('<p>', '').replaceAll('</p>', '')
                              .replaceAll('<b>', '').replaceAll('</b>', '') // would typically use RichTextSpan
                              .replaceAll('<i>', '').replaceAll('</i>', '');

         widgets.add(Text(
          text,
          style: GoogleFonts.outfit(
            color: Colors.white70,
            fontSize: _fontSize,
            height: 1.6, 
          ),
        ));
      }
    }
    return widgets;
  }
}
