import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../ui/theme/empoderate_theme.dart';
import '../../components/premium_scaffold.dart';
import '../../components/neon_widgets.dart';
import '../../components/legal_shielding.dart';
import 'course_detail_screen.dart';
import 'learning_repository.dart';

class LearningCenterScreen extends StatefulWidget {
  const LearningCenterScreen({Key? key}) : super(key: key);

  @override
  State<LearningCenterScreen> createState() => _LearningCenterScreenState();
}

class _LearningCenterScreenState extends State<LearningCenterScreen> {
  String _search = '';
  String _selectedCategory = 'all'; // all, start, finance, marketing, hr, legal, management

  @override
  Widget build(BuildContext context) {
    // FILTER LOGIC
    final displayedCourses = LearningRepository.courses.where((c) {
      final matchesSearch = _search.isEmpty || 
             c.title.toLowerCase().contains(_search.toLowerCase()) || 
             c.description.toLowerCase().contains(_search.toLowerCase());
      
      final matchesCategory = _selectedCategory == 'all' || c.category == _selectedCategory;
      
      return matchesSearch && matchesCategory;
    }).toList();

    return PremiumScaffold(
      title: 'ACADEMIA EMPO',
      showBackButton: true,
      useScroll: true,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // EXPLANATION
            Text(
              'Tu universidad de negocios personal. Desde legalización hasta liderazgo.',
              style: GoogleFonts.outfit(
                color: Colors.white.withOpacity(0.85),
                fontSize: 14,
                fontWeight: FontWeight.w300,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),

            _buildSearchBar(),
            const SizedBox(height: 32),

            // FEATURED BANNER
            if (_selectedCategory == 'all' && _search.isEmpty) ...[
              const NeonSectionTitle(title: 'Curso Destacado'),
              const SizedBox(height: 12),
              _buildFeaturedBanner(context),
              const SizedBox(height: 32),

              // STATS
               _buildStatsBlock(),
              const SizedBox(height: 32),
            ],

            // CATEGORÍAS (INTERACTIVE)
            const NeonSectionTitle(title: 'Explorar por Área'),
            const SizedBox(height: 12),
             SizedBox(
              height: 110,
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                children: [
                   _buildCategoryFilter('Todo', 'all', Icons.grid_view, Colors.white),
                   _buildCategoryFilter('Inicio', 'start', Icons.rocket_launch, EmpoderateTheme.goldStrong),
                   _buildCategoryFilter('Legal', 'legal', Icons.gavel, Colors.orangeAccent),
                   _buildCategoryFilter('Finanzas', 'finance', Icons.pie_chart, EmpoderateTheme.cyanAccent),
                   _buildCategoryFilter('Marketing', 'marketing', Icons.campaign, EmpoderateTheme.purpleAccent),
                   _buildCategoryFilter('RRHH', 'hr', Icons.groups, Colors.blueAccent),
                   _buildCategoryFilter('Gestión', 'management', Icons.business_center, Colors.pinkAccent),
                ],
              ),
            ),
            const SizedBox(height: 32),

             // CURSOS RESULTS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const NeonSectionTitle(title: 'Catálogo'),
                Text('${displayedCourses.length} cursos', style: const TextStyle(color: Colors.white38)),
              ],
            ),
            const SizedBox(height: 16),
            
            if (displayedCourses.isEmpty)
              Container(
                padding: const EdgeInsets.all(32), 
                width: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(border: Border.all(color: Colors.white10), borderRadius: BorderRadius.circular(16)),
                child: Column(
                  children: [
                    const Icon(Icons.search_off, size: 48, color: Colors.white24),
                    const SizedBox(height: 16),
                    const Text("No encontramos cursos con ese filtro.", style: TextStyle(color: Colors.white30)),
                    TextButton(onPressed: () => setState(() { _search=''; _selectedCategory='all'; }), child: const Text('Ver Todo'))
                  ],
                ),
              ),

