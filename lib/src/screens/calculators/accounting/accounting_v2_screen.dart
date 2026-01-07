import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_empoderate/src/components/premium_scaffold.dart';
import 'package:proyecto_empoderate/src/components/neon_widgets.dart';
import 'package:proyecto_empoderate/src/features/hr/compliance/hr_compliance_service.dart';
import 'package:proyecto_empoderate/src/widgets/feature_intro_screen.dart';

import 'package:proyecto_empoderate/src/config/accounting_config.dart';
import '../../../navigation/app_routes.dart';
import '../../../data/repositories/checklist_repository.dart';
import '../../../models/checklist_model.dart';
import '../../learning/module_guide_data.dart';

class AccountingV2Screen extends StatefulWidget {
  const AccountingV2Screen({Key? key}) : super(key: key);

  @override
  State<AccountingV2Screen> createState() => _AccountingV2ScreenState();
}

class _AccountingV2ScreenState extends State<AccountingV2Screen> {
  final HrComplianceService _hrService = HrComplianceService();
  bool _showIntro = true;

  // Sorted tools
  late final List<AccountingToolConfig> _mainTools;
  late final List<AccountingToolConfig> _extraTools;

  @override
  void initState() {
    super.initState();
    _mainTools = accountingTools
        .where((tool) => tool.category == AccountingCategory.main)
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));
    _extraTools = accountingTools
        .where((tool) => tool.category == AccountingCategory.extra)
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      title: 'Contabilidad',
      isNeonTitle: true,
      showBackButton: true,
      body: Stack(
        children: [
          // MAIN CONTENT - wrapped in Positioned.fill
          Positioned.fill(
            child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 80),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- HEADER ---
                Container(
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.analytics_outlined, color: Color(0xFFD4AF37), size: 32),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Control Financiero Inteligente',
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Sigue estos 6 pasos para dominar tus finanzas.',
                              style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // --- SEQUENTIAL TOOLS (MAIN PATH) ---
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    'RUTA DE CONTROL FINANCIERO',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFFD4AF37),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                ..._mainTools.map((tool) => _buildSequentialCard(context, tool)).toList(),

                const SizedBox(height: 32),

                // --- EXTRA TOOLS ---
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    'CALCULADORAS RÁPIDAS',
                    style: GoogleFonts.outfit(
                      color: Colors.white54,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                _buildExtraToolsGrid(),
              ],
            ),
          ),
        ),

          // --- INTRO OVERLAY ---
          if (_showIntro)
            Positioned.fill(
              child: FeatureIntroScreen(
                key: const ValueKey('IntroOverlay'),
                title: 'CONTROL FINANCIERO',
                subTitle: 'Toma el control total de tus números. Costos, márgenes, presupuestos y flujo de caja en un solo lugar.',
                heroEmoji: '📊',
                primaryColor: const Color(0xFFD4AF37), // Gold
                features: const [
                  IntroFeatureItem(Icons.business, 'Costos'),
                  IntroFeatureItem(Icons.balance, 'Equilibrio'),
                  IntroFeatureItem(Icons.pie_chart, 'Presupuesto'),
                  IntroFeatureItem(Icons.waves, 'Flujo'),
                ],
                processSteps: const [
                  IntroStepItem('1. Costos', 'Conoce cuánto te cuesta operar.'),
                  IntroStepItem('2. Equilibrio', 'Calcula tu punto de no pérdida.'),
                  IntroStepItem('3. Margen', 'Define precios rentables.'),
                  IntroStepItem('4. Presupuesto', 'Distribuye tu dinero.'),
                ],
                proTip: 'Sigue el orden sugerido para construir un entendimiento sólido de tus finanzas.',
                onDismiss: () => setState(() => _showIntro = false),
              ),
            ),
        ],
      ),
    );
  }

  /// Sequential card with step number, context tip, and next-step button
  Widget _buildSequentialCard(BuildContext context, AccountingToolConfig tool) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: tool.color.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(color: tool.color.withOpacity(0.1), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: tool.color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(tool.icon, color: tool.color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tool.title,
                      style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tool.description,
                      style: GoogleFonts.outfit(color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Context Tip (if available)
          if (tool.contextTip != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.withOpacity(0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lightbulb_outline, color: Colors.amber, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      tool.contextTip!,
                      style: GoogleFonts.outfit(color: Colors.amber.shade100, fontSize: 11, fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, tool.route),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: tool.color,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(tool.actionLabel, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                ),
              ),
              if (tool.nextStepId != null) ...[
                const SizedBox(width: 12),
                Tooltip(
                  message: 'Siguiente: ${getNextTool(tool.id)?.title ?? "N/A"}',
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: const Icon(Icons.arrow_forward, color: Colors.white54, size: 20),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  /// Grid of extra/quick tools
  Widget _buildExtraToolsGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 12.0;
        final cols = constraints.maxWidth > 600 ? 3 : 2;
        final itemWidth = (constraints.maxWidth - (spacing * (cols - 1))) / cols;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: _extraTools.map((tool) {
            return SizedBox(
              width: itemWidth,
              child: _buildMiniCard(context, tool),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildMiniCard(BuildContext context, AccountingToolConfig tool) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, tool.route),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: tool.color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(tool.icon, color: tool.color, size: 28),
            const SizedBox(height: 8),
            Text(
              tool.title,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              tool.actionLabel,
              style: GoogleFonts.outfit(color: tool.color, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
