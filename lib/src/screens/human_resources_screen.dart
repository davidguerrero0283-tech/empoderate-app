import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../components/premium_scaffold.dart';
import '../components/neon_widgets.dart';
import '../components/info_button.dart';
import '../components/calculator_info_panel.dart';
import 'package:go_router/go_router.dart';
import '../services/worker_service.dart';
import '../calculators/salario_models.dart';
import 'hr_templates_screen.dart';
import '../navigation/app_routes.dart';
import 'package:go_router/go_router.dart';
import 'package:proyecto_empoderate/src/features/hr/compliance/hr_compliance_summary_card.dart';
import 'learning/module_guide_data.dart';
import 'package:url_launcher/url_launcher.dart';
import 'employees_grid_screen.dart';
import 'directorio_screen.dart';
import 'package:intl/intl.dart';
import '../models/vacation_management.dart';
import '../services/vacation_eligibility_service.dart';
import '../components/visibility_builder.dart';
import '../features/analytics/analytics_service.dart';
import '../features/admin/visibility/visibility_service.dart';
import '../widgets/vacation_dashboard.dart';
import 'package:proyecto_empoderate/src/widgets/feature_intro_screen.dart';
import '../components/business_hero_header.dart';


class HumanResourcesScreen extends StatefulWidget {
  const HumanResourcesScreen({Key? key}) : super(key: key);

  @override
  State<HumanResourcesScreen> createState() => _HumanResourcesScreenState();
}