            LayoutBuilder(
              builder: (context, constraints) {
                int cols = 1;
                if (constraints.maxWidth > 800) cols = 2; // Tablet/Desktop
                
                double spacing = 16;
                double itemWidth = (constraints.maxWidth - (spacing * (cols - 1))) / cols;

                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: displayedCourses.map((course) => SizedBox(
                    width: itemWidth,
                    child: _NeonCourseCard(
                      title: course.title,
                      desc: course.description,
                      icon: course.icon,
                      color: course.color,
                      level: course.level,
                      onTap: () => context.push(
                        '/learning_center/course/${course.id}',
                      ),
                    ),
                  )).toList(),
                );
              },
            ),

            const SizedBox(height: 60),
            const LegalShielding(type: ShieldType.ai), 
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      decoration: BoxDecoration(
        color: EmpoderateTheme.deepBlue,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: EmpoderateTheme.purpleAccent.withOpacity(0.5)),
        boxShadow: [BoxShadow(color: EmpoderateTheme.purpleAccent.withOpacity(0.1), blurRadius: 10)],
      ),
      child: TextField(
        onChanged: (v) => setState(() => _search = v),
        style: GoogleFonts.outfit(color: Colors.white),
        decoration: InputDecoration(
          icon: const Icon(Icons.search, color: EmpoderateTheme.purpleAccent, size: 24),
          hintText: '¿Qué quieres aprender hoy?',
          hintStyle: GoogleFonts.outfit(color: Colors.white38, fontSize: 14),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildFeaturedBanner(BuildContext context) {
    if (LearningRepository.courses.isEmpty) return SizedBox.shrink();

    return NeonWideCard(
      borderColor: EmpoderateTheme.cyanAccent,
      isPremium: true,
      onTap: (){
         context.push('/learning_center/course/${LearningRepository.courses.first.id}');
      },
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white10, 
              shape: BoxShape.circle,
              border: Border.all(color: EmpoderateTheme.cyanAccent),
            ),
            child: Icon(Icons.star, color: EmpoderateTheme.cyanAccent, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: EmpoderateTheme.cyanAccent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('RECOMENDADO', style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 4),
                Text('Cómo Iniciar tu Negocio', style: EmpoderateTheme.titleStyle.copyWith(color: Colors.white, fontSize: 16)),
                const SizedBox(height: 4),
                Text('El curso esencial para todo nuevo emprendedor.', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsBlock() {
     return Container(
       padding: const EdgeInsets.all(16),
       decoration: BoxDecoration(
         color: EmpoderateTheme.deepBlue,
         borderRadius: BorderRadius.circular(16),
         border: Border.all(color: Colors.white10),
       ),
       child: Row(
         mainAxisAlignment: MainAxisAlignment.spaceAround,
         children: [
           _buildStatItem('Estudiantes', '2.5k', Icons.groups, EmpoderateTheme.cyanAccent),
           Container(width: 1, height: 40, color: Colors.white10),
           _buildStatItem('Cursos', '${LearningRepository.courses.length}', Icons.menu_book, Colors.greenAccent),
           Container(width: 1, height: 40, color: Colors.white10),
           _buildStatItem('Certificados', '150+', Icons.verified, Colors.pinkAccent),
         ],
       ),
     );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: GoogleFonts.outfit(color: Colors.white54, fontSize: 10)),
      ],
    );
  }

  Widget _buildCategoryFilter(String title, String id, IconData icon, Color color) {
    final isSelected = _selectedCategory == id;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 90,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : EmpoderateTheme.deepBlue,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? color : Colors.white10, width: isSelected ? 2 : 1),
          boxShadow: isSelected ? [BoxShadow(color: color.withOpacity(0.2), blurRadius: 10)] : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? color : Colors.white38, size: 24),
            const SizedBox(height: 8),
            Text(
              title, 
              style: GoogleFonts.outfit(
                color: isSelected ? Colors.white : Colors.white38, 
                fontSize: 12, 
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
              ), 
              textAlign: TextAlign.center, 
              maxLines: 1
            ),
          ],
        ),
      ),
    );
  }
}

class _NeonCourseCard extends StatefulWidget {
  final String title;
  final String desc;
  final IconData icon;
  final Color color;
  final String level;
  final VoidCallback onTap;

  const _NeonCourseCard({
    Key? key, 
    required this.title, 
    required this.desc, 
    required this.icon, 
    required this.color,
    required this.level,
    required this.onTap,
  }) : super(key: key);

  @override
  State<_NeonCourseCard> createState() => _NeonCourseCardState();
}

class _NeonCourseCardState extends State<_NeonCourseCard> {
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
              ? [BoxShadow(color: widget.color.withOpacity(0.3), blurRadius: 16)]
              : [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(widget.icon, color: widget.color, size: 32),
                 Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(8)),
                    child: Text(widget.level, style: const TextStyle(color: Colors.white70, fontSize: 10)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                widget.title,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.desc,
                style: GoogleFonts.outfit(color: Colors.white60, fontSize: 12, height: 1.3),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Text('LEER CURSO', style: TextStyle(color: widget.color, fontSize: 11, fontWeight: FontWeight.bold)),
                   Icon(Icons.arrow_forward, color: widget.color, size: 16)
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
