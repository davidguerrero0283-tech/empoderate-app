import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../ui/theme/empoderate_theme.dart';
import '../components/premium_scaffold.dart';
import '../models/business_data.dart';
import 'industry_category_screen.dart';
import 'niche_confirmation_screen.dart'; // Needed for trending navigation
import '../components/premium_negocio_list_card.dart';
import '../components/premium_pink_neon_accordion.dart';
import '../components/business_hero_header.dart'; // [NEW] Premium Header
import 'package:go_router/go_router.dart';
import 'learning/module_guide_data.dart';
import '../navigation/app_routes.dart';

class MiNegocioRubroScreen extends StatefulWidget {
  const MiNegocioRubroScreen({Key? key}) : super(key: key);

  @override
  State<MiNegocioRubroScreen> createState() => _MiNegocioRubroScreenState();
}

class _MiNegocioRubroScreenState extends State<MiNegocioRubroScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'Todos';

  final List<String> _filters = [
    'Todos',
    'Baja Inversión',
    'Rápido Inicio', 
    'Desde Casa',
    'Populares'
  ];

  @override
  Widget build(BuildContext context) {
    // Filter categories based on search AND selected filter
    final filteredCategories = categoryData.map((cat) {
      // Filter rubros first
      final matchingRubros = cat.rubros.where((r) {
        final matchesSearch = _searchQuery.isEmpty || 
            r.name.toLowerCase().contains(_searchQuery.toLowerCase()) || 
            cat.name.toLowerCase().contains(_searchQuery.toLowerCase());
            
        bool matchesFilter = true;
        if (_selectedFilter != 'Todos') {
          if (_selectedFilter == 'Baja Inversión') {
            matchesFilter = r.investmentLevel == '\$';
          } else if (_selectedFilter == 'Rápido Inicio') {
            // Check if time estimate contains "1 Mes", "Inmediato", "1 Sem"
            matchesFilter = r.timeEstimate != null && 
                (r.timeEstimate!.contains('Inmediato') || 
                 r.timeEstimate!.contains('1 Sem') || 
                 r.timeEstimate!.contains('1 Mes'));
          } else if (_selectedFilter == 'Desde Casa') {
            matchesFilter = r.tags.any((t) => ['CASERO', 'REMOTO', 'ONLINE', 'HANDMADE'].contains(t));
          } else if (_selectedFilter == 'Populares') {
            matchesFilter = r.tags.contains('POPULAR') || r.tags.contains('ALTA DEMANDA');
          }
        }
        
        return matchesSearch && matchesFilter;
      }).toList();

      // Return new category object with ONLY matching rubros (or empty if none match)
      if (matchingRubros.isEmpty) return null;
      
      return IndustryCategory(
        id: cat.id,
        name: cat.name,
        icon: cat.icon,
        rubros: matchingRubros,
      );
    }).whereType<IndustryCategory>().toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0F1520),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 80),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             // 1. HERO HEADER (Replaces old Title)
            BusinessHeroHeader(
              title: 'Explora Industrias',
              categoryName: 'DIRECTORIO DE NEGOCIOS', 
              icon: Icons.storefront,
              onBackPressed: () => context.canPop() ? context.pop() : context.go(AppRoutes.home),
              isCompact: true, // [NEW] Smaller header
            ),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   const SizedBox(height: 24), // [NEW] Added Spacing
                   
                   // Intro Text
                  Center( // [NEW] Centered Text
                    child: Text(
                      'Selecciona el rubro para ver requisitos específicos.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        color: Colors.white60,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),

                  // --- NEW: EDUCATION GUIDE ---
                  GestureDetector(
                    onTap: () => context.push('/module_guide?type=start'),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: ModuleGuides.start.themeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: ModuleGuides.start.themeColor.withOpacity(0.5)),
                      ),
                      child: Row(
                        children: [
                           Container(
                             padding: const EdgeInsets.all(10),
                             decoration: BoxDecoration(color: Colors.black26, shape: BoxShape.circle),
                             child: Icon(ModuleGuides.start.icon, color: ModuleGuides.start.themeColor, size: 24),
                           ),
                           const SizedBox(width: 16),
                           Expanded(
                             child: Column(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               children: [
                                  Text('Guía Maestra: Elegir tu Rubro', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                  Text('Ventajas, Riesgos y Decisiones Clave.', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12)),
                               ],
                             ),
                           ),
                           Icon(Icons.arrow_forward_ios, color: ModuleGuides.start.themeColor, size: 14),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  
                  // NEW: 2 Pink Neon Accordions (Compact)
                  LayoutBuilder(
                    builder: (context, constraints) {
                      // Use Stack/Wrap logic or just simpler logic: 
                      // If width > 600, Row. Else Column. 
                      // But mostly mobile, so let's stick to Column for safety or Wrap.
                      // User requested: "Deben estar en fila (2 columnas) si cabe; si no cabe (móvil), se apilan"
                      // Since mobile is primary, let's use check width or simply Wrap.
                      bool isWide = constraints.maxWidth > 500;
                      
                      return Flex(
                        direction: isWide ? Axis.horizontal : Axis.vertical,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // BUTTON 1: ¿Por qué formalizarse?
                          Flexible(
                            flex: isWide ? 1 : 0,
                            child: PremiumPinkNeonAccordion(
                              title: 'Tu Idea de Negocio: El Primer Paso',
                              content: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Todo gran negocio nace de una idea clara. No necesitas ser experto, solo resolver un problema real.'),
                                  const SizedBox(height: 8),
                                  Text('Consejos para empezar con el pie derecho:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                  const SizedBox(height: 8),
                                  _buildBullet('Identifica qué sabes hacer mejor y qué te apasiona.'),
                                  _buildBullet('Investiga si hay personas dispuestas a pagar por ello.'),
                                  _buildBullet('Empieza en pequeño (MVP), valida y luego escala.'),
                                  _buildBullet('Explora los rubros abajo para encontrar tu nicho.'),
                                ],
                              ),
                            ),
                          ),
                          
                          SizedBox(width: 12, height: 12),
                          
                          // BUTTON 2: ¿Cómo se usa esta sección?
                          Flexible(
                            flex: isWide ? 1 : 0,
                            child: PremiumPinkNeonAccordion(
                              title: '¿Cómo se usa esta sección?',
                              content: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildNumbered('1', 'Elige tu rubro (industria) según tu idea.'),
                                  _buildNumbered('2', 'Selecciona tu modelo de negocio.'),
                                  _buildNumbered('3', 'Revisa los requisitos por secciones (legales, permisos, operación, impuestos, personal).'),
                                  _buildNumbered('4', 'Toca un requisito para ver pasos y fuentes oficiales.'),
                                  _buildNumbered('5', 'Marca tu avance para llevar control.'),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Guía informativa. Los requisitos pueden variar según actividad y distrito.',
                                    style: TextStyle(fontSize: 12, color: Colors.white54, fontStyle: FontStyle.italic),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- TRENDING SECTION (Carrusel) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('TENDENCIAS 🔥', style: GoogleFonts.outfit(color: EmpoderateTheme.goldStrong, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildTrendingCard(context, 'Food Truck', 'Gourmet Móvil', Icons.local_shipping, Colors.redAccent, 'ALTA RENTABILIDAD', '\$\$'),
                  _buildTrendingCard(context, 'Barbería', 'Estilo Masculino', Icons.content_cut, Colors.blueGrey, 'POPULAR', '\$'),
                  _buildTrendingCard(context, 'Ecommerce', 'Tienda Online', Icons.shopping_bag, Colors.blueAccent, 'SCALABLE', '\$'),
                  _buildTrendingCard(context, 'Spa', 'Relax & Salud', Icons.spa, Colors.teal, 'PREMIUM', '\$\$\$'),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Executive Search Bar (Premium Gold)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: EmpoderateTheme.safeBoxDecoration(
                  color: const Color(0xFF0F1520), // Deep Dark Navy
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: EmpoderateTheme.goldStrong.withOpacity(0.5), width: 1.0), // Gold Border
                  boxShadow: [
                    BoxShadow(color: EmpoderateTheme.goldStrong.withOpacity(0.05), blurRadius: 10) // Subtle Glow
                  ],
                ),
                child: TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                   style: GoogleFonts.outfit(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Buscar rubro...',
                    hintStyle: GoogleFonts.outfit(color: EmpoderateTheme.goldStrong.withOpacity(0.5)),
                    prefixIcon: Icon(Icons.search, color: EmpoderateTheme.goldStrong.withOpacity(0.8)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Smart Filters Pills
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: _filters.map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(
                        filter,
                        style: GoogleFonts.outfit(
                          color: isSelected ? Colors.black : Colors.white70,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (bool selected) {
                        setState(() {
                          // Allow re-selecting 'Todos' explicitly, or toggle others
                          _selectedFilter = (selected && filter != _selectedFilter) ? filter : 'Todos';
                        });
                      },
                      selectedColor: EmpoderateTheme.goldStrong,
                      backgroundColor: Colors.white.withOpacity(0.05),
                      side: BorderSide(
                        color: isSelected ? EmpoderateTheme.goldStrong : Colors.white12,
                        width: 1,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  );
                }).toList(),
              ),
            ),
            
            const SizedBox(height: 24),

            // Categories Grid
            if (filteredCategories.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(child: Text('No se encontraron resultados.', style: GoogleFonts.outfit(color: Colors.white54))),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: filteredCategories.length,
                  itemBuilder: (context, index) {
                     final category = filteredCategories[index];
                     // Enforcing Premium Gold Uniformity
                     final Color accent = EmpoderateTheme.goldStrong;

                      return PremiumNegocioListCard(
                      title: category.name,
                      subtitle: '${category.rubros.length} Tipos disponibles',
                      icon: category.icon,
                      accentColor: accent,
                      onTap: () {
                        context.push('/mi_negocio_rubro/category/${category.id}');
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check, color: EmpoderateTheme.cyanAccent, size: 14),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 13))),
        ],
      ),
    );
  }

  Widget _buildNumbered(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 18, height: 18,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: EmpoderateTheme.goldStrong.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Text(number, style: const TextStyle(color: EmpoderateTheme.goldStrong, fontSize: 11, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 13))),
        ],
      ),
    );
  }

  Widget _buildTrendingCard(BuildContext context, String title, String subtitle, IconData icon, Color color, String tag, String investment) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      decoration: EmpoderateTheme.safeBoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.2), color.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
             final category = categoryData.firstWhere((c) => c.rubros.any((r) => r.name.contains(title) || r.name == title));
             final rubro = category.rubros.firstWhere((r) => r.name.contains(title) || r.name == title);

             context.push('/mi_negocio_rubro/category/${category.id}/rubro/${rubro.id}');
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(icon, color: color, size: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: color.withOpacity(0.5)),
                      ),
                      child: Text(investment, style: GoogleFonts.outfit(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Text(title, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                Text(subtitle, style: GoogleFonts.outfit(color: Colors.white60, fontSize: 11)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(tag, style: GoogleFonts.outfit(color: color, fontSize: 9, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
