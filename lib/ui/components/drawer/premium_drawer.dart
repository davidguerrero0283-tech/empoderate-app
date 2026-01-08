import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/empoderate_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui'; // For BackdropFilter
import '../../../../src/navigation/app_routes.dart';
import '../../../../src/navigation/app_router.dart'; // For rootNavigatorKey
import '../../../../src/components/neon_widgets.dart'; // Using global neon constants
import '../../../../src/components/visibility_builder.dart';
import '../../../../src/services/user_profile_service.dart';
import '../../../../src/services/menu_persistent_state.dart';

class PremiumDrawer extends StatefulWidget {
  const PremiumDrawer({Key? key}) : super(key: key);

  @override
  State<PremiumDrawer> createState() => _PremiumDrawerState();
}

class _PremiumDrawerState extends State<PremiumDrawer> {
  final UserProfileService _profileService = UserProfileService();

  @override
  void initState() {
    super.initState();
    _profileService.loadProfile();
    _profileService.addListener(_onProfileChange);
  }

  @override
  void dispose() {
    _profileService.removeListener(_onProfileChange);
    super.dispose();
  }

  void _onProfileChange() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // 1. WIDTH & STRUCTURE
    return SizedBox(
      width: 300, // Fixed width as requested
      child: Drawer(
        elevation: 0, // Disable default shadow to use our own glass styling
        backgroundColor: Colors.transparent, // Background handled by container
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero, // Square corners
        ),
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20), // Heavy blur for premium glass feel
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.zero, // Ensure square corners
                // 2. VISUAL STYLE: Dark Glass + Gradient
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF030303), // Soft Black
                    Color(0xFF050914), // Deep Navy (very dark)
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                border: Border(
                  right: BorderSide(
                    color: Colors.white.withOpacity(0.05),
                    width: 1,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 30,
                    offset: const Offset(10, 0),
                  )
                ],
              ),
              child: Column(
                children: [
                  // 4. MENU ITEMS (with header and footer inside scroll)
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // USER HEADER (Inside Scroll)
                          _buildHeader(context),
                          
                          Divider(height: 1, color: Colors.white.withOpacity(0.05)),
                          
                          // MENU ITEMS
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                          // SECTION 1: INICIO
                          _buildSectionLabel('INICIO'),
                          _buildMenuItem(
                            context, 
                            icon: Icons.home_outlined, 
                            title: 'Inicio', 
                            route: AppRoutes.root,
                            color: kNeonBlue
                          ),
                          VisibilityBuilder(
                            id: 'home.ruta_exito',
                            child: _buildMenuItem(
                              context, 
                              icon: Icons.flag_outlined,
                              title: 'La Ruta al Éxito', 
                              route: AppRoutes.laRutaAlExito,
                              color: kNeonPurple
                            ),
                          ),
                          VisibilityBuilder(
                            id: 'home.my_business',
                            child: _buildMenuItem(
                              context, 
                              icon: Icons.business_outlined,
                              title: 'Mi Negocio', 
                              route: AppRoutes.miNegocioRubro,
                              color: kNeonCyan
                            ),
                          ),
                          _buildMenuItem(
                            context, 
                            icon: Icons.store_outlined,
                            title: 'Perfil del Negocio', 
                            route: AppRoutes.businessProfile,
                            color: kNeonGold
                          ),
                    
                    const SizedBox(height: 16),
                    
                    // SECTION 2: HERRAMIENTAS
                    _buildSectionLabel('HERRAMIENTAS'),
                    VisibilityBuilder(
                      id: 'tools.general',
                      child: _buildMenuItem(
                        context, 
                        icon: Icons.grid_view, 
                        title: 'Herramientas', 
                        route: AppRoutes.tools,
                        color: kNeonCyan
                      ),
                    ),
                    VisibilityBuilder(
                      id: 'tools.calculators',
                      child: _buildMenuItem(
                        context, 
                        icon: Icons.calculate_outlined,
                        title: 'Calculadoras', 
                        route: AppRoutes.calculadoras,
                        color: kNeonGreen
                      ),
                    ),
                    VisibilityBuilder(
                      id: 'tools.audit',
                      child: _buildMenuItem(
                        context, 
                        icon: Icons.assessment_outlined,
                        title: 'Auditoría de Negocio', 
                        route: AppRoutes.auditoria,
                        color: Colors.orangeAccent
                      ),
                    ),
                    _buildMenuItem(
                      context, 
                      icon: Icons.checklist_outlined,
                      title: 'Checklist', 
                      route: AppRoutes.checklist,
                      color: Colors.purpleAccent
                    ),
                    _buildMenuItem(
                      context, 
                      icon: Icons.security_outlined,
                      title: 'Bóveda Digital', 
                      route: AppRoutes.bovedaDigital,
                      color: kNeonGold
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // SECTION 3: RECURSOS HUMANOS
                    _buildSectionLabel('RECURSOS HUMANOS'),
                    VisibilityBuilder(
                      id: 'home.hr',
                      child: _buildMenuItem(
                        context, 
                        icon: Icons.people_outline,
                        title: 'RRHH Principal', 
                        route: AppRoutes.humanResources,
                        color: kNeonBlue
                      ),
                    ),
                    _buildMenuItem(
                      context, 
                      icon: Icons.attach_money_outlined,
                      title: 'Calculadora de Salario', 
                      route: AppRoutes.salarioNeto,
                      color: kNeonGreen
                    ),
                    _buildMenuItem(
                      context, 
                      icon: Icons.receipt_long_outlined,
                      title: 'Liquidación', 
                      route: AppRoutes.liquidacion,
                      color: Colors.redAccent
                    ),
                    _buildMenuItem(
                      context, 
                      icon: Icons.verified_user_outlined,
                      title: 'Cumplimiento Laboral', 
                      route: '/coming-soon?title=Cumplimiento Laboral',
                      color: Colors.tealAccent
                    ),
                    _buildMenuItem(
                      context, 
                      icon: Icons.description_outlined,
                      title: 'Plantillas RRHH', 
                      route: '/coming-soon?title=Plantillas RRHH',
                      color: kNeonPurple
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // SECTION 4: CONTABILIDAD
                    _buildSectionLabel('CONTABILIDAD'),
                    _buildMenuItem(
                      context, 
                      icon: Icons.account_balance_outlined,
                      title: 'Contabilidad Principal', 
                      route: AppRoutes.accounting,
                      color: kNeonGreen
                    ),
                    _buildMenuItem(
                      context, 
                      icon: Icons.school_outlined,
                      title: 'Aula Contable', 
                      route: AppRoutes.accountingClassroom,
                      color: kNeonBlue
                    ),
                    _buildMenuItem(
                      context, 
                      icon: Icons.trending_up_outlined,
                      title: 'Flujo de Caja', 
                      route: AppRoutes.cashFlow,
                      color: Colors.greenAccent
                    ),
                    _buildMenuItem(
                      context, 
                      icon: Icons.pie_chart_outline,
                      title: 'Presupuesto', 
                      route: AppRoutes.budget,
                      color: Colors.blueAccent
                    ),
                    _buildMenuItem(
                      context, 
                      icon: Icons.request_quote_outlined,
                      title: 'Estimador de Impuestos', 
                      route: AppRoutes.taxEstimator,
                      color: Colors.orangeAccent
                    ),
                    _buildMenuItem(
                      context, 
                      icon: Icons.payments_outlined,
                      title: 'Costos Fijos', 
                      route: AppRoutes.fixedCosts,
                      color: kNeonCyan
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // SECTION 5: MARKETING
                    _buildSectionLabel('MARKETING'),
                    VisibilityBuilder(
                      id: 'home.marketing',
                      child: _buildMenuItem(
                        context, 
                        icon: Icons.campaign_outlined,
                        title: 'Marketing Principal', 
                        route: AppRoutes.marketing,
                        color: Colors.pinkAccent
                      ),
                    ),
                    _buildMenuItem(
                      context, 
                      icon: Icons.article_outlined,
                      title: 'Contenido', 
                      route: AppRoutes.marketingContent,
                      color: kNeonPurple
                    ),
                    _buildMenuItem(
                      context, 
                      icon: Icons.filter_alt_outlined,
                      title: 'Embudo de Ventas', 
                      route: AppRoutes.marketingFunnel,
                      color: kNeonCyan
                    ),
                    _buildMenuItem(
                      context, 
                      icon: Icons.rocket_launch_outlined,
                      title: 'Campañas', 
                      route: AppRoutes.marketingCampaigns,
                      color: Colors.deepOrangeAccent
                    ),
                    _buildMenuItem(
                      context, 
                      icon: Icons.person_pin_outlined,
                      title: 'Avatar de Cliente', 
                      route: AppRoutes.marketingAvatar,
                      color: kNeonBlue
                    ),
                    _buildMenuItem(
                      context, 
                      icon: Icons.auto_awesome_outlined,
                      title: 'Automatización Redes Sociales', 
                      route: AppRoutes.marketingAutomation,
                      color: kNeonGold
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // SECTION 6: APRENDIZAJE
                    _buildSectionLabel('APRENDIZAJE'),
                    VisibilityBuilder(
                      id: 'tools.courses',
                      child: _buildMenuItem(
                        context, 
                        icon: Icons.school_outlined,
                        title: 'Centro de Aprendizaje', 
                        route: AppRoutes.learningCenter,
                        color: kNeonBlue
                      ),
                    ),
                    VisibilityBuilder(
                      id: 'tools.library',
                      child: _buildMenuItem(
                        context, 
                        icon: Icons.folder_open_outlined, 
                        title: 'Biblioteca', 
                        route: AppRoutes.library,
                        color: Colors.tealAccent
                      ),
                    ),
                    VisibilityBuilder(
                      id: 'home.blog',
                      child: _buildMenuItem(
                        context, 
                        icon: Icons.rss_feed_outlined,
                        title: 'Blog', 
                        route: AppRoutes.blog,
                        color: kNeonPurple
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // SECTION 6: INTELIGENCIA ARTIFICIAL
                    _buildSectionLabel('INTELIGENCIA ARTIFICIAL'),
                    VisibilityBuilder(
                      id: 'tools.ai_chat',
                      child: _buildMenuItem(
                        context, 
                        icon: Icons.psychology_outlined,
                        title: 'Hub IA', 
                        route: AppRoutes.aiHub,
                        color: kNeonViolet
                      ),
                    ),
                    _buildMenuItem(
                      context, 
                      icon: Icons.account_balance_wallet_outlined,
                      title: 'IA Contable', 
                      route: AppRoutes.iaContable,
                      color: kNeonGreen
                    ),
                    _buildMenuItem(
                      context, 
                      icon: Icons.gavel_outlined,
                      title: 'IA Legal', 
                      route: AppRoutes.iaLegal,
                      color: Colors.blueAccent
                    ),
                    _buildMenuItem(
                      context, 
                      icon: Icons.trending_up_outlined,
                      title: 'IA Marketing', 
                      route: AppRoutes.iaMarketing,
                      color: Colors.pinkAccent
                    ),
                    _buildMenuItem(
                      context, 
                      icon: Icons.point_of_sale_outlined,
                      title: 'IA Ventas', 
                      route: AppRoutes.iaVentas,
                      color: Colors.orangeAccent
                    ),
                    _buildMenuItem(
                      context, 
                      icon: Icons.speed_outlined,
                      title: 'IA Productividad', 
                      route: AppRoutes.iaProductividad,
                      color: kNeonCyan
                    ),
                    _buildMenuItem(
                      context, 
                      icon: Icons.menu_book_outlined,
                      title: 'IA Docente', 
                      route: AppRoutes.iaDocente,
                      color: kNeonBlue
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // SECTION 7: TRÁMITES Y AGENDA
                    _buildSectionLabel('TRÁMITES Y AGENDA'),
                    _buildMenuItem(
                      context, 
                      icon: Icons.assignment_outlined,
                      title: 'Trámites', 
                      route: AppRoutes.tramites,
                      color: Colors.amberAccent
                    ),
                    _buildMenuItem(
                      context, 
                      icon: Icons.event_outlined,
                      title: 'Agenda de Trámites', 
                      route: AppRoutes.agendaTramites,
                      color: kNeonPurple
                    ),
                    _buildMenuItem(
                      context, 
                      icon: Icons.task_outlined,
                      title: 'Pendientes', 
                      route: AppRoutes.pendientes,
                      color: Colors.redAccent
                    ),
                    _buildMenuItem(
                      context, 
                      icon: Icons.notifications_outlined,
                      title: 'Recordatorios', 
                      route: AppRoutes.recordatorios,
                      color: kNeonCyan
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // SECTION 9: CONFIGURACIÓN
                    _buildSectionLabel('CONFIGURACIÓN'),
                    _buildMenuItem(
                      context, 
                      icon: Icons.settings_outlined, 
                      title: 'Ajustes', 
                      route: AppRoutes.settings,
                      color: Colors.white70 
                    ),
                    // Admin access - moved from floating button to drawer
                    _buildMenuItem(
                      context, 
                      icon: Icons.admin_panel_settings, 
                      title: 'Administrador', 
                      route: '/under_construction?title=${Uri.encodeComponent('Administrador')}&route=${Uri.encodeComponent('/admin_dashboard')}',
                      color: const Color(0xFFD4AF37) 
                    ),
                    _buildMenuItem(
                      context, 
                      icon: Icons.diamond_outlined, 
                      title: 'Planes Premium', 
                      route: AppRoutes.premiumPlans,
                      color: kNeonGold 
                    ),
                    _buildMenuItem(
                      context, 
                      icon: Icons.policy_outlined,
                      title: 'Legal', 
                      route: AppRoutes.legal,
                      color: Colors.white54
                    ),
                              ],
                            ),
                          ),
                          
                          // FOOTER (Inside Scroll)
                          const SizedBox(height: 24),
                          Divider(height: 1, color: Colors.white.withOpacity(0.05)),
                          
                          Container(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              children: [
                                _buildMenuItem(
                                  context,
                                  icon: Icons.logout_outlined,
                                  title: 'Cerrar Sesión',
                                  onTap: () {
                                    Navigator.pushReplacementNamed(context, AppRoutes.root);
                                  },
                                  color: Colors.white54,
                                  isFooter: true,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Versión 2.0.0 (Premium)',
                                  style: GoogleFonts.outfit(color: Colors.white24, fontSize: 10, letterSpacing: 1),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final displayName = _profileService.displayName;
    final initials = _profileService.initials;
    final hasCustomName = _profileService.businessName.isNotEmpty || _profileService.userName.isNotEmpty;
    final hasImage = _profileService.hasProfileImage;

    return Container(
      padding: const EdgeInsets.only(top: 40, bottom: 30, left: 16, right: 16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        border: Border(bottom: BorderSide(color: kNeonGold.withOpacity(0.1), width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Top Row for Menu Icon
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => MenuStateService().setMenuOpen(false),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: kNeonGold.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.menu_open, color: kNeonGold, size: 24),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          
          // Avatar - Clickable to edit profile with hover glow
          StatefulBuilder(
            builder: (context, setAvatarState) {
              bool isHovered = false;
              return MouseRegion(
                cursor: SystemMouseCursors.click,
                onEnter: (_) => setAvatarState(() => isHovered = true),
                onExit: (_) => setAvatarState(() => isHovered = false),
                child: GestureDetector(
                  onTap: () => _showProfileModal(context),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: isHovered
                          ? [
                              BoxShadow(
                                color: kNeonGold.withOpacity(0.6),
                                blurRadius: 20,
                                spreadRadius: 3,
                              ),
                            ]
                          : [],
                    ),
                    child: Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(1.5),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isHovered ? kNeonGold : kNeonGold.withOpacity(0.6),
                              width: isHovered ? 3 : 2,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 36, // Slightly larger
                            backgroundColor: Colors.black.withOpacity(0.3),
                            backgroundImage: hasImage 
                                ? MemoryImage(_profileService.profileImageBytes!) 
                                : null,
                            child: hasImage 
                                ? null
                                : hasCustomName
                                    ? Text(
                                        initials,
                                        style: GoogleFonts.outfit(
                                          color: kNeonGold,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    : Icon(Icons.person_outline, size: 40, color: kNeonGold.withOpacity(0.9)),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: kNeonGold,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 4),
                              ],
                            ),
                            child: const Icon(Icons.edit, size: 12, color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          
          // Name and Plan
          Text(
            displayName.toUpperCase(),
            style: GoogleFonts.outfit(
              color: kNeonGold,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          
          StatefulBuilder(
            builder: (context, setBadgeState) {
              bool isHovered = false;
              return MouseRegion(
                cursor: SystemMouseCursors.click,
                onEnter: (_) => setBadgeState(() => isHovered = true),
                onExit: (_) => setBadgeState(() => isHovered = false),
                child: GestureDetector(
                  onTap: () {
                    AppRoutes.navigatorKey.currentState?.pushNamed(AppRoutes.premiumPlans);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: isHovered ? kNeonGold.withOpacity(0.2) : kNeonGold.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isHovered ? kNeonGold : kNeonGold.withOpacity(0.3), 
                        width: isHovered ? 2 : 1,
                      ),
                      boxShadow: isHovered
                          ? [
                              BoxShadow(
                                color: kNeonGold.withOpacity(0.5),
                                blurRadius: 15,
                                spreadRadius: 2,
                              ),
                            ]
                          : [],
                    ),
                    child: Text(
                      'PLAN PREMIUM',
                      style: GoogleFonts.outfit(
                        color: isHovered ? kNeonGold : kNeonGold.withOpacity(0.9),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8, top: 4),
      child: Text(
        text,
        style: GoogleFonts.outfit(
          color: Colors.white38,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon, 
    required String title, 
    String? route,
    VoidCallback? onTap,
    Color color = Colors.white,
    bool isFooter = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (onTap != null) {
            onTap();
          } else if (route != null) {
            // Close drawer first
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
            
            // Small delay to allow drawer to close smoothly
            Future.delayed(const Duration(milliseconds: 150), () {
              try {
                // Define ShellRoute paths - these use context.go (replace navigation stack)
                final shellRoutePaths = {
                  '/',
                  '/tools',
                  '/boveda_digital',
                  '/settings',
                  '/library',
                };
                
                // Check if this is a ShellRoute path
                final isShellRoute = shellRoutePaths.contains(route);
                
                // Use rootNavigatorKey to get router context (drawer context doesn't have router)
                final navigatorContext = rootNavigatorKey.currentContext;
                if (navigatorContext != null) {
                  if (isShellRoute) {
                    // Use context.go for ShellRoute paths (keeps bottom nav)
                    navigatorContext.go(route);
                  } else {
                    // Use context.push for standard routes (shows back button)
                    navigatorContext.push(route);
                  }
                } else {
                  debugPrint('⚠️ Navigator context is null, cannot navigate to $route');
                }
              } catch (e) {
                // Fallback: try with root context
                debugPrint('⚠️ Navigation error to $route: $e');
                final navigatorContext = rootNavigatorKey.currentContext;
                if (navigatorContext != null) {
                  try {
                    navigatorContext.push(route);
                  } catch (e2) {
                    navigatorContext.push('/under_construction?title=${Uri.encodeComponent(title)}&route=${Uri.encodeComponent(route)}');
                  }
                }
              }
            });
          }
        },
        hoverColor: color.withOpacity(0.1),
        splashColor: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          margin: const EdgeInsets.only(bottom: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, color: color.withOpacity(0.9), size: 22),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.outfit(
                    color: isFooter ? color : Colors.white.withOpacity(0.9),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showProfileModal(BuildContext context) {
    final businessController = TextEditingController(text: _profileService.businessName);
    final userController = TextEditingController(text: _profileService.userName);

    // Use global navigator context to avoid "Navigator operation with context that doesn't include Navigator"
    final navigatorContext = AppRoutes.navigatorKey.currentContext;
    if (navigatorContext == null) return;

    showDialog(
      context: navigatorContext,
      barrierColor: Colors.black87,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              width: 340,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF0A0E14).withOpacity(0.95),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: kNeonGold.withOpacity(0.3)),
                boxShadow: [
                  BoxShadow(
                    color: kNeonGold.withOpacity(0.1),
                    blurRadius: 30,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: kNeonGold.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.badge_outlined, color: kNeonGold, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tu Identidad',
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Personaliza tu perfil',
                              style: GoogleFonts.outfit(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(Icons.close, color: Colors.white38),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Profile Image Section
                  StatefulBuilder(
                    builder: (context, setModalState) {
                      final hasImage = _profileService.hasProfileImage;
                      return Column(
                        children: [
                          GestureDetector(
                            onTap: () async {
                              final success = await _profileService.pickProfileImage();
                              if (success) {
                                setModalState(() {});
                                setState(() {});
                              }
                            },
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.05),
                                border: Border.all(
                                  color: kNeonGold.withOpacity(0.4),
                                  width: 2,
                                ),
                              ),
                              child: ClipOval(
                                child: hasImage
                                    ? Image.memory(
                                        _profileService.profileImageBytes!,
                                        fit: BoxFit.cover,
                                        width: 80,
                                        height: 80,
                                      )
                                    : Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.add_a_photo, color: kNeonGold, size: 28),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Logo',
                                            style: GoogleFonts.outfit(
                                              color: Colors.white54,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ),
                          if (hasImage) ...[
                            const SizedBox(height: 8),
                            TextButton.icon(
                              onPressed: () async {
                                await _profileService.removeProfileImage();
                                setModalState(() {});
                                setState(() {});
                              },
                              icon: const Icon(Icons.delete_outline, size: 16, color: Colors.redAccent),
                              label: Text(
                                'Quitar imagen',
                                style: GoogleFonts.outfit(color: Colors.redAccent, fontSize: 12),
                              ),
                            ),
                          ],
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  
                  // Business Name Field
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'NOMBRE DEL NEGOCIO',
                        style: GoogleFonts.outfit(
                          color: kNeonGold,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: businessController,
                        style: GoogleFonts.outfit(color: Colors.white, fontSize: 16),
                        decoration: InputDecoration(
                          hintText: 'Ej: Mi Emprendimiento',
                          hintStyle: GoogleFonts.outfit(color: Colors.white30),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.05),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.white10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.white10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: kNeonGold),
                          ),
                          prefixIcon: Icon(Icons.store_outlined, color: Colors.white38, size: 20),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // User Name Field
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TU NOMBRE',
                        style: GoogleFonts.outfit(
                          color: Colors.white54,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: userController,
                        style: GoogleFonts.outfit(color: Colors.white, fontSize: 16),
                        decoration: InputDecoration(
                          hintText: 'Ej: María García',
                          hintStyle: GoogleFonts.outfit(color: Colors.white30),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.05),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.white10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.white10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: kNeonGold),
                          ),
                          prefixIcon: Icon(Icons.person_outline, color: Colors.white38, size: 20),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'El nombre del negocio tiene prioridad en el header',
                    style: GoogleFonts.outfit(color: Colors.white24, fontSize: 11),
                  ),
                  const SizedBox(height: 24),
                  
                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        await _profileService.setBusinessName(businessController.text);
                        await _profileService.setUserName(userController.text);
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kNeonGold,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: Text(
                        'Guardar',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Clear Button
                  TextButton(
                    onPressed: () async {
                      await _profileService.clearProfile();
                      Navigator.pop(ctx);
                    },
                    child: Text(
                      'Restablecer a EMPODÉRATE',
                      style: GoogleFonts.outfit(
                        color: Colors.white38,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
