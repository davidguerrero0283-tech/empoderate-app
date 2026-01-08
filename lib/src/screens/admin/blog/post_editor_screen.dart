import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../components/neon_widgets.dart';
import '../../../features/blog/models/post_draft_model.dart';
import '../../../features/blog/services/content_service.dart';
import '../../../navigation/app_routes.dart';

class PostEditorScreen extends StatefulWidget {
  final String? draftId;

  const PostEditorScreen({Key? key, this.draftId}) : super(key: key);

  @override
  State<PostEditorScreen> createState() => _PostEditorScreenState();
}

class _PostEditorScreenState extends State<PostEditorScreen> {
  final ContentService _service = ContentService.instance;
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _keywordCtrl;
  late TextEditingController _titleCtrl;
  late TextEditingController _slugCtrl;
  late TextEditingController _excerptCtrl;
  late TextEditingController _contentCtrl;
  late TextEditingController _tagsCtrl;
  late TextEditingController _imageUrlCtrl;
  late TextEditingController _imagePromptCtrl;

  PostDraft? _draft;
  String _source = 'both';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _keywordCtrl = TextEditingController();
    _titleCtrl = TextEditingController();
    _slugCtrl = TextEditingController();
    _excerptCtrl = TextEditingController();
    _contentCtrl = TextEditingController();
    _tagsCtrl = TextEditingController();
    _imageUrlCtrl = TextEditingController();
    _imagePromptCtrl = TextEditingController();

