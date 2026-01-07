import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_empoderate/ui/theme/empoderate_theme.dart';
import '../../components/neon_widgets.dart';
import '../../navigation/app_routes.dart';
import '../../components/visibility_builder.dart';
import 'package:go_router/go_router.dart';
import '../../models/checklist_model.dart';
// import '../../features/agenda/services/agenda_service.dart'; // OLD - REMOVED
import '../../features/pendientes/services/pendiente_service.dart';
// Note: Ensure checklist_model.dart is imported. If path differs, adjustment needed.
// Based on previous file creations: lib/src/models/checklist_model.dart

class HomeStartBlock extends StatelessWidget {
  final BusinessProgressModel? dashboard; // generic nullable for safety, though we'll pass it

  const HomeStartBlock({Key? key, this.dashboard}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 1+3 Layout
    return LayoutBuilder(
      builder: (context, constraints) {
        // Breakpoint for Mobile vs Desktop
        final bool isDesktop = constraints.maxWidth > 800; // Arbitrary breakpoint for 2 columns

        // Extract Summaries
        final startSummary = dashboard?.byArea[ProgressArea.start];
        final payrollSummary = dashboard?.byArea[ProgressArea.payroll];
        final accountingSummary = dashboard?.byArea[ProgressArea.accounting];
        final marketingSummary = dashboard?.byArea[ProgressArea.marketing];

        if (!isDesktop) {
          return Column(
            children: [
              // #1 Comienza Aquí (Full Width)
              _buildStartHereCard(context, height: 260, summary: startSummary),
              const SizedBox(height: 16),
              // #2, #3, #4 Stacked
              _buildSecondaryCard(
                context, 
                number: '2', 
                title: 'Recursos Humanos', 
                subtitle: 'Planilla, equipo y obligaciones', 
                icon: Icons.people_outline, 
                route: AppRoutes.humanResources,
                bullets: ['• Planilla y salarios', '• Base de datos de colaboradores'],
                summary: payrollSummary,
                defaultNextStep: 'Configura y registra tu equipo',
              ),
              const SizedBox(height: 12),
              _buildSecondaryCard(
                context, 
                number: '3', 
                title: 'Contabilidad', 
                subtitle: 'Presupuesto, flujo y balances', 
                icon: Icons.account_balance_wallet_outlined, 
                route: AppRoutes.accountingV2, // Ensure V2
                bullets: ['• Presupuesto y flujo de caja', '• Punto de equilibrio y márgenes'],
                summary: accountingSummary,
                defaultNextStep: 'Define tu presupuesto base',
              ),
              const SizedBox(height: 12),
              _buildSecondaryCard(
                context, 
                number: '4', 
                title: 'Marketing', 
                subtitle: 'Embudo, métricas y crecimiento', 
                icon: Icons.trending_up, 
                route: AppRoutes.marketing,
                bullets: ['• Embudo de ventas', '• Métricas de conversión'],
                summary: marketingSummary,
                defaultNextStep: 'Mide y optimiza resultados',
              ),
              
              // NEW: AGENDA CARD
              const SizedBox(height: 16),
              _buildAgendaCard(context),
              const SizedBox(height: 12),
              _buildPendientesCard(context),
            ],
          );
        } else {
          // DESKTOP: 2 Columns (Left ~40%, Right ~60%)
          final double leftWidth = (constraints.maxWidth * 0.40) - 8; // Minus half gap
          final double rightWidth = (constraints.maxWidth * 0.60) - 8;
          final double totalHeight = 340; // Total block height

          return Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // LEFT COL: #1 Comienza Aquí
                  SizedBox(
                     width: leftWidth,
                     height: totalHeight,
                     child: _buildStartHereCard(context, height: totalHeight, summary: startSummary),
                  ),
                  const SizedBox(width: 16),
                  
                  // RIGHT COL: #2, #3, #4 Stacked (Equal heights)
                  SizedBox(
                    width: rightWidth,
                    height: totalHeight,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: _buildSecondaryCard(
                          context, 
                          number: '2', 
                          title: 'Recursos Humanos', 
                          subtitle: 'Planilla, equipo y obligaciones', 
                          icon: Icons.people_outline, 
                          route: AppRoutes.humanResources,
                          bullets: ['• Planilla y salarios', '• Base de datos de colaboradores'],
                          summary: payrollSummary,
                          defaultNextStep: 'Configura y registra tu equipo',
                        )),
                        const SizedBox(height: 12),
                        Expanded(child: _buildSecondaryCard(
                          context, 
                          number: '3', 
                          title: 'Contabilidad', 
                          subtitle: 'Presupuesto, flujo y balances', 
                          icon: Icons.account_balance_wallet_outlined, 
                          route: AppRoutes.accountingV2,
                          bullets: ['• Presupuesto y flujo de caja', '• Punto de equilibrio y márgenes'],
                          summary: accountingSummary,
                          defaultNextStep: 'Define tu presupuesto base',
                        )),
                        const SizedBox(height: 12),
                        Expanded(child: _buildSecondaryCard(
                          context, 
                          number: '4', 
                          title: 'Marketing', 
                          subtitle: 'Embudo, métricas y crecimiento', 
                          icon: Icons.trending_up, 
                          route: AppRoutes.marketing,
                          bullets: ['• Embudo de ventas', '• Métricas de conversión'],
                          summary: marketingSummary,
                          defaultNextStep: 'Mide y optimiza resultados',
                        )),
                      ],
                    ),
                  ),
                ],
              ),
              // DESKTOP AGENDA CARD (Full Width below)
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: _buildAgendaCard(context)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildPendientesCard(context)),
                ],
              ),
            ],
          );
        }
      },
    );
  }
  
  // NEW AGENDA CARD WIDGET
  Widget _buildAgendaCard(BuildContext context) {
    return _AgendaCardWithHover();
  }

  // NEW PENDIENTES CARD WIDGET
  Widget _buildPendientesCard(BuildContext context) {
    return _PendientesCardWithHover();
  }

  // #1 Primary Card (Yellow/Gold)
  Widget _buildStartHereCard(BuildContext context,
      {required double height, ProgressSummary? summary}) {
    return _StartHereCardWithHover(height: height, summary: summary);
  }

  // Secondary Cards
  Widget _buildSecondaryCard(
    BuildContext context, {
    required String number,
    required String title,
    required String subtitle,
    required IconData icon,
    required List<String> bullets,
    required String defaultNextStep,
    required String route,
    ProgressSummary? summary,
  }) {
    return _SecondaryCardWithHover(
      number: number,
      title: title,
      subtitle: subtitle,
      icon: icon,
      bullets: bullets,
      defaultNextStep: defaultNextStep,
      route: route,
      summary: summary,
    );
  }
}

