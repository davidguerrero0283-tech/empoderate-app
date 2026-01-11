import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../ui/theme/empoderate_theme.dart';
import '../../../components/premium_scaffold.dart';
import '../../../components/business_hero_header.dart';

class HrMasterGuideScreen extends StatefulWidget {
  const HrMasterGuideScreen({super.key});

  @override
  State<HrMasterGuideScreen> createState() => _HrMasterGuideScreenState();
}

class _HrMasterGuideScreenState extends State<HrMasterGuideScreen> {
  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      title: 'GUÍA MAESTRA RRHH',
      isNeonTitle: true,
      showBackButton: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HERO CARD
            _buildHeroCard(),
            const SizedBox(height: 32),

            // SECCIÓN TEXTO EXTRA (Requested)
            _buildSectionTitle('Fundamentos Estratégicos', Icons.lightbulb),
            const SizedBox(height: 16),
            _buildTextSection(),
            const SizedBox(height: 32),

            // SECCIÓN 1: FLUJO REAL
            _buildSectionTitle('Flujo Real de RRHH', Icons.timeline),
            const SizedBox(height: 16),
            _buildTimelineSection(),
            const SizedBox(height: 32),

            // SECCIÓN 2: COMPARATIVA
            _buildSectionTitle('RRHH vs Contabilidad vs Legal', Icons.compare_arrows),
             const SizedBox(height: 16),
            _buildComparisonSection(),
            const SizedBox(height: 32),

            // SECCIÓN 3: CHECKLIST
            _buildSectionTitle('Checklist por Etapas', Icons.checklist_rtl),
             const SizedBox(height: 16),
            _buildChecklistSection(),
            const SizedBox(height: 32),

