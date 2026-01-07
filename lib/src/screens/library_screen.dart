import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../ui/theme/empoderate_theme.dart';
import '../components/premium_scaffold.dart';
import '../components/neon_widgets.dart';
import '../components/legal_shielding.dart';
import 'library_detail_screen.dart';
import '../data/library_data.dart'; // New data source

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({Key? key}) : super(key: key);

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  String _searchQuery = '';
  List<ResourceFile> _searchResults = [];

  // Mapping for Category Metadata
  final Map<String, Map<String, dynamic>> _categoryMeta = {
    LibraryDataService.catBusiness: {'title': 'Plantillas Empresariales', 'desc': 'Modelos de negocio, planes y estrategias.', 'icon': Icons.description_outlined, 'color': EmpoderateTheme.purpleAccent},
    LibraryDataService.catLegal: {'title': 'Documentos Legales', 'desc': 'Contratos y acuerdos listos para usar.', 'icon': Icons.gavel_outlined, 'color': EmpoderateTheme.gold},
    LibraryDataService.catForms: {'title': 'Formularios Oficiales', 'desc': 'Trámites gubernamentales y solicitudes.', 'icon': Icons.assignment_outlined, 'color': EmpoderateTheme.cyanAccent},
    LibraryDataService.catAccounting: {'title': 'Recursos Contables', 'desc': 'Libros diarios, balances y facturas.', 'icon': Icons.calculate_outlined, 'color': Colors.greenAccent},
    LibraryDataService.catHr: {'title': 'Recursos Humanos', 'desc': 'Contratos laborales y evaluaciones.', 'icon': Icons.groups_outlined, 'color': const Color(0xFFFF4DFF)},
    LibraryDataService.catEducation: {'title': 'Material Educativo', 'desc': 'Guías PDF, ebooks y manuales.', 'icon': Icons.menu_book_outlined, 'color': EmpoderateTheme.cyanAccent},
  };

  void _onSearch(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isNotEmpty) {
        _searchResults = LibraryDataService.instance.searchResources(query);
      } else {
        _searchResults = [];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      title: 'BIBLIOTECA DE RECURSOS',
      showBackButton: true,
      useScroll: true,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // EXPLANATION
            Text(
              'Encuentra plantillas, documentos, formularios, guías oficiales y recursos esenciales para gestionar y hacer crecer tu negocio.',
              style: GoogleFonts.outfit(
                color: Colors.white.withOpacity(0.85),
                fontSize: 14,
                fontWeight: FontWeight.w300,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),

            // SEARCH BAR
            _buildSearchBar(),
            
            // SHOW SEARCH RESULTS IF ACTIVE
            if (_searchQuery.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                'Resultados para "$_searchQuery":',
                style: EmpoderateTheme.titleStyle.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 16),
              if (_searchResults.isEmpty)
                _buildEmptyState()
              else
                ..._searchResults.map((r) => _buildResourceRow(r)).toList(),
              const SizedBox(height: 32),
            ] else ...[
              const SizedBox(height: 32),
              // RECURSOS PREMIUM
              _buildPremiumBanner(),
              const SizedBox(height: 32),

              // CATEGORÍAS PRINCIPALES
              Text(
                'Categorías de Recursos',
                style: EmpoderateTheme.titleStyle.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 16),
              _buildCategoriesGrid(),

              const SizedBox(height: 60),
              const LegalShielding(type: ShieldType.ai), 
              const SizedBox(height: 40),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
     return Center(
       child: Padding(
         padding: const EdgeInsets.all(24.0),
         child: Column(
           children: [
             Icon(Icons.search_off, size: 48, color: Colors.white24),
             const SizedBox(height: 12),
             Text(
               'No se encontraron recursos.',
               style: GoogleFonts.outfit(color: Colors.white70, fontSize: 16),
             ),
             Text(
               'Prueba con: contrato, planilla, flujo de caja...',
               style: GoogleFonts.outfit(color: Colors.white38, fontSize: 14),
             ),
           ],
         ),
       ),
     );
  }

  Widget _buildResourceRow(ResourceFile r) {
    final catMeta = _categoryMeta[r.categoryId] ?? {};
    final color = (catMeta['color'] as Color?) ?? Colors.white;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Container(
             padding: const EdgeInsets.all(8),
             decoration: BoxDecoration(
               color: color.withOpacity(0.1),
               borderRadius: BorderRadius.circular(8),
             ),
             child: Icon(Icons.description, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  r.name,
                  style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                     _buildTagChip(r.format, Colors.grey),
                     const SizedBox(width: 6),
                     if (r.isPro) _buildTagChip('PRO', EmpoderateTheme.gold),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.download_rounded, color: Colors.white70),
            onPressed: () {
               ScaffoldMessenger.of(context).showSnackBar(
                 SnackBar(content: Text('Descargando ${r.name}...')),
               );
               LibraryDataService.instance.incrementDownload(r.name);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTagChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3), width: 0.5),
      ),
      child: Text(
        label,
        style: GoogleFonts.outfit(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      decoration: BoxDecoration(
        color: EmpoderateTheme.deepBlue,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: EmpoderateTheme.cyanAccent.withOpacity(0.5)),
        boxShadow: [BoxShadow(color: EmpoderateTheme.cyanAccent.withOpacity(0.1), blurRadius: 10)],
      ),
      child: TextField(
        style: GoogleFonts.outfit(color: Colors.white),
        onChanged: _onSearch,
        decoration: InputDecoration(
          icon: const Icon(Icons.search, color: EmpoderateTheme.cyanAccent, size: 24),
          hintText: 'Buscar recurso...',
          hintStyle: GoogleFonts.outfit(color: Colors.white38, fontSize: 14),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildPremiumBanner() {
    return NeonWideCard(
      borderColor: EmpoderateTheme.goldStrong,
      onTap: (){},
      child: Row(
        children: [
          Icon(Icons.workspace_premium, color: EmpoderateTheme.goldStrong, size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Recursos Premium', style: EmpoderateTheme.titleStyle.copyWith(fontSize: 18, color: EmpoderateTheme.goldStrong)),
                const SizedBox(height: 4),
                Text('Accede a plantillas y contratos avanzados.', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: EmpoderateTheme.goldStrong),
        ],
      ),
    );
  }

  Widget _buildCategoriesGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        int cols = 1;
        if (constraints.maxWidth > 900) cols = 3;
        else if (constraints.maxWidth > 600) cols = 2;
        
        double spacing = 16;
        double itemWidth = (constraints.maxWidth - (spacing * (cols - 1))) / cols;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: _categoryMeta.entries.map((entry) {
             final key = entry.key;
             final meta = entry.value;

             return SizedBox(
              width: itemWidth,
              child: _NeonCategoryCard(
                title: meta['title'],
                desc: meta['desc'],
                icon: meta['icon'],
                color: meta['color'],
                onTap: () => context.push(
                  '/library/category/$key',
                  extra: meta,
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _NeonCategoryCard extends StatefulWidget {
  final String title;
  final String desc;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _NeonCategoryCard({
    Key? key,
    required this.title,
    required this.desc,
    required this.icon,
    required this.color,
    required this.onTap,
  }) : super(key: key);

  @override
  State<_NeonCategoryCard> createState() => _NeonCategoryCardState();
}

class _NeonCategoryCardState extends State<_NeonCategoryCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: EmpoderateTheme.deepBlue,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _isHovered ? widget.color : widget.color.withOpacity(0.3),
              width: _isHovered ? 1.5 : 1,
            ),
            boxShadow: _isHovered 
              ? [BoxShadow(color: widget.color.withOpacity(0.2), blurRadius: 12)]
              : [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(widget.icon, color: widget.color, size: 36),
              const SizedBox(height: 12),
              Text(
                widget.title,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.desc,
                style: GoogleFonts.outfit(color: Colors.white60, fontSize: 13, height: 1.3),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