// -----------------------------------------------------------------------------
// HOVER WIDGETS
// -----------------------------------------------------------------------------

class _AgendaCardWithHover extends StatefulWidget {
  @override
  State<_AgendaCardWithHover> createState() => _AgendaCardWithHoverState();
}

class _AgendaCardWithHoverState extends State<_AgendaCardWithHover> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final count = 0;
    final hasAlerts = false;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () => context.push(AppRoutes.agendaTramites),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          width: double.infinity,
          height: 90,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: EmpoderateTheme.safeBoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0F1520), Color(0xFF004D40)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isHovered
                  ? kNeonGold
                  : (hasAlerts ? Colors.redAccent : EmpoderateTheme.goldStrong),
              width: _isHovered ? 2 : 1.5,
            ),
            boxShadow: [
              if (_isHovered)
                BoxShadow(
                  color: kNeonGold.withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 2,
                )
              else
                BoxShadow(
                    color: (hasAlerts ? Colors.redAccent : EmpoderateTheme.goldStrong)
                        .withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4)),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(Icons.notifications_active_outlined,
                    color: hasAlerts
                        ? Colors.redAccent
                        : EmpoderateTheme.goldStrong,
                    size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Agenda de Trámites',
                        style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    Text(
                        hasAlerts
                            ? '¡Tienes $count vencimientos cercanos!'
                            : 'Recordatorios de impuestos y permisos',
                        style: GoogleFonts.outfit(
                            color: hasAlerts ? Colors.white : Colors.white70,
                            fontSize: 13,
                            fontWeight:
                                hasAlerts ? FontWeight.bold : FontWeight.normal)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: hasAlerts ? Colors.redAccent : EmpoderateTheme.goldStrong,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: hasAlerts
                      ? [BoxShadow(color: Colors.redAccent.withOpacity(0.4), blurRadius: 8)]
                      : [],
                ),
                child: Text(hasAlerts ? '$count PRÓXIMOS' : 'VER AGENDA',
                    style: GoogleFonts.outfit(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 11)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PendientesCardWithHover extends StatefulWidget {
  @override
  State<_PendientesCardWithHover> createState() => _PendientesCardWithHoverState();
}

class _PendientesCardWithHoverState extends State<_PendientesCardWithHover> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
        listenable: PendienteService(),
        builder: (context, _) {
          final count = PendienteService().pendingCount;
          final hasPending = count > 0;

          return MouseRegion(
            onEnter: (_) => setState(() => _isHovered = true),
            onExit: (_) => setState(() => _isHovered = false),
            child: GestureDetector(
              onTap: () => context.push(AppRoutes.pendientes),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                width: double.infinity,
                height: 90,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: EmpoderateTheme.safeBoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F1520), Color(0xFF1A237E)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _isHovered
                        ? kNeonGold
                        : EmpoderateTheme.cyanAccent.withOpacity(0.4),
                    width: _isHovered ? 2 : 1.5,
                  ),
                  boxShadow: [
                    if (_isHovered)
                      BoxShadow(
                        color: kNeonGold.withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 2,
                      )
                    else
                      BoxShadow(
                          color: EmpoderateTheme.cyanAccent.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4)),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          shape: BoxShape.circle),
                      child: const Icon(Icons.check_circle_outline,
                          color: EmpoderateTheme.cyanAccent, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Mis Pendientes',
                              style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                          Text(
                              hasPending
                                  ? 'Tienes $count tareas pendientes'
                                  : '¡Todo está al día!',
                              style: GoogleFonts.outfit(
                                  color: Colors.white70, fontSize: 13)),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios,
                        color: Colors.white24, size: 16),
                  ],
                ),
              ),
            ),
          );
        });
  }
}