    if (widget.draftId != null) {
      _loadDraft();
    }
  }

  void _loadDraft() {
    _draft = _service.getDraftById(widget.draftId!);
    if (_draft != null) {
      _titleCtrl.text = _draft!.title;
      _slugCtrl.text = _draft!.slug;
      _excerptCtrl.text = _draft!.excerpt;
      _contentCtrl.text = _draft!.content;
      _tagsCtrl.text = _draft!.tags.join(', ');
      _imageUrlCtrl.text = _draft!.imageUrl;
      _imagePromptCtrl.text = _draft!.imagePrompt;
      _source = _draft!.source;
    }
  }

  Future<void> _generateDraft() async {
    if (_keywordCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa un tema o keyword')),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Simulate generation delay
    await Future.delayed(const Duration(milliseconds: 800));

    final generated = _service.generateMockContent(_keywordCtrl.text.trim());

    setState(() {
      _titleCtrl.text = generated['title']!;
      _slugCtrl.text = generated['slug']!;
      _excerptCtrl.text = generated['excerpt']!;
      _contentCtrl.text = generated['content']!;
      _imagePromptCtrl.text = generated['imagePrompt']!;
      _isLoading = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✨ Borrador generado con IA mock')),
      );
    }
  }

  Future<void> _saveDraft() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final tags = _tagsCtrl.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

    if (_draft == null) {
      // Create new
      _draft = PostDraft(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleCtrl.text,
        slug: _slugCtrl.text,
        excerpt: _excerptCtrl.text,
        content: _contentCtrl.text,
        tags: tags,
        imagePrompt: _imagePromptCtrl.text,
        imageUrl: _imageUrlCtrl.text,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        status: 'draft',
        source: _source,
      );
      await _service.createDraft(_draft!);
    } else {
      // Update existing
      _draft = _draft!.copyWith(
        title: _titleCtrl.text,
        slug: _slugCtrl.text,
        excerpt: _excerptCtrl.text,
        content: _contentCtrl.text,
        tags: tags,
        imagePrompt: _imagePromptCtrl.text,
        imageUrl: _imageUrlCtrl.text,
        source: _source,
        updatedAt: DateTime.now(),
      );
      await _service.updateDraft(_draft!);
    }

    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Borrador guardado')),
      );
    }
  }

  Future<void> _publish() async {
    if (_draft == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Guarda el borrador primero')),
      );
      return;
    }

    await _saveDraft();
    await _service.publishDraft(_draft!.id);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 Publicado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
      context.pop();
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
        title: Text(
          widget.draftId == null ? 'Nuevo Post' : 'Editar Post',
          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_draft != null)
            TextButton.icon(
              onPressed: _isLoading ? null : _publish,
              icon: const Icon(Icons.publish, color: Colors.greenAccent),
              label: const Text('Publicar', style: TextStyle(color: Colors.greenAccent)),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Generator Section
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.deepPurpleAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.deepPurpleAccent.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.auto_awesome, color: Colors.deepPurpleAccent),
                              const SizedBox(width: 12),
                              Text(
                                'Generador IA (Mock)',
                                style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Ingresa un tema o keyword y genera contenido automáticamente',
                            style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14),
                          ),
                          const SizedBox(height: 16),
                          NeonInput(
                            label: 'Tema / Keyword',
                            hint: 'Ej: Contabilidad para Pymes',
                            controller: _keywordCtrl,
                          ),
                          const SizedBox(height: 16),
                          NeonButton(
                            text: 'Generar Borrador con IA',
                            icon: Icons.auto_awesome,
                            onTap: _generateDraft,
                            color: Colors.deepPurpleAccent,
                            primary: true,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),
                    const NeonSectionTitle(title: 'Contenido del Post', color: Color(0xFFD4AF37)),
                    const SizedBox(height: 16),

                    // Title
                    NeonInput(
                      label: 'Título *',
                      hint: 'Título del artículo',
                      controller: _titleCtrl,
                      validator: (v) => v?.isEmpty ?? true ? 'Requerido' : null,
                      onChanged: (v) {
                        // Auto-generate slug
                        _slugCtrl.text = PostDraft.generateSlug(v);
                      },
                    ),

                    // Slug
                    NeonInput(
                      label: 'Slug (URL) *',
                      hint: 'se-genera-automaticamente',
                      controller: _slugCtrl,
                      validator: (v) => v?.isEmpty ?? true ? 'Requerido' : null,
                    ),

                    // Excerpt
                    NeonInput(
                      label: 'Extracto *',
                      hint: 'Resumen breve para SEO y previews',
                      controller: _excerptCtrl,
                      maxLines: 3,
                      validator: (v) => v?.isEmpty ?? true ? 'Requerido' : null,
                    ),

                    // Content
                    NeonInput(
                      label: 'Contenido (Markdown) *',
                      hint: 'Usa # para títulos, ** para negritas, - para listas',
                      controller: _contentCtrl,
                      maxLines: 15,
                      validator: (v) => v?.isEmpty ?? true ? 'Requerido' : null,
                    ),

                    // Tags
                    NeonInput(
                      label: 'Tags (separados por comas)',
                      hint: 'finanzas, pymes, contabilidad',
                      controller: _tagsCtrl,
                    ),

                    const SizedBox(height: 32),
                    const NeonSectionTitle(title: 'Imagen de Portada', color: Colors.cyan),
                    const SizedBox(height: 16),

                    // Image URL
                    NeonInput(
                      label: 'URL de Imagen',
                      hint: 'https://...',
                      controller: _imageUrlCtrl,
                    ),

                    // Image Prompt (read-only, generated by AI)
                    NeonInput(
                      label: 'Prompt sugerido para IA',
                      hint: 'Se genera automáticamente',
                      controller: _imagePromptCtrl,
                      maxLines: 2,
                    ),

                    const SizedBox(height: 32),
                    const NeonSectionTitle(title: 'Destino de Publicación', color: Colors.orange),
                    const SizedBox(height: 16),

                    // Source selector
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RadioListTile<String>(
                            title: const Text('Blog Externo + App', style: TextStyle(color: Colors.white)),
                            subtitle: const Text('Publicar en ambos destinos', style: TextStyle(color: Colors.white54)),
                            value: 'both',
                            groupValue: _source,
                            activeColor: const Color(0xFFD4AF37),
                            onChanged: (v) => setState(() => _source = v!),
                          ),
                          RadioListTile<String>(
                            title: const Text('Solo Blog Externo (Hostinger)', style: TextStyle(color: Colors.white)),
                            subtitle: const Text('Para blog estático/SEO', style: TextStyle(color: Colors.white54)),
                            value: 'external',
                            groupValue: _source,
                            activeColor: const Color(0xFFD4AF37),
                            onChanged: (v) => setState(() => _source = v!),
                          ),
                          RadioListTile<String>(
                            title: const Text('Solo App (Recursos)', style: TextStyle(color: Colors.white)),
                            subtitle: const Text('Biblioteca interna', style: TextStyle(color: Colors.white54)),
                            value: 'app',
                            groupValue: _source,
                            activeColor: const Color(0xFFD4AF37),
                            onChanged: (v) => setState(() => _source = v!),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: NeonButton(
                            text: 'Guardar Borrador',
                            icon: Icons.save,
                            onTap: _saveDraft,
                            color: const Color(0xFF00E5FF),
                            primary: false,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: NeonButton(
                            text: _draft?.status == 'published' ? 'Actualizar' : 'Publicar',
                            icon: Icons.publish,
                            onTap: _publish,
                            color: Colors.greenAccent,
                            primary: true,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _keywordCtrl.dispose();
    _titleCtrl.dispose();
    _slugCtrl.dispose();
    _excerptCtrl.dispose();
    _contentCtrl.dispose();
    _tagsCtrl.dispose();
    _imageUrlCtrl.dispose();
    _imagePromptCtrl.dispose();
    super.dispose();
  }
}
