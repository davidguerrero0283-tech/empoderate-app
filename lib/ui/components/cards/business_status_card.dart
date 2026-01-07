import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_empoderate/ui/theme/empoderate_theme.dart';
import 'package:proyecto_empoderate/src/models/checklist_model.dart';
import 'package:proyecto_empoderate/src/components/neon_widgets.dart'; 

// Note: neon_widgets is in lib/ui/components/. Cards is lib/ui/components/cards.
// So .. goes to lib/ui/components. That works.

class BusinessStatusCard extends StatefulWidget {
  final BusinessProgressModel dashboard;
  final VoidCallback onTap;
  final Function(int) onTapSection;

  const BusinessStatusCard({
    Key? key, 
    required this.dashboard,
    required this.onTap,
    required this.onTapSection,
  }) : super(key: key);

  @override
  State<BusinessStatusCard> createState() => _BusinessStatusCardState();
}

class _BusinessStatusCardState extends State<BusinessStatusCard> {
  bool _isHovered = false;
  
  @override
  Widget build(BuildContext context) {
    // Colors
    final Color kGold = const Color(0xFFD4AF37);
    
    // Safety Clamp
    final overallPercent = widget.dashboard.overall.percent.clamp(0.0, 1.0); 

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: LinearGradient(
             colors: [
               const Color(0xFF020C1F), // Deep Blue Black
               const Color(0xFF0A2342), // Navy
             ],
             begin: Alignment.topLeft,
             end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _isHovered ? kNeonGold : kGold.withOpacity(0.3),
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
              BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 4)),
              BoxShadow(color: kGold.withOpacity(0.05), blurRadius: 50, spreadRadius: 0),
            ],
          ],
        ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24), // Match container
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: widget.onTap, // Main Card Action
          splashColor: kGold.withOpacity(0.1),
          highlightColor: kGold.withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // HEADER LINE
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Estado de tu negocio',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Progreso general (ponderado)',
                          style: GoogleFonts.outfit(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    // Circular Percent Indicator
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: overallPercent),
                      duration: const Duration(milliseconds: 1000),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, _) {
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 50, height: 50,
                              child: CircularProgressIndicator(
                                value: value,
                                backgroundColor: Colors.white10,
                                color: kGold,
                                strokeWidth: 4,
                              ),
                            ),
                            Text(
                              '${(value * 100).toInt()}%',
                              style: GoogleFonts.outfit(color: kGold, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ],
                        );
                      }
                    )
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // GENERAL BAR (Animated)
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: overallPercent),
                  duration: const Duration(milliseconds: 1200),
                  curve: Curves.easeOutQuad,
                  builder: (context, value, _) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: value,
                        backgroundColor: Colors.white10,
                        color: kGold,
                        minHeight: 8,
                      ),
                    );
                  }
                ),
                 const SizedBox(height: 8),
                 Row(
                   children: [
                     Icon(Icons.bolt, size: 14, color: kGold),
                     const SizedBox(width: 4),
                     Expanded(
                       child: Text(
                         "Siguiente: ${widget.dashboard.overall.nextTitle ?? '¡Todo listo!'}",
                         style: GoogleFonts.outfit(color: kGold, fontSize: 12, fontWeight: FontWeight.w500),
                         maxLines: 1, overflow: TextOverflow.ellipsis,
                       ),
                     ),
                   ],
                 ),

                const SizedBox(height: 20),
                
                // MINI BARS GRID (4 AREAS)
                Row(
                  children: [
                    _buildMiniArea(context, "Inicio (40%)", widget.dashboard.byArea[ProgressArea.start], 0),
                    const SizedBox(width: 8),
                    _buildMiniArea(context, "Planilla (20%)", widget.dashboard.byArea[ProgressArea.payroll], 1),
                    const SizedBox(width: 8),
                    _buildMiniArea(context, "Contab. (20%)", widget.dashboard.byArea[ProgressArea.accounting], 2),
                    const SizedBox(width: 8),
                    _buildMiniArea(context, "Market. (20%)", widget.dashboard.byArea[ProgressArea.marketing], 3),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // CTA BUTTONS (ROW)
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: kGold.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: kGold.withOpacity(0.3)),
                        ),
                        child: Center(
                          child: Text(
                            'VER CHECKLIST COMPLETO',
                            style: GoogleFonts.outfit(
                              color: kGold,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // ORIGIN BUTTON
                    GestureDetector(
                       onTap: () => _showOriginDialog(context),
                       child: Container(
                         padding: const EdgeInsets.all(10),
                         decoration: BoxDecoration(
                           color: Colors.white.withOpacity(0.05),
                           borderRadius: BorderRadius.circular(12),
                           border: Border.all(color: Colors.white10),
                         ),
                         child: const Icon(Icons.info_outline, color: Colors.white54, size: 20),
                       ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
    );
  }

  void _showOriginDialog(BuildContext context) {
    showDialog(
      context: context, 
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0A2342),
        title: Text("Origen de datos", style: GoogleFonts.outfit(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSourceItem("Inicio (40%)", "Fuente: Negocio por rubro (checklist del rubro seleccionado)."),
            _buildSourceItem("Planilla (20%)", "Fuente: Obligaciones laborales y cumplimiento (cuando estén configuradas)."),
            _buildSourceItem("Contabilidad (20%)", "Fuente: hitos guardados (presupuesto, flujo, punto de equilibrio, etc.)."),
            _buildSourceItem("Marketing (20%)", "Fuente: embudo/campañas/métricas configuradas."),
            const SizedBox(height: 12),
            Text(
              "Última actualización: ${widget.dashboard.updatedAt.toString().substring(0, 16)}",
              style: GoogleFonts.outfit(color: Colors.white24, fontSize: 10),
            )
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx), 
            child: Text("Entendido", style: GoogleFonts.outfit(color: const Color(0xFFD4AF37)))
          )
        ],
      )
    );
  }

  Widget _buildSourceItem(String area, String source) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(area, style: GoogleFonts.outfit(color: const Color(0xFF00E5FF), fontWeight: FontWeight.bold, fontSize: 13)),
          Text(source, style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildMiniArea(BuildContext context, String label, ProgressSummary? summary, int index) {
    if (summary == null) return const Expanded(child: SizedBox());
    
    // Configured check
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(4),
          onTap: () => widget.onTapSection(index),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2), // Small padding for touch area
            child: Column(
               children: [
                 _buildMiniBar(summary),
                  const SizedBox(height: 6),
                  Text(
                    label,
                    style: GoogleFonts.outfit(color: Colors.white70, fontSize: 9),
                    maxLines: 1, overflow: TextOverflow.clip,
                  ),
                  if (summary.configured)
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: summary.percent),
                     duration: const Duration(milliseconds: 1000),
                     curve: Curves.easeOut,
                     builder: (context, value, _) {
                        return Column(
                          children: [
                            Text(
                              "${(value*100).toInt()}%",
                              style: GoogleFonts.outfit(color: const Color(0xFF00E5FF), fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "${summary.done}/${summary.total}",
                              style: GoogleFonts.outfit(color: Colors.white38, fontSize: 9),
                            )
                          ],
                        );
                     }
                  )
                  else
                   Container(
                      margin: const EdgeInsets.only(top: 2),
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.white10)
                      ),
                      child: Text("Sin data", style: GoogleFonts.outfit(color: Colors.white30, fontSize: 7)),
                   )
               ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMiniBar(ProgressSummary summary) {
     if (!summary.configured) {
        return Container(
          height: 4, width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(2)
          ),
        );
     }
     
     return TweenAnimationBuilder<double>(
       tween: Tween<double>(begin: 0, end: summary.percent),
       duration: const Duration(milliseconds: 1000),
       curve: Curves.easeOut,
       builder: (context, value, _) {
         return ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: value,
              backgroundColor: Colors.white10,
              color: const Color(0xFF00E5FF),
              minHeight: 4,
            ),
          );
       }
     );
  }
}
