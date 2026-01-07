import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../components/premium_scaffold.dart';
import '../../../components/neon_widgets.dart';
import '../../../features/blog/blog_data_service.dart';
import '../../../features/blog/categories_list.dart'; // Standard categories
import '../../../models/blog_article.dart';
import '../../../features/blog_generator/blog_service.dart';
import 'blog_form_widgets.dart'; // Custom helpers

class AdminBlogFormScreen extends StatefulWidget {
  const AdminBlogFormScreen({Key? key}) : super(key: key);

  @override
  State<AdminBlogFormScreen> createState() => _AdminBlogFormScreenState();
}

class _AdminBlogFormScreenState extends State<AdminBlogFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dataService = BlogDataService();
  final _aiService = BlogGeneratorService();

  // Controllers
  final _titleController = TextEditingController();
  final _subtitleController = TextEditingController();
  final _imgController = TextEditingController();
  final _contentController = TextEditingController();
  final _metaTitleController = TextEditingController();
  final _metaDescController = TextEditingController();
  final _keywordsController = TextEditingController();

  // State
  String? _articleId;
  String _category = blogCategories.first; // Default
  String _status = 'draft';
  bool _isFeatured = false;
  bool _isGenerating = false;
  bool _allowComments = true;
  
  // New CMS State
  List<String> _tags = [];
  bool _isScheduled = false;
  DateTime? _scheduledDate;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is BlogArticle && _articleId == null) {
      _articleId = args.id;
      _titleController.text = args.title;
      _subtitleController.text = args.subtitle;
      _imgController.text = args.imageUrl;
      _contentController.text = args.contentRaw.isNotEmpty ? args.contentRaw : args.content;
      _metaTitleController.text = args.metaTitle;
      _metaDescController.text = args.metaDescription;
      _keywordsController.text = args.keywords.join(', ');
      
      // CMS Fields
      if (blogCategories.contains(args.category)) {
        _category = args.category;
      } else {
        _category = blogCategories.first;
      }

      _status = args.status;
      _isFeatured = args.isFeatured;
      _tags = List.from(args.tags);
      _allowComments = args.allowComments;
      
      if (args.scheduledDate != null) {
        _isScheduled = true;
        _scheduledDate = args.scheduledDate;
      }
    }
  }

  Future<void> _generateWithAI() async {
    setState(() => _isGenerating = true);
    
    // Show dialog to get topic
    String topic = '';
    await showDialog(
      context: context, 
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF001225),
        title: Text('Generar con IA', style: GoogleFonts.outfit(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Ingresa el tema principal:', style: GoogleFonts.outfit(color: Colors.white70)),
            const SizedBox(height: 8),
            NeonInput(label: 'Tema', onChanged: (v) => topic = v),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(ctx), 
            child: Text('Generar', style: GoogleFonts.outfit(color: const Color(0xFFD4AF37)))
          ),
        ],
      )
    );

    if (topic.isNotEmpty) {
      try {
        final result = await _aiService.generateArticleAI(topic, _category);
        setState(() {
          _titleController.text = result.title;
          _subtitleController.text = result.subtitle;
          _contentController.text = result.sections.map((s) => '## ${s.title}\n\n${s.text}').join('\n\n');
          _keywordsController.text = result.keywords.join(', ');
          _tags = List.from(result.keywords); // Synced for convenience
          _imgController.text = result.coverImage;
          _metaTitleController.text = result.title;
          _metaDescController.text = result.summary;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Contenido generado por IA')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error IA: $e')));
      }
    }
    
    setState(() => _isGenerating = false);
  }
  
  Future<void> _showMagicDialog() async {
    String topic = '';
    String objective = 'Informar';
    String level = 'Básico';
    
    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF001225),
            title: Text('Botón Mágico ✨', style: GoogleFonts.outfit(color: Colors.white)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Genera estructura automática para tu artículo.', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 16),
                NeonInput(label: 'Tema del Bloque', onChanged: (v) => topic = v),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: objective,
                  items: ['Informar', 'Explicar', 'Checklist', 'Guía Paso a Paso']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(color: Colors.white))))
                      .toList(),
                  onChanged: (v) => setDialogState(() => objective = v!),
                  decoration: const InputDecoration(labelText: 'Objetivo', filled: true, fillColor: Color(0xFF001220)),
                  dropdownColor: const Color(0xFF001225),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: level,
                  items: ['Básico', 'Intermedio', 'Avanzado']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(color: Colors.white))))
                      .toList(),
                  onChanged: (v) => setDialogState(() => level = v!),
                  decoration: const InputDecoration(labelText: 'Nivel', filled: true, fillColor: Color(0xFF001220)),
                  dropdownColor: const Color(0xFF001225),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
              TextButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  if (topic.isNotEmpty) {
                    setState(() => _isGenerating = true);
                    await Future.delayed(const Duration(seconds: 1)); // UX Delay
                    final blocks = _aiService.generateSmartBlocks(topic, objective, level);
                    
                    setState(() {
                      if (_contentController.text.isEmpty) {
                        _contentController.text = blocks;
                      } else {
                        _contentController.text = "${_contentController.text}\n\n$blocks";
                      }
                      _isGenerating = false;
                    });
                     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bloques Mágicos Insertados ✨')));
                  }
                }, 
                child: Text('🪄 Generar', style: GoogleFonts.outfit(color: Colors.purpleAccent, fontWeight: FontWeight.bold))
              ),
            ],
          );
        }
      )
    );
  }
  
  Future<void> _pickScheduledDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _scheduledDate ?? now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFD4AF37),
              onPrimary: Colors.black,
              surface: Color(0xFF001225),
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      // Pick time
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_scheduledDate ?? now.add(const Duration(hours: 1))),
      );
      if (time != null) {
         setState(() {
           _scheduledDate = DateTime(picked.year, picked.month, picked.day, time.hour, time.minute);
         });
      }
    }
  }

  void _save(String actionType) {
    if (!_formKey.currentState!.validate()) return;
    
    // Determine status logic based on scheduling
    String finalStatus = _status;
    if (actionType == 'published') {
      if (_isScheduled && _scheduledDate != null && _scheduledDate!.isAfter(DateTime.now())) {
        finalStatus = 'scheduled';
      } else {
        finalStatus = 'published';
      }
    } else {
      finalStatus = 'draft';
    }

    final newArticle = BlogArticle(
      id: _articleId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text,
      subtitle: _subtitleController.text,
      description: _metaDescController.text.isNotEmpty ? _metaDescController.text : 'Sin descripción',
      category: _category,
      date: _isScheduled && _scheduledDate != null ? _scheduledDate! : DateTime.now(), // Publish date logic
      imageUrl: _imgController.text.isNotEmpty ? _imgController.text : 'https://via.placeholder.com/300',
      content: _contentController.text, 
      keywords: _keywordsController.text.split(',').map((e) => e.trim()).toList(),
      relatedIds: [],
      status: finalStatus,
      isFeatured: _isFeatured,
      metaTitle: _metaTitleController.text,
      metaDescription: _metaDescController.text,
      contentRaw: _contentController.text,
      // New fields
      tags: _tags,
      allowComments: _allowComments,
      scheduledDate: _isScheduled ? _scheduledDate : null,
      publishedAt: finalStatus == 'published' ? DateTime.now() : null, // If publishing now
    );

    if (_articleId == null) {
      _dataService.addArticle(newArticle);
    } else {
      _dataService.updateArticle(newArticle);
    }

    Navigator.pop(context);
    String msg = 'Borrador Guardado';
    if (finalStatus == 'published') msg = 'Artículo Publicado';
    if (finalStatus == 'scheduled') msg = 'Artículo Programado para ${DateFormat('dd/MM HH:mm').format(_scheduledDate!)}';
    
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: const Color(0xFF00E5FF).withOpacity(0.8),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      title: _articleId != null ? 'Editar Artículo' : 'Nuevo Artículo',
      showBackButton: true,
      usePadding: false, // We'll handle padding inside Form
      useScroll: true, // Let PremiumScaffold handle scrolling
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_isGenerating) 
                const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37))),
              
              NeonCard(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text('Datos Principales', style: GoogleFonts.outfit(color: const Color(0xFFD4AF37), fontWeight: FontWeight.bold))),
                        IconButton(
                          icon: const Icon(Icons.auto_awesome, color: Color(0xFFD4AF37)),
                          onPressed: _generateWithAI,
                          tooltip: 'Autocompletar con IA',
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    NeonInput(label: 'Título', controller: _titleController),
                    const SizedBox(height: 12),
                    NeonInput(label: 'Subtítulo', controller: _subtitleController),
                    const SizedBox(height: 12),
                    
                    // Category Dropdown
                    DropdownButtonFormField<String>(
                      value: _category,
                      dropdownColor: const Color(0xFF001225),
                      items: blogCategories.map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(color: Colors.white)))).toList(),
                      onChanged: (v) => setState(() => _category = v!),
                      decoration: const InputDecoration(
                        labelText: 'Categoría', 
                        labelStyle: TextStyle(color: Colors.white54),
                        filled: true,
                        fillColor: Color(0xFF001220), 
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                      ),
                    ),
                     const SizedBox(height: 12),
                    NeonInput(label: 'URL Imagen Portada', controller: _imgController),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              NeonCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Row(
                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       children: [
                         Expanded(
                           child: Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               Text('Contenido', style: GoogleFonts.outfit(color: const Color(0xFFD4AF37), fontWeight: FontWeight.bold)),
                               const SizedBox(height: 8),
                               InkWell(
                                 onTap: _showMagicDialog,
                                 borderRadius: BorderRadius.circular(8),
                                 child: Container(
                                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                   decoration: BoxDecoration(
                                     gradient: const LinearGradient(colors: [Colors.blueAccent, Colors.purpleAccent]),
                                     borderRadius: BorderRadius.circular(8),
                                     boxShadow: [
                                       BoxShadow(
                                         color: Colors.blueAccent.withOpacity(0.3),
                                         blurRadius: 8,
                                         offset: const Offset(0, 2),
                                       )
                                     ]
                                   ),
                                   child: Row(
                                     mainAxisSize: MainAxisSize.min,
                                     children: [
                                       const Icon(Icons.auto_fix_high, color: Colors.white, size: 18),
                                       const SizedBox(width: 8),
                                       Text('🪄 Crear bloques automáticos', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
                                     ],
                                   ),
                                 ),
                               ),
                             ],
                           ),
                         ),
                         const Icon(Icons.edit_note, color: Colors.white54),
                       ],
                     ),
                     const SizedBox(height: 12),
                     
                     // Custom Rich Text Toolbar
                     RichTextToolbar(controller: _contentController),
                     
                     TextField(
                       controller: _contentController,
                       maxLines: 15,
                       style: GoogleFonts.outfit(color: Colors.white),
                       decoration: const InputDecoration(
                         hintText: 'Escribe aquí... (Usa la barra superior para formato)',
                         hintStyle: TextStyle(color: Colors.white24),
                         border: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                         enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                         focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFFD4AF37))),
                         fillColor: Color(0xFF001220),
                         filled: true,
                       ),
                     ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
               NeonCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Text('SEO & Configuración', style: GoogleFonts.outfit(color: const Color(0xFFD4AF37), fontWeight: FontWeight.bold)),
                     const SizedBox(height: 12),
                     
                     // Tags Input
                     NeonTagInput(
                       initialTags: _tags,
                       onChanged: (newTags) => _tags = newTags,
                     ),
                     const SizedBox(height: 12),
                     
                     NeonInput(label: 'Meta Title', controller: _metaTitleController),
                     NeonInput(label: 'Meta Description', controller: _metaDescController),
                     NeonInput(label: 'Palabras Clave (SEO)', controller: _keywordsController),
                     
                     const Divider(color: Colors.white24, height: 32),
                     
                     // Switches
                     SwitchListTile(
                       title: Text('Artículo Destacado', style: GoogleFonts.outfit(color: Colors.white)),
                       value: _isFeatured,
                       activeColor: const Color(0xFFD4AF37),
                       onChanged: (v) => setState(() => _isFeatured = v),
                     ),
                     SwitchListTile(
                       title: Text('Permitir Comentarios', style: GoogleFonts.outfit(color: Colors.white)),
                       value: _allowComments,
                       activeColor: const Color(0xFF00E5FF),
                       onChanged: (v) => setState(() => _allowComments = v),
                     ),
                     
                     SwitchListTile(
                       title: Text('Programar Publicación', style: GoogleFonts.outfit(color: Colors.white)),
                       subtitle: _isScheduled && _scheduledDate != null 
                           ? Text('Fecha: ${DateFormat('dd MMMM yyyy HH:mm').format(_scheduledDate!)}', style: const TextStyle(color: Color(0xFFD4AF37)))
                           : null,
                       value: _isScheduled,
                       activeColor: const Color(0xFFFF4081),
                       onChanged: (v) {
                         setState(() => _isScheduled = v);
                         if (v) _pickScheduledDate();
                       },
                     ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              Row(
                children: [
                  Expanded(
                    child: NeonButton(
                      text: 'Guardar Borrador',
                      primary: false,
                      color: Colors.orangeAccent,
                      textColor: Colors.orangeAccent,
                      onTap: () => _save('draft'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: NeonButton(
                      text: _isScheduled ? 'PROGRAMAR' : 'PUBLICAR',
                      primary: true,
                      color: _isScheduled ? const Color(0xFFFF4081) : const Color(0xFF00E676),
                      textColor: Colors.black,
                      onTap: () => _save('published'), // Logic handles status
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