class _StartHereCardWithHover extends StatefulWidget {
  final double height;
  final ProgressSummary? summary;

  const _StartHereCardWithHover({super.key, required this.height, this.summary});

  @override
  State<_StartHereCardWithHover> createState() => _StartHereCardWithHoverState();
}

class _StartHereCardWithHoverState extends State<_StartHereCardWithHover> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFF4D35E);
    const bgColor = Color(0xFF242100);
    final percent = widget.summary?.percent ?? 0.0;
    final nextStep = widget.summary?.nextTitle ?? 'Elige tu rubro';

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () {
          final route = widget.summary?.nextRoute ?? AppRoutes.miNegocioRubro;
          context.push(route);
        },
        child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: widget.height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isHovered ? kNeonGold : primaryColor.withOpacity(0.5),
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
              BoxShadow(
                  color: primaryColor.withOpacity(0.15),
                  blurRadius: 15,
                  offset: const Offset(0, 4)),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryColor.withOpacity(0.2),
                  boxShadow: [
                    BoxShadow(
                        color: primaryColor.withOpacity(0.4),
                        blurRadius: 50,
                        spreadRadius: 10),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text('PRIORITARIO',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold)),
                        ),
                        Container(
                          width: 32,
                          height: 32,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                              color: Colors.white, shape: BoxShape.circle),
                          child: Text('1',
                              style: GoogleFonts.outfit(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text('Escoge tu Negocio',
                        style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold)),
                    Text('Define tu rubro y genera tu plan personalizado',
                        style: GoogleFonts.outfit(
                            color: Colors.white70, fontSize: 14)),
                    const SizedBox(height: 24),
                    if (widget.summary != null) ...[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Progreso',
                                  style: GoogleFonts.outfit(
                                      color: primaryColor, fontSize: 12)),
                              Text('${(percent * 100).toInt()}%',
                                  style: GoogleFonts.outfit(
                                      color: primaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: LinearProgressIndicator(
                                value: percent,
                                backgroundColor: Colors.white10,
                                color: primaryColor,
                                minHeight: 4),
                          ),
                          const SizedBox(height: 8),
                          Text('Siguiente: $nextStep',
                              style: GoogleFonts.outfit(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic)),
                        ],
                      ),
                    ] else ...[
                      _buildSteps(primaryColor),
                    ],
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: Colors.black26, borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        children: [
                          const Icon(Icons.lightbulb, color: primaryColor, size: 14),
                          const SizedBox(width: 6),
                          const Expanded(
                              child: Text(
                                  'IA: Selecciona tu tipo de negocio para generar checklist, guías y plantillas.',
                                  style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 10,
                                      fontStyle: FontStyle.italic))),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () {
                          final route =
                              widget.summary?.nextRoute ?? AppRoutes.miNegocioRubro;
                          context.push(route);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.black,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text('EMPEZAR',
                            style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold, fontSize: 14)),
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
    );
  }

  Widget _buildSteps(Color color) {
    return Column(
      children: [
        _buildMiniStep(1, 'Elige tu rubro', color),
        const SizedBox(height: 8),
        _buildMiniStep(2, 'Mira requisitos', color),
        const SizedBox(height: 8),
        _buildMiniStep(3, 'Activa ruta', color),
      ],
    );
  }

  Widget _buildMiniStep(int num, String text, Color color,
      {IconData icon = Icons.check_circle_outline, double size = 14}) {
    return Row(
      children: [
        Icon(icon, color: color.withOpacity(0.7), size: size),
        const SizedBox(width: 6),
        Expanded(
            child: Text(text,
                style: GoogleFonts.outfit(color: color, fontSize: 11),
                maxLines: 1,
                overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}

class _SecondaryCardWithHover extends StatefulWidget {
  final String number;
  final String title;
  final String subtitle;
  final IconData icon;
  final List<String> bullets;
  final String defaultNextStep;
  final String route;
  final ProgressSummary? summary;

  const _SecondaryCardWithHover({
    super.key,
    required this.number,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.bullets,
    required this.defaultNextStep,
    required this.route,
    this.summary,
  });

  @override
  State<_SecondaryCardWithHover> createState() => _SecondaryCardWithHoverState();
}

class _SecondaryCardWithHoverState extends State<_SecondaryCardWithHover> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF001B3A);
    const mediumBlue = Color(0xFF003366);
    const softBlue = Color(0xFF004080);
    const goldBorder = Color(0xFFF4D35E);

    final percent = widget.summary?.percent ?? 0.0;
    final done = widget.summary?.done ?? 0;
    final total = widget.summary?.total ?? 0;
    final nextStep = widget.summary?.nextTitle ?? widget.defaultNextStep;
    final nextRoute = widget.summary?.nextRoute ?? widget.route;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () {
          if (widget.route == AppRoutes.accountingV2 ||
              widget.route == AppRoutes.marketing) {
            context.push(widget.route);
          } else {
            context.push(nextRoute);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 110),
          clipBehavior: Clip.antiAlias,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [primaryBlue, mediumBlue, softBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _isHovered ? kNeonGold : goldBorder.withOpacity(0.4),
              width: _isHovered ? 2 : 1,
            ),
            boxShadow: [
              if (_isHovered)
                BoxShadow(
                  color: kNeonGold.withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 2,
                )
              else ...[
                BoxShadow(
                    color: const Color(0xFF000000).withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4)),
                BoxShadow(
                    color: mediumBlue.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 2),
              ],
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                top: -40,
                right: -40,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.04),
                    boxShadow: [
                      BoxShadow(color: mediumBlue.withOpacity(0.1), blurRadius: 30)
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Icon(widget.icon,
                                  color: EmpoderateTheme.cyanAccent, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                  child: Text(widget.title,
                                      style: GoogleFonts.outfit(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 17),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis)),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(widget.subtitle,
                              style: GoogleFonts.outfit(
                                  color: goldBorder, fontSize: 11),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 6),
                          if (widget.summary != null && total > 0) ...[
                            Row(
                              children: [
                                Text("Progreso: $done/$total",
                                    style: GoogleFonts.outfit(
                                        color: Colors.white54, fontSize: 10)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(2),
                                    child: LinearProgressIndicator(
                                      value: percent,
                                      backgroundColor: Colors.black26,
                                      color: EmpoderateTheme.cyanAccent,
                                      minHeight: 4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ] else ...[
                            ...widget.bullets.map((b) => Padding(
                                  padding: const EdgeInsets.only(bottom: 1),
                                  child: Text(b,
                                      style: GoogleFonts.outfit(
                                          color: goldBorder.withOpacity(0.9),
                                          fontSize: 10,
                                          height: 1.1),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis),
                                )),
                          ],
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.arrow_forward,
                                  color: goldBorder, size: 9),
                              const SizedBox(width: 4),
                              Expanded(
                                  child: Text(nextStep,
                                      style: GoogleFonts.outfit(
                                          color: goldBorder,
                                          fontSize: 9,
                                          fontStyle: FontStyle.italic),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          width: 26,
                          height: 26,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                              color: Colors.white, shape: BoxShape.circle),
                          child: Text(widget.number,
                              style: GoogleFonts.outfit(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12)),
                        ),
                        const SizedBox(height: 6),
                        SizedBox(
                          height: 30,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pushNamed(context, nextRoute),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: goldBorder.withOpacity(0.9),
                              foregroundColor: Colors.black,
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                            ),
                            child: Text('EMPEZAR',
                                style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.w700, fontSize: 10)),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