            // SECCIÓN 4: ACCESOS DIRECTOS
            _buildSectionTitle('Herramientas & Accesos', Icons.touch_app),
             const SizedBox(height: 16),
            _buildQuickAccessSection(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: EmpoderateTheme.gold, size: 24),
        const SizedBox(width: 12),
        Text(
          title,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // --- HERO CARD ---
  Widget _buildHeroCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1A237E).withOpacity(0.8), // Deep Navy
            const Color(0xFF0D47A1).withOpacity(0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: EmpoderateTheme.gold.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: EmpoderateTheme.gold.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'RECURSOS HUMANOS',
            style: GoogleFonts.outfit(
              color: EmpoderateTheme.gold,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'El arte de gestionar talento con precisión legal',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Desde la contratación hasta la liquidación, RRHH es el motor que asegura el cumplimiento laboral, la paga justa y el clima organizacional. Aquí encontrarás el mapa completo para navegar las leyes de Panamá sin riesgos.',
            style: GoogleFonts.outfit(
              color: Colors.white70,
              fontSize: 15,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            children: [
              _buildTag('Planillas'),
              _buildTag('Contratos'),
              _buildTag('Vacaciones'),
              _buildTag('Liquidaciones'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 11),
      ),
    );
  }

  // --- TEXT SECTION (NEW) ---
  Widget _buildTextSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(color: EmpoderateTheme.gold, width: 4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Más allá de la Burocracia',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Una gestión de recursos humanos eficiente no solo te protege de multas del Ministerio de Trabajo, sino que crea un ambiente donde el mejor talento quiere quedarse.\n\nLa clave del éxito en Panamá está en la transparencia documental: contratos claros, descripciones de puesto definidas y pagos puntuales que incluyan todas las prestaciones de ley. Cuando tus colaboradores sienten seguridad financiera y legal, su productividad aumenta drásticamente y la rotación disminuye.\n\nUtiliza las herramientas de esta app para transformar los cálculos complejos en una ventaja competitiva para tu negocio.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  // --- TIMELINE SECTION ---
  Widget _buildTimelineSection() {
    final steps = [
      {'title': '1. Estructura', 'desc': 'Definir cargos y salarios.'},
      {'title': '2. Reclutamiento', 'desc': 'Selección del talento ideal.'},
      {'title': '3. Contratación', 'desc': 'Firma de contrato y registro.'},
      {'title': '4. Asistencia', 'desc': 'Registro de turnos y marcas.'},
      {'title': '5. Planilla', 'desc': 'Cálculo de horas y pagos.'},
      {'title': '6. Deducciones', 'desc': 'Seguro Social, Educativo, ISR.'},
      {'title': '7. Pagos', 'desc': 'Transferencia y comprobantes.'},
      {'title': '8. Vacaciones', 'desc': 'Control de días y goce.'},
      {'title': '9. Décimo', 'desc': 'Pago de XIII Mes (3 veces/año).'},
      {'title': '10. Disciplina', 'desc': 'Amonestaciones y control.'},
      {'title': '11. Liquidación', 'desc': 'Cálculo final y finiquito.'},
      {'title': '12. Historial', 'desc': 'Archivo y referencias.'},
      {'title': '13. Auditoría', 'desc': 'Revisión de cumplimiento.'},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: steps.asMap().entries.map((entry) {
          final isLast = entry.key == steps.length - 1;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: EmpoderateTheme.gold,
                      shape: BoxShape.circle,
                    ),
                  ),
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 40,
                      color: Colors.white12,
                    ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.value['title']!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        entry.value['desc']!,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  // --- COMPARISON SECTION ---
  Widget _buildComparisonSection() {
    return SizedBox(
      height: 160,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildCompareCard(
            'Recursos Humanos',
            ['Datos del Trabajador', 'Jornadas & Turnos', 'Documentos Laborales', 'Clima Laboral'],
            const Color(0xFFE91E63), // Pink
            Icons.people,
          ),
          const SizedBox(width: 12),
          _buildCompareCard(
            'Contabilidad',
            ['Registro de Pagos', 'Cálculo de Costos', 'Pago de Impuestos', 'Flujo de Caja'],
            const Color(0xFF2196F3), // Blue
            Icons.account_balance_wallet,
          ),
          const SizedBox(width: 12),
          _buildCompareCard(
            'Legal',
            ['Contratos Ley', 'Reglamento Interno', 'Litigios Laborales', 'Mitradel'],
            const Color(0xFFFFC107), // Amber
            Icons.gavel,
          ),
        ],
      ),
    );
  }

  Widget _buildCompareCard(String title, List<String> items, Color color, IconData icon) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.outfit(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const Divider(color: Colors.white12, height: 20),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Icon(Icons.check, color: color.withOpacity(0.7), size: 12),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    item,
                    style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 11),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  // --- CHECKLIST SECTION ---
  Widget _buildChecklistSection() {
    return Column(
      children: [
        _buildChecklistTile('Etapa 1: Base', ['Expedientes al día', 'Contratos firmados', 'Cargos definidos']),
        const SizedBox(height: 12),
        _buildChecklistTile('Etapa 2: Operación', ['Planilla quincenal', 'Control de vacaciones', 'Recibos de pago']),
        const SizedBox(height: 12),
        _buildChecklistTile('Etapa 3: Control', ['Liquidaciones cerradas', 'Pago de impuestos', 'Auditoría interna']),
      ],
    );
  }

  Widget _buildChecklistTile(String stage, List<String> items) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            stage,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: items.map((item) => Expanded(
              child: Row(
                children: [
                  const Icon(Icons.check_box_outline_blank, color: Colors.white38, size: 14),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                  ),
                ],
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  // --- QUICK ACCESS SECTION ---
  Widget _buildQuickAccessSection(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _buildQuickButton(context, 'Directorio', Icons.groups, '/hr/employees', Colors.cyan),
        _buildQuickButton(context, 'Turnos', Icons.access_time, '/shift_logger', Colors.orangeAccent),
        _buildQuickButton(context, 'Planilla', Icons.attach_money, '/salario_neto', Colors.greenAccent),
        _buildQuickButton(context, 'Vacaciones', Icons.beach_access, '/vacation_calculator', Colors.pinkAccent),
        _buildQuickButton(context, 'Décimo', Icons.card_giftcard, '/decimo_calculator', Colors.purpleAccent),
        _buildQuickButton(context, 'Liquidación', Icons.work_off, '/liquidacion', Colors.redAccent),
        _buildQuickButton(context, 'Plantillas', Icons.description, '/rrhh/plantillas', Colors.tealAccent),
        _buildQuickButton(context, 'Cumplimiento', Icons.verified_user, '/rrhh/cumplimiento', Colors.blueAccent),
      ],
    );
  }

  Widget _buildQuickButton(BuildContext context, String label, IconData icon, String route, Color color) {
    return GestureDetector(
      onTap: () => context.push(route),
      child: Container(
        width: 100, // Fixed width for grid look
        height: 90,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