class _HumanResourcesScreenState extends State<HumanResourcesScreen> {
  final WorkerService _service = WorkerService();
  int _totalEmployees = 0;
  double _totalPayroll = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
    // Intro overlay removed - now using BusinessHeroHeader
  }

  void _showHrIntro() {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (ctx, _, __) => FeatureIntroScreen(
          title: 'GESTIÓN DE TALENTO 360°',
          subTitle: 'Tu equipo es tu activo más valioso. Adminístralo con precisión legal y humana.',
          heroEmoji: '👥',
          primaryColor: const Color(0xFFFF4081), // Pink
          features: const [
             IntroFeatureItem(Icons.folder_shared, 'Expedientes'),
             IntroFeatureItem(Icons.qr_code_scanner, 'Asistencias'),
             IntroFeatureItem(Icons.gavel, 'Disciplina'),
             IntroFeatureItem(Icons.analytics, 'Reportes'),
          ],
          processSteps: const [
             IntroStepItem('1. Recluta', 'Registra perfiles completos con foto y contratos.'),
             IntroStepItem('2. Monitorea', 'Gestiona asistencias, llegadas tardías y turnos.'),
             IntroStepItem('3. Evalúa', 'Lleva un historial de incidencias y méritos.'),
             IntroStepItem('4. Cumple', 'Genera documentos legales listos para firmar.'),
          ],
          proTip: 'Usa los expedientes digitales para tener toda la documentación legal a un click de responder auditorías.',
          onDismiss: () => context.pop(),
        ),
      ),
    );
  }

  Future<void> _loadStats() async {
    try {
      final workers = await _service.getWorkers();
      setState(() {
        _totalEmployees = workers.length;
        _totalPayroll = workers.fold<double>(0, (sum, w) => sum + w.basePayment);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color mainColor = const Color(0xFFFF4081); // Neon Pink
    final Color secondaryColor = const Color(0xFFE040FB); // Neon Purple
    final Color copperColor = const Color(0xFFFFAB40); // Soft Copper Neon
    final Color cyanColor = const Color(0xFF00E5FF); // Cyan

    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final String? contentTitle = args?['title'];
    final String? contentBody = args?['content'];

    return PremiumScaffold(
      showBranding: true,
      title: 'Recursos Humanos',
      useScroll: false,
      usePadding: false,
      floatingActionButton: (contentTitle != null && contentBody != null)
          ? InfoButton(title: contentTitle, content: contentBody)
          : null,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HERO HEADER with Stats
            BusinessHeroHeader(
              title: 'Gestión de Recursos Humanos',
              subtitle: 'Administra tu equipo, calcula planillas y genera documentos legales',
              icon: Icons.people_alt_outlined,
              color: const Color(0xFFFF4081), // Neon Pink
              stats: _isLoading 
                ? null 
                : [
                    StatItem(
                      value: '$_totalEmployees',
                      label: 'Colaboradores',
                      icon: Icons.groups,
                    ),
                    StatItem(
                      value: '\$${_totalPayroll.toStringAsFixed(0)}',
                      label: 'Nómina Base',
                      icon: Icons.payments,
                    ),
                  ],
            ),
            
            const SizedBox(height: 24),
            
            // Alerts Section
            _buildAlertsSection(),
            const SizedBox(height: 24),

            // Guía Educativa
            GestureDetector(
              onTap: () => context.push('/hr/master_guide'), // NEW: Point to Premium Guide
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ModuleGuides.hr.themeColor.withOpacity(0.15),
                      ModuleGuides.hr.themeColor.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: ModuleGuides.hr.themeColor.withOpacity(0.5)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(ModuleGuides.hr.icon, color: ModuleGuides.hr.themeColor, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Guía Maestra: RRHH',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'Aprende a contratar y gestionar tu equipo',
                            style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, color: ModuleGuides.hr.themeColor, size: 14),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Sección de Herramientas
            Row(
              children: [
                Icon(Icons.dashboard_customize, color: const Color(0xFFFF4081), size: 24),
                const SizedBox(width: 12),
                Text(
                  'Herramientas Principales',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Grid de Herramientas Premium
            LayoutBuilder(
              builder: (context, constraints) {
                double spacing = 16;
                double itemWidth = (constraints.maxWidth - spacing) / 2;
                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: [
                    SizedBox(
                      width: itemWidth,
                      child: _buildPremiumToolCard(
                        context,
                        title: 'Base de Datos',
                        subtitle: 'Colaboradores registrados',
                        icon: Icons.recent_actors,
                        color: cyanColor,
                        onTap: () => context.push(AppRoutes.employees),
                        badge: _totalEmployees > 0 ? '$_totalEmployees' : null,
                      ),
                    ),
                    SizedBox(
                      width: itemWidth,
                      child: _buildPremiumToolCard(
                        context,
                        title: 'Gestión Administrativa',
                        subtitle: 'Horario, Vacaciones, Permisos',
                        icon: Icons.calendar_view_week,
                        color: cyanColor,
                        onTap: () => context.push('/schedule_creator'),
                      ),
                    ),
                    SizedBox(
                      width: itemWidth,
                      child: _buildPremiumToolCard(
                        context,
                        title: 'Gestión de Nómina',
                        subtitle: 'Salario, Planilla, Comprobante',
                        icon: Icons.calculate_outlined,
                        color: mainColor,
                        onTap: () => context.push(AppRoutes.salarioNeto),
                      ),
                    ),
                    SizedBox(
                      width: itemWidth,
                      child: _buildPremiumToolCard(
                        context,
                        title: 'Terminación Laboral',
                        subtitle: 'Liquidación, Renuncia, Despido',
                        icon: Icons.work_outline,
                        color: copperColor,
                        onTap: () => context.push(AppRoutes.liquidacion),
                      ),
                    ),
                    SizedBox(
                      width: itemWidth,
                      child: _buildPremiumToolCard(
                        context,
                        title: 'Vacaciones',
                        subtitle: 'Cálculo de días y pago',
                        icon: Icons.beach_access,
                        color: Colors.pinkAccent,
                        onTap: () => context.push('/vacation_calculator'),
                      ),
                    ),
                    SizedBox(
                      width: itemWidth,
                      child: _buildPremiumToolCard(
                        context,
                        title: 'Décimo Tercer Mes',
                        subtitle: 'XIII Mes / Aguinaldo',
                        icon: Icons.card_giftcard,
                        color: Colors.amber,
                        onTap: () => context.push('/decimo_calculator'),
                      ),
                    ),
                    SizedBox(
                      width: itemWidth,
                      child: _buildPremiumToolCard(
                        context,
                        title: 'Documentos',
                        subtitle: 'Plantillas legales',
                        icon: Icons.description_outlined,
                        color: secondaryColor,
                        onTap: () => context.push('/rrhh/plantillas'),
                      ),
                    ),

                    SizedBox(
                      width: itemWidth,
                      child: _buildPremiumToolCard(
                        context,
                        title: 'Enlaces',
                        subtitle: 'CSS / MITRADEL',
                        icon: Icons.link,
                        color: Colors.tealAccent,
                        onTap: () => context.push(AppRoutes.directorio),
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 32),

            // Resumen de Cumplimiento
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: HrComplianceSummaryCard(),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 28),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  subtitle,
                  style: GoogleFonts.outfit(
                    color: color,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.outfit(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumToolCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    String? badge,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.15),
              color.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      badge,
                      style: GoogleFonts.outfit(
                        color: Colors.black,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.outfit(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showOfficialLinksDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F1520),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.tealAccent.withOpacity(0.5)),
        ),
        title: Text(
          'Enlaces Oficiales',
          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Consulta fuentes oficiales para trámites y requisitos específicos.',
              style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 20),
            NeonButton(
              text: 'Caja de Seguro Social (CSS)',
              onTap: () => _launch('https://w3.css.gob.pa/'),
              primary: false,
              color: Colors.white10,
              icon: Icons.open_in_new,
            ),
            const SizedBox(height: 12),
            NeonButton(
              text: 'MITRADEL (Orientación)',
              onTap: () => _launch('https://www.mitradel.gob.pa/'),
              primary: false,
              color: Colors.white10,
              icon: Icons.open_in_new,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cerrar', style: TextStyle(color: Colors.white54)),
          ),
        ],
      ),
    );
  }

  Future<void> _launch(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  Widget _buildAlertsSection() {
    return FutureBuilder<List<HRAlert>>(
      future: _gatherAlerts(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) return const SizedBox.shrink();
        final alerts = snapshot.data!;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.notifications_active, color: Colors.amber, size: 20),
                const SizedBox(width: 8),
                Text('Centro de Alertas', style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            ...alerts.map((a) => GestureDetector(
              onTap: a.onTap,
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: a.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: a.color.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(a.icon, color: a.color, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(a.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                          Text(a.message, style: const TextStyle(color: Colors.white70, fontSize: 11)),
                        ],
                      ),
                    ),
                    if (a.onTap != null)
                      const Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 14),
                  ],
                ),
              ),
            )),
          ],
        );
      },
    );
  }

  Future<List<HRAlert>> _gatherAlerts() async {
    final workers = await _service.getWorkers();
    final alerts = <HRAlert>[];
    
    // 1. Vacation Alerts
    final vacationService = VacationEligibilityService();
    int pendingVacationsCount = 0;
    for (var w in workers) {
      if (vacationService.calculateEligibility(w).any((e) => e.status == VacationStatus.pending)) {
        pendingVacationsCount++;
      }
    }
    
    if (pendingVacationsCount > 0) {
      alerts.add(HRAlert(
        title: 'Vacaciones Pendientes',
        message: 'Hay $pendingVacationsCount empleados con periodos de vacaciones por aprobar.',
        icon: Icons.beach_access,
        color: Colors.pinkAccent,
        onTap: () => context.push(AppRoutes.employees), // Go to employee directory
      ));
    }

    // 2. New Month Alert (XIII Month)
    final now = DateTime.now();
    if (now.month == 4 || now.month == 8 || now.month == 12) {
       alerts.add(HRAlert(
         title: 'Pago de Décimo Próximo',
         message: 'Recuerda procesar el pago del XIII Mes durante este periodo (Agosto).',
         icon: Icons.redeem,
         color: Colors.amber,
       ));
    }

    // 3. Contracts Expiring (Defined contracts ending within 30 days)
    int expiringContracts = 0;
    for (var w in workers) {
      if (w.contractType == WorkerContractType.definido && w.contractEnd != null) {
        final days = w.contractEnd!.difference(now).inDays;
        if (days >= 0 && days <= 30) {
          expiringContracts++;
        }
      }
    }
    if (expiringContracts > 0) {
        alerts.add(HRAlert(
             title: 'Contratos por Vencer',
             message: '$expiringContracts contratos finalizan en los próximos 30 días.',
             icon: Icons.access_time_filled,
             color: Colors.orangeAccent,
             onTap: () => context.push(AppRoutes.employees),
        ));
    }

    // 4. Probation Periods Ending (3 months from start, check if within 15 days)
    int probationEnding = 0;
    for (var w in workers) {
      if (w.startDate != null) {
        final probationEnd = w.startDate!.add(const Duration(days: 90)); // Approx 3 months
        final days = probationEnd.difference(now).inDays;
        if (days >= 0 && days <= 15) {
             probationEnding++;
        }
      }
    }
    if (probationEnding > 0) {
        alerts.add(HRAlert(
             title: 'Periodos de Prueba',
             message: '$probationEnding periodos de prueba finalizan pronto (15 días o menos).',
             icon: Icons.how_to_reg,
             color: const Color(0xFF00E5FF), // Cyan
             onTap: () => context.push(AppRoutes.employees),
        ));
    }

    return alerts;
  }
}

class HRAlert {
  final String title;
  final String message;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  HRAlert({required this.title, required this.message, required this.icon, required this.color, this.onTap});
}
