import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_empoderate/ui/theme/empoderate_theme.dart';
import '../../components/neon_widgets.dart';
import '../../navigation/app_routes.dart';
// import '../../features/agenda/services/agenda_service.dart'; // OLD - REMOVED

class BusinessInsightPanel extends StatelessWidget {
  const BusinessInsightPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Mock Data for MVP - Should eventually come from a Provider
    const String balance = '\$ 1,250.00';
    const bool isDemo = true;
    // final AgendaService agendaService = AgendaService(); // OLD - REMOVED

    return _InsightMainCardWithHover(
      balance: balance,
    );
  }
}

class _InsightMainCardWithHover extends StatefulWidget {
  final String balance;

  const _InsightMainCardWithHover({required this.balance});

  @override
  State<_InsightMainCardWithHover> createState() => _InsightMainCardWithHoverState();
}

class _InsightMainCardWithHoverState extends State<_InsightMainCardWithHover> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isHovered ? kNeonGold : EmpoderateTheme.gold.withOpacity(0.4),
            width: _isHovered ? 2 : 1,
          ),
          boxShadow: [
            if (_isHovered)
              BoxShadow(
                color: kNeonGold.withOpacity(0.4),
                blurRadius: 25,
                spreadRadius: 2,
              )
            else
              BoxShadow(
                color: Colors.black45,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: NeonCard(
          padding: EdgeInsets.zero,
          borderColor: Colors.transparent, // Handled by AnimatedContainer
          backgroundColor: Colors.transparent, // Handled by AnimatedContainer
          child: Stack(
            children: [
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: [
                        EmpoderateTheme.gold.withOpacity(0.05),
                        Colors.black.withOpacity(0.4),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: EmpoderateTheme.gold.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.analytics_rounded,
                                  color: EmpoderateTheme.gold, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Panel Inteligente',
                              style: GoogleFonts.outfit(
                                color: EmpoderateTheme.gold,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            _buildAiPill(
                              context,
                              'Insights',
                              Icons.lightbulb_outline,
                              () => _showRecommendations(context),
                            ),
                            const SizedBox(width: 8),
                            _buildAiPill(
                              context,
                              'Asistente',
                              Icons.smart_toy_outlined,
                              () => Navigator.pushNamed(context, AppRoutes.aiChat),
                              isPrimary: true,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    LayoutBuilder(builder: (context, constraints) {
                      final bool isDesktop = constraints.maxWidth > 800;
                      if (isDesktop) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                                flex: 4, child: _buildMainBalance(widget.balance)),
                            const SizedBox(width: 32),
                            Expanded(
                              flex: 6,
                              child: _buildIndicatorsGrid(),
                            ),
                          ],
                        );
                      } else {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildMainBalance(widget.balance),
                            const SizedBox(height: 24),
                            _buildIndicatorsGrid(),
                          ],
                        );
                      }
                    }),
                    const SizedBox(height: 24),
                    const Divider(color: Colors.white10),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: EmpoderateTheme.purpleAccent.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: EmpoderateTheme.purpleAccent.withOpacity(0.1)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.auto_awesome,
                              color: EmpoderateTheme.purpleAccent, size: 18),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Sugerencia IA: Mantén tu agenda al día para mejorar tu calificación crediticia interna.',
                              style: GoogleFonts.outfit(
                                  color: Colors.white70, fontSize: 13),
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios_rounded,
                              color: Colors.white30, size: 12),
                        ],
                      ),
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

  Widget _buildMainBalance(String balance) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Estado del negocio',
          style: GoogleFonts.outfit(color: Colors.white54, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Text(
          balance,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 42,
            fontWeight: FontWeight.bold,
            letterSpacing: -1,
            shadows: [
              BoxShadow(
                color: EmpoderateTheme.gold.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 2,
              )
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  const Icon(Icons.trending_up,
                      color: Colors.greenAccent, size: 14),
                  const SizedBox(width: 4),
                  Text('+12%',
                      style: GoogleFonts.outfit(
                          color: Colors.greenAccent,
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text('vs. mes anterior',
                style: GoogleFonts.outfit(color: Colors.white30, fontSize: 12)),
          ],
        ),
      ],
    );
  }

  Widget _buildIndicatorsGrid() {
    // Agenda Logic - OLD REMOVED
    final alertCount = 0; // TODO: Connect to new AgendaRepository
    String agendaValue = 'Al día';
    Color agendaColor = Colors.greenAccent;
    IconData agendaIcon = Icons.verified_outlined;

    if (alertCount > 0) {
      agendaValue = '$alertCount Alertas';
      agendaColor = Colors.orangeAccent;
      agendaIcon = Icons.warning_amber_rounded;
    }

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _InsightMiniCardWithHover(
          label: 'Ingresos',
          value: '\$2,500',
          icon: Icons.arrow_upward_rounded,
          color: Colors.greenAccent,
          width: 140,
        ),
        _InsightMiniCardWithHover(
          label: 'Gastos',
          value: '\$1,250',
          icon: Icons.arrow_downward_rounded,
          color: Colors.redAccent,
          width: 140,
        ),
        _InsightMiniCardWithHover(
          label: 'Cash Flow',
          value: '\$5,000',
          icon: Icons.account_balance_wallet_outlined,
          color: Colors.blueAccent,
          width: 140,
        ),
        // Integated Agenda Item
        _InsightMiniCardWithHover(
          label: 'Agenda',
          value: agendaValue,
          icon: agendaIcon,
          color: agendaColor,
          width: 140,
        ),
      ],
    );
  }

  Widget _buildAiPill(BuildContext context, String text, IconData icon,
      VoidCallback onTap,
      {bool isPrimary = false}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isPrimary
              ? EmpoderateTheme.gold.withOpacity(0.15)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isPrimary
                ? EmpoderateTheme.gold.withOpacity(0.5)
                : Colors.white12,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: isPrimary ? EmpoderateTheme.gold : Colors.white70, size: 14),
            const SizedBox(width: 6),
            Text(
              text,
              style: GoogleFonts.outfit(
                color: isPrimary ? Colors.white : Colors.white70,
                fontSize: 12,
                fontWeight: isPrimary ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRecommendations(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: const Color(0xFF0F1520),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Colors.white10)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.lightbulb, color: EmpoderateTheme.gold, size: 24),
                  const SizedBox(width: 12),
                  Text('Recomendaciones IA',
                      style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 24),
              _buildBullet(
                  'Completa tu perfil de negocio para obtener análisis sectorial.'),
              _buildBullet('Revisa el checklist de permisos municipales.'),
              _buildBullet(
                  'Registra tus gastos fijos estimados en el modulo de Finanzas.'),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: EmpoderateTheme.gold,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Entendido',
                      style: GoogleFonts.outfit(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline,
              color: EmpoderateTheme.gold, size: 16),
          const SizedBox(width: 12),
          Expanded(
              child: Text(text,
                  style: GoogleFonts.outfit(color: Colors.white70, height: 1.4))),
        ],
      ),
    );
  }
}

class _InsightMiniCardWithHover extends StatefulWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final double width;

  const _InsightMiniCardWithHover({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.width,
  });

  @override
  State<_InsightMiniCardWithHover> createState() => _InsightMiniCardWithHoverState();
}

class _InsightMiniCardWithHoverState extends State<_InsightMiniCardWithHover> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: widget.width, // Fixed width for consistent grid
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isHovered ? kNeonGold : Colors.white.withOpacity(0.05),
            width: _isHovered ? 1.5 : 1,
          ),
          boxShadow: [
            if (_isHovered)
              BoxShadow(
                color: kNeonGold.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 1,
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(widget.icon, color: widget.color.withOpacity(0.8), size: 16),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(widget.label,
                        style: GoogleFonts.outfit(
                            color: Colors.white54, fontSize: 11),
                        overflow: TextOverflow.ellipsis)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              widget.value,
              style: GoogleFonts.outfit(
                  color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
