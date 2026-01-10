import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../components/premium_scaffold.dart';
import '../components/neon_widgets.dart';
import '../components/calculator_info_panel.dart';
import 'package:go_router/go_router.dart';
import '../features/tools/auditoria/auditoria_service.dart';
import '../navigation/app_routes.dart';

class AuditoriaNegocioScreen extends StatefulWidget {
  const AuditoriaNegocioScreen({Key? key}) : super(key: key);

  @override
  State<AuditoriaNegocioScreen> createState() => _AuditoriaNegocioScreenState();
}

class _AuditoriaNegocioScreenState extends State<AuditoriaNegocioScreen> {
  final AuditoriaService _service = AuditoriaService.instance;
  bool _isLoading = true;
  List<BusinessArea> _areas = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await _service.init();
    final areas = await _service.getAreas();
    setState(() {
      _areas = areas;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      title: 'AUDITORÍA',
      showBackButton: true,
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: kNeonViolet))
        : RefreshIndicator(
            onRefresh: _loadData,
            color: kNeonViolet,
            backgroundColor: const Color(0xFF0F1520),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Info Panel
                    const CalculatorInfoPanel(configId: 'auditoria'),
                    const SizedBox(height: 24),
                    
                    const NeonSectionTitle(
                      title: 'Estado del Negocio',
                      color: kNeonViolet, 
                    ),
                    const SizedBox(height: 16),
                    
                    // Table
                    NeonTable(
                      headers: const ['Área', 'Progreso', 'Estado', 'Prioridad'],
                      accentColor: kNeonViolet,
                      rows: _areas.map((area) => [
                        Text(area.name, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                        Text('${area.completedSteps}/${area.totalSteps}', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12)),
                        _buildStatusChip(area.status, _getStatusColor(area.status)),
                        Text(area.priority, style: GoogleFonts.outfit(color: _getPriorityColor(area.priority), fontWeight: FontWeight.bold, fontSize: 12)),
                      ]).toList(),
                    ),

                    const SizedBox(height: 32),
                    // Buttons
                    Row(
                      children: [
                        Expanded(
                          child: NeonButton(
                            text: 'Ver Mi Ruta',
                            onTap: () => context.go(AppRoutes.laRutaAlExito),
                            primary: true, 
                            icon: Icons.map,
                            color: kNeonBlue,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: NeonButton(
                            text: 'Recomendaciones',
                            onTap: () => _showRecommendationsSheet(context),
                            primary: false, 
                            icon: Icons.lightbulb,
                            color: kNeonViolet,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    
                    // Next Steps Card
                    NeonWideCard(
                      borderColor: kNeonPurple,
                      isPremium: true, 
                      child: Column(
                        children: [
                          Icon(Icons.auto_awesome, color: kNeonPurple, size: 32, shadows: [BoxShadow(color: kNeonPurple.withOpacity(0.5), blurRadius: 10)]),
                          const SizedBox(height: 12),
                          Text(
                            'Auditoría progresiva (semi-IA)',
                            style: GoogleFonts.outfit(
                              color: kNeonPurple,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Esta auditoría se actualiza automáticamente con tu avance en La Ruta del Éxito.',
                            style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  Widget _buildStatusChip(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.circle, size: 6, color: color, shadows: [BoxShadow(color: color.withOpacity(0.5), blurRadius: 4)]),
        const SizedBox(width: 4),
        Text(label, style: GoogleFonts.outfit(color: color, fontSize: 11, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Completado': return kNeonGreen;
      case 'En proceso': return Colors.orange;
      default: return kNeonRed;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'Alta': return kNeonRed;
      case 'Media': return Colors.orange;
      default: return Colors.white54;
    }
  }

  void _showRecommendationsSheet(BuildContext context) async {
    // Show loading or just wait
    final List<AuditRecommendation> recs = [];
    for (var area in _areas) {
      final rec = await _service.getRecommendationsForArea(area.name);
      if (rec != null) recs.add(rec);
    }

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0F1520),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (_, scrollController) => Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.lightbulb, color: kNeonViolet),
                  const SizedBox(width: 12),
                  Text('Recomendaciones PRO', style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Basadas en tu progreso actual en La Ruta',
                style: GoogleFonts.outfit(color: Colors.white54, fontSize: 13),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: recs.length,
                  itemBuilder: (ctx, i) => _buildRecItem(recs[i]),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: NeonButton(text: 'Cerrar', onTap: () => Navigator.pop(context), primary: true, color: kNeonViolet),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecItem(AuditRecommendation rec) {
    final bool isCompleted = rec.title.contains('✅');
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isCompleted ? kNeonGreen.withOpacity(0.3) : Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(rec.area.toUpperCase(), style: GoogleFonts.outfit(color: kNeonViolet, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              if (!isCompleted)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: kNeonPurple.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                  child: Text('Fase ${rec.phase}', style: GoogleFonts.outfit(color: kNeonPurple, fontSize: 9, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(rec.title, style: GoogleFonts.outfit(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(rec.description, style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13)),
          if (rec.toolLabel != null) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                // Navigation logic if needed, or just a toast
              },
              child: Row(
                children: [
                  const Icon(Icons.arrow_forward_ios, size: 12, color: kNeonBlue),
                  const SizedBox(width: 4),
                  Text(rec.toolLabel!, style: GoogleFonts.outfit(color: kNeonBlue, fontSize: 13, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
