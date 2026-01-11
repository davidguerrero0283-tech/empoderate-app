import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../components/premium_scaffold.dart';
import '../../../components/neon_widgets.dart';
import '../../rrhh/obligaciones/services/obligaciones_updates_service.dart';
import 'services/compliance_checklist_service.dart';
import '../../../../ui/theme/empoderate_theme.dart';

/// Pantalla de Obligaciones Laborales con badges de actualización
class LaborComplianceScreen extends StatefulWidget {
  const LaborComplianceScreen({Key? key}) : super(key: key);

  @override
  State<LaborComplianceScreen> createState() => _LaborComplianceScreenState();
}

class _LaborComplianceScreenState extends State<LaborComplianceScreen> {
  final ObligacionesUpdatesService _service = ObligacionesUpdatesService();
  final ComplianceChecklistService _checklistService = ComplianceChecklistService();
  Map<String, bool> _hasUpdates = {'css': false, 'permisos': false, 'calendario': false};
  ComplianceProgress? _progress;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final updates = await _service.checkForModuleUpdates();
    final progress = await _checklistService.getProgress();
    if (mounted) {
      setState(() {
        _hasUpdates = updates;
        _progress = progress;
        _isLoading = false;
      });
    }
  }

  String _getFortnightText() {
    final now = DateTime.now();
    final monthNames = ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 
                        'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'];
    final monthName = monthNames[now.month - 1];
    final fortnight = now.day <= 15 ? '1ra Quincena' : '2da Quincena';
    return '$fortnight • $monthName ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      title: 'Obligaciones Laborales',
      showBackButton: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFFF4081).withOpacity(0.2),
                    const Color(0xFFFF4081).withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFF4081).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF4081).withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.assignment_turned_in, color: Color(0xFFFF4081), size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Gestiona tus Obligaciones',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Mantén tu negocio en cumplimiento',
                          style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // CHECKLIST PROGRESS CARD
            GestureDetector(
              onTap: () async {
                await context.push('/hr/compliance_checklist');
                _loadData();
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      EmpoderateTheme.gold.withOpacity(0.15),
                      Colors.transparent,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: EmpoderateTheme.gold.withOpacity(0.4)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: EmpoderateTheme.gold.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.checklist, color: EmpoderateTheme.gold, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Checklist de Cumplimiento',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _getFortnightText(),
                            style: GoogleFonts.outfit(color: EmpoderateTheme.gold.withOpacity(0.9), fontSize: 10),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_progress?.completed ?? 0}/${_progress?.total ?? 0} tareas completadas',
                            style: GoogleFonts.outfit(color: Colors.white60, fontSize: 11),
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: _progress?.percent ?? 0.0,
                              minHeight: 6,
                              backgroundColor: Colors.white10,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                (_progress?.percent ?? 0) >= 1.0
                                    ? Colors.greenAccent
                                    : EmpoderateTheme.gold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      children: [
                        Text(
                          '${((_progress?.percent ?? 0) * 100).toInt()}%',
                          style: GoogleFonts.outfit(
                            color: EmpoderateTheme.gold,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios, color: EmpoderateTheme.gold, size: 12),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Sección de Herramientas
            Text(
              'Herramientas de Cumplimiento',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // PAGO DE PLANILLA - Enhanced Card
            _buildPlanillaCard(context),
            const SizedBox(height: 12),

            _buildToolCard(
              context,
              title: 'CSS / Cuota Obrero Patronal',
              subtitle: 'Gestión de seguro social',
              icon: Icons.health_and_safety,
              color: const Color(0xFF00E5FF),
              route: '/hr/obligaciones/css',
              moduleId: 'css',
            ),
            const SizedBox(height: 12),

            _buildToolCard(
              context,
              title: 'Décimo Tercer Mes',
              subtitle: 'Cálculo y registro del XIII mes',
              icon: Icons.card_giftcard,
              color: Colors.amber,
              route: '/decimo_calculator',
              moduleId: null,
            ),
            const SizedBox(height: 12),

            _buildToolCard(
              context,
              title: 'Vacaciones',
              subtitle: 'Gestión de periodos vacacionales',
              icon: Icons.beach_access,
              color: Colors.pinkAccent,
              route: '/vacation_calculator',
              moduleId: null,
            ),
            const SizedBox(height: 12),

            _buildToolCard(
              context,
              title: 'Permisos y Licencias',
              subtitle: 'Control de ausencias justificadas',
              icon: Icons.event_note,
              color: const Color(0xFF9575CD),
              route: '/hr/obligaciones/permisos',
              moduleId: 'permisos',
            ),
            const SizedBox(height: 12),

            _buildToolCard(
              context,
              title: 'Contratos y Reglamentos',
              subtitle: 'Plantillas y documentación legal',
              icon: Icons.description,
              color: const Color(0xFFE040FB),
              route: '/rrhh/plantillas',
              moduleId: null,
            ),
            const SizedBox(height: 12),

            _buildToolCard(
              context,
              title: 'Calendario de Obligaciones',
              subtitle: 'Fechas límite y recordatorios',
              icon: Icons.calendar_today,
              color: const Color(0xFFFFB74D),
              route: '/hr/obligaciones/calendario',
              moduleId: 'calendario',
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildToolCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String? route,
    required String? moduleId,
  }) {
    final hasNewUpdate = moduleId != null && (_hasUpdates[moduleId] ?? false);
    
    return GestureDetector(
      onTap: () {
        if (route != null) {
          context.push(route);
        } else {
          context.push('/under_construction?title=${Uri.encodeComponent(title)}');
        }
      },
      child: Container(
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
        ),
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                // NEW Badge
                if (hasNewUpdate)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'NUEVO',
                        style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
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
                      color: Colors.white60,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              route != null ? Icons.arrow_forward_ios : Icons.construction,
              color: route != null ? color : Colors.orange,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  /// Enhanced Planilla card with quincena info and educational compliance content
  Widget _buildPlanillaCard(BuildContext context) {
    final now = DateTime.now();
    final quincena = now.day <= 15 ? '1ra Quincena' : '2da Quincena';
    
    return GestureDetector(
      onTap: () => context.push('/salario'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF4CAF50).withOpacity(0.2),
              const Color(0xFF4CAF50).withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF4CAF50).withOpacity(0.4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.payments, color: Color(0xFF4CAF50), size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pago de Planilla',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50).withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          quincena,
                          style: GoogleFonts.outfit(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, color: Color(0xFF4CAF50), size: 18),
              ],
            ),
            const SizedBox(height: 16),
            
            // Educational content about payroll compliance
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.white54, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        '¿Sabías que?',
                        style: GoogleFonts.outfit(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'En Panamá, el pago de planilla incluye deducciones obligatorias:\n'
                    '• CSS Empleado: 9.75% del salario bruto\n'
                    '• CSS Patronal: 12.25% (lo paga el empleador)\n'
                    '• Seguro Educativo: 1.25% empleado + 1.50% empleador',
                    style: GoogleFonts.outfit(color: Colors.white60, fontSize: 11, height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            
            Row(
              children: [
                _buildQuickAction('Calculadora', Icons.calculate, () => context.push('/salario')),
                const SizedBox(width: 8),
                _buildQuickAction('Empleados', Icons.people, () => context.push('/employees')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(String label, IconData icon, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white70, size: 16),
              const SizedBox(width: 6),
              Text(label, style: GoogleFonts.outfit(color: Colors.white70, fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }
}
