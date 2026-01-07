import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../components/premium_scaffold.dart';
import '../components/neon_widgets.dart';
import '../components/visibility_builder.dart';
import '../navigation/app_routes.dart';
import 'package:go_router/go_router.dart';
import '../features/analytics/analytics_service.dart';
import '../features/admin/visibility/visibility_service.dart';
import 'package:proyecto_empoderate/src/models/checklist_model.dart';
import 'package:proyecto_empoderate/src/data/repositories/checklist_repository.dart';
import 'package:proyecto_empoderate/ui/components/cards/business_status_card.dart';
import '../widgets/pwa_install_button.dart';

import '../logic/business_progress_controller.dart';
import 'home/home_start_block.dart';
import 'package:proyecto_empoderate/ui/theme/empoderate_theme.dart'; // Ensure theme colors are available
import '../features/blog/blog_data_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _repository = ChecklistRepository();
  final _progressController = BusinessProgressController(); 

  @override
  void initState() {
    super.initState();
    AnalyticsService().trackScreenView('Home');
    _progressController.init();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
       // _checkPwaInstall(); // Uncomment if method exists
    });
    VisibilityService.instance.init().then((_) => setState((){})); 
    _repository.init(); 
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PremiumScaffold(
          showBranding: true,
          showBackButton: false, 
          useScroll: false,
          usePadding: false,
          // FAB moved to Stack
          floatingActionButton: null,
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                // SECCIÓN 1: ESTADO DE TU NEGOCIO
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: AnimatedBuilder(
                    animation: _progressController,
                    builder: (context, _) {
                      return BusinessStatusCard(
                        dashboard: _progressController.data, 
                        onTap: () {
                           context.push(AppRoutes.checklist);
                        },
                        onTapSection: (index) {
                           context.push('${AppRoutes.checklist}?tab=$index');
                        }
                      );
                    }
                  ),
                ),
                const SizedBox(height: 28),

                // SECCIÓN 2: PRIMEROS PASOS
                HomeStartBlock(
                  dashboard: _progressController.data,
                ),

                const SizedBox(height: 28),
                
                // SECCIÓN 2.5: APRENDE & CRECE
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const NeonSectionTitle(
                      title: 'Aprende & Crece',
                      color: Color(0xFF00E5FF),
                    ),
                    Text(
                      'Guías, ideas y contenido para impulsar tu negocio',
                      style: GoogleFonts.outfit(color: Colors.white38, fontSize: 12),
                    ),
                    const SizedBox(height: 16),
                    VisibilityBuilder(
                      id: 'home.blog',
                      child: _BlogCard(),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // NUEVA SECCIÓN: PANEL DE HERRAMIENTAS AVANZADAS
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const NeonSectionTitle(
                      title: 'Panel de Herramientas Avanzadas',
                      color: Color(0xFFF4D35E),
                    ),
                    Text(
                      'Funciones complementarias para potenciar tu negocio.',
                      style: GoogleFonts.outfit(color: Colors.white38, fontSize: 12),
                    ),
                    const SizedBox(height: 16),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final toolsIds = [
                          'tools.chatbot', 'tools.general', 'tools.pro_guide', 'tools.courses',
                          'tools.library', 'tools.calculators', 'tools.audit', 'tools.blog_mini'
                        ];
                        final hasVisible = toolsIds.any((id) => VisibilityService.instance.isVisible(id));

                        if (!hasVisible) {
                            return Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.amber.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.amber.withOpacity(0.3)),
                              ),
                              child: Column(
                                children: [
                                  const Icon(Icons.warning, color: Colors.amber),
                                  const SizedBox(height: 8),
                                  Text(
                                    'No hay tarjetas visibles en Panel Avanzado.',
                                    style: GoogleFonts.outfit(color: Colors.amber, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'Actívalas en Admin -> Visibilidad',
                                    style: GoogleFonts.outfit(color: Colors.amber.withOpacity(0.7), fontSize: 12),
                                  ),
                                  const SizedBox(height: 8),
                                  NeonButton(
                                    text: 'Ir a Admin',
                                    onTap: () => context.push(AppRoutes.adminDashboard),
                                    color: Colors.amber,
                                  )
                                ],
                              ),
                            );
                        }

                        double spacing = 12;
                        int cols = 4;
                        double itemWidth = (constraints.maxWidth - (spacing * (cols - 1))) / cols;
                        if (itemWidth < 75) {
                            cols = 3;
                            itemWidth = (constraints.maxWidth - (spacing * (cols - 1))) / cols;
                        }

                        // 5 cards in a single row with equal widths
                        return Row(
                          children: [
                            Expanded(child: VisibilityBuilder(id: 'tools.ai_chat', child: _buildUniformCard(context, 'Chat IA', Icons.psychology_outlined, const Color(0xFF0A1628), kNeonCyan, onTap: () => context.push(AppRoutes.aiHub)))),
                            SizedBox(width: spacing),
                            Expanded(child: VisibilityBuilder(id: 'tools.courses', child: _buildUniformCard(context, 'Cursos', Icons.school_outlined, const Color(0xFF2A0C22), kNeonPink, onTap: () => context.push(AppRoutes.learningCenter)))),
                            SizedBox(width: spacing),
                            Expanded(child: VisibilityBuilder(id: 'tools.library', child: _buildUniformCard(context, 'Biblioteca', Icons.folder_open, const Color(0xFF1A1A1D), const Color(0xFFF4D35E), onTap: () => context.push(AppRoutes.library)))),
                            SizedBox(width: spacing),
                            Expanded(child: VisibilityBuilder(id: 'tools.calculators', child: _buildUniformCard(context, 'Calculadoras', Icons.calculate_outlined, const Color(0xFF072A21), kNeonGreen, onTap: () => context.push(AppRoutes.calculadoras)))),
                            SizedBox(width: spacing),
                            Expanded(child: VisibilityBuilder(id: 'tools.audit', child: _buildUniformCard(context, 'Auditoría', Icons.radar, const Color(0xFF160526), Colors.deepPurpleAccent, onTap: () => context.push(AppRoutes.auditoria)))),
                          ],
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // SECCIÓN 3: ACCESOS RÁPIDOS
                Column(
                  children: [
                    NeonWideCard(
                      borderColor: const Color(0xFFD4AF37), 
                      backgroundColor: const Color(0xFF1A1500), 
                      onTap: () => context.push(AppRoutes.laRutaAlExito),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD4AF37).withOpacity(0.1),
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.5)),
                            ),
                            child: const Icon(Icons.flag, color: Color(0xFFD4AF37), size: 24), 
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'La Ruta al Éxito',
                                  style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Mini juego interactivo para hacer crecer tu negocio.',
                                  style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.play_arrow, color: Color(0xFFD4AF37), size: 20),
                        ],
                      ),
                    ),


                  ],
                ),
                
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
        const PwaInstallButton(), 
        
        // ADMIN FLOATING BUTTON (Positioned manually to ensure visibility)
        // TEMPORARILY DISABLED - Causing layout crash
        /*
        Positioned(
          bottom: 20,
          right: 20,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                 BoxShadow(color: const Color(0xFFD4AF37).withOpacity(0.6), blurRadius: 16, spreadRadius: 2),
              ],
            ),
            child: FloatingActionButton(
              heroTag: 'admin_fab',
              onPressed: () => context.push(AppRoutes.adminDashboard),
              backgroundColor: const Color(0xFFD4AF37),
              child: const Icon(Icons.shield, color: Color(0xFF001220), size: 28),
            ),
          ),
        ),
        */ 
      ],
    ); 
  }

  Widget _buildMiniCard(BuildContext context, double width, String title, IconData icon, Color bg, Color neon, {VoidCallback? onTap}) {
    return SizedBox(
      width: width,
      child: NeonGridCard(
        title: title,
        subtitle: '',
        icon: icon,
        neonColor: neon,
        backgroundColor: bg,
        onTap: onTap ?? () {}, 
      ),
    );
  }

  Widget _buildUniformCard(BuildContext context, String title, IconData icon, Color bg, Color neon, {VoidCallback? onTap}) {
    return _UniformToolCard(
      title: title,
      icon: icon,
      backgroundColor: bg,
      neonColor: neon,
      onTap: onTap,
    );
  }



  Widget _buildAiChatCard(BuildContext context, double width) {
    return _AiChatCard(width: width);
  }

  Widget _textChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.white12),
      ),
      child: Text(
        text,
        style: GoogleFonts.outfit(color: Colors.white70, fontSize: 8),
      ),
    );
  }
}

// Separate stateful widget for Blog card to avoid scroll reset
class _BlogCard extends StatefulWidget {
  @override
  State<_BlogCard> createState() => _BlogCardState();
}

class _BlogCardState extends State<_BlogCard> {
  bool _isHovered = false;
  List<dynamic> _latestPosts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  void _loadPosts() {
    // Import BlogDataService at top of file
    try {
      final blogService = BlogDataService.instance;
      final published = blogService.getPublishedArticles();
      // Sort by date descending and take first 6
      published.sort((a, b) => b.date.compareTo(a.date));
      setState(() {
        _latestPosts = published.take(6).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF0A1628),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isHovered ? kNeonGold : const Color(0xFF00E5FF).withOpacity(0.4),
            width: _isHovered ? 2 : 1,
          ),
          boxShadow: [
            if (_isHovered)
              BoxShadow(
                color: kNeonGold.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 2,
              )
            else
              BoxShadow(
                color: const Color(0xFF00E5FF).withOpacity(0.15),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title and "Ver todos" button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00E5FF).withOpacity(0.15),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.5)),
                        ),
                        child: const Icon(Icons.auto_stories, color: Color(0xFF00E5FF), size: 18),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Blog Empresarial',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Últimas publicaciones',
                            style: GoogleFonts.outfit(color: Colors.white38, fontSize: 11),
                          ),
                        ],
                      ),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: () => context.push(AppRoutes.blog),
                    icon: const Icon(Icons.arrow_forward, size: 14, color: kNeonGold),
                    label: Text(
                      'Ver todos',
                      style: GoogleFonts.outfit(color: kNeonGold, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            
            // Posts grid - 6 posts in wrap layout
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: CircularProgressIndicator(color: Color(0xFF00E5FF))),
              )
            else if (_latestPosts.isEmpty)
              Padding(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: Text(
                    'No hay artículos publicados',
                    style: GoogleFonts.outfit(color: Colors.white38),
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _latestPosts.take(6).map((article) => _buildMiniPostCard(article)).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniPostCard(dynamic article) {
    return GestureDetector(
      onTap: () => context.push('${AppRoutes.blogArticle}?id=${article.id}'),
      child: Container(
        width: 180,
        decoration: BoxDecoration(
          color: const Color(0xFF151C2B),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
              child: Container(
                height: 90,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(article.imageUrl),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.2), BlendMode.darken),
                  ),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category chip
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: kNeonGold.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: kNeonGold.withOpacity(0.3)),
                    ),
                    child: Text(
                      article.category.length > 15 
                          ? article.category.substring(0, 15) 
                          : article.category,
                      style: GoogleFonts.outfit(
                        color: kNeonGold,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Title
                  Text(
                    article.title,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// Separate stateful widget for AI Chat card to avoid scroll reset
class _AiChatCard extends StatefulWidget {
  final double width;
  
  const _AiChatCard({required this.width});

  @override
  State<_AiChatCard> createState() => _AiChatCardState();
}

class _AiChatCardState extends State<_AiChatCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () => context.push(AppRoutes.aiChat),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          width: widget.width,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF06272E),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: _isHovered ? kNeonGold : kNeonCyan.withOpacity(0.5),
              width: _isHovered ? 2 : 1,
            ),
            boxShadow: [
              if (_isHovered)
                BoxShadow(
                  color: kNeonGold.withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 2,
                )
              else
                BoxShadow(color: kNeonCyan.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2)),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.smart_toy_outlined, color: kNeonCyan, size: 28, shadows: [BoxShadow(color: kNeonCyan.withOpacity(0.5), blurRadius: 8)]),
              const SizedBox(height: 8),
              Text(
                'ChatBot con IA',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                'Pregúntame y te guío',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(color: Colors.white54, fontSize: 10),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                alignment: WrapAlignment.center,
                children: [
                  _textChip('Trámites'),
                  _textChip('RRHH'),
                  _textChip('Contabilidad'),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _textChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.white12),
      ),
      child: Text(
        text,
        style: GoogleFonts.outfit(color: Colors.white70, fontSize: 8),
      ),
    );
  }
}

// Uniform Tool Card for 5-column layout
class _UniformToolCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color backgroundColor;
  final Color neonColor;
  final VoidCallback? onTap;

  const _UniformToolCard({
    required this.title,
    required this.icon,
    required this.backgroundColor,
    required this.neonColor,
    this.onTap,
  });

  @override
  State<_UniformToolCard> createState() => _UniformToolCardState();
}

class _UniformToolCardState extends State<_UniformToolCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 100,
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isHovered ? widget.neonColor : widget.neonColor.withOpacity(0.4),
              width: _isHovered ? 2 : 1,
            ),
            boxShadow: [
              if (_isHovered)
                BoxShadow(
                  color: widget.neonColor.withOpacity(0.5),
                  blurRadius: 16,
                  spreadRadius: 2,
                )
              else
                BoxShadow(
                  color: widget.neonColor.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.icon,
                color: widget.neonColor,
                size: 28,
                shadows: [
                  BoxShadow(
                    color: widget.neonColor.withOpacity(0.5),
                    blurRadius: 8,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
