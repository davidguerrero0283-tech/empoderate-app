import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../components/neon_widgets.dart';
import '../../../navigation/app_routes.dart';
import 'hr_compliance_service.dart';
import 'hr_compliance_service.dart';

class HrComplianceSummaryCard extends StatefulWidget {
  const HrComplianceSummaryCard({Key? key}) : super(key: key);

  @override
  State<HrComplianceSummaryCard> createState() => _HrComplianceSummaryCardState();
}

class _HrComplianceSummaryCardState extends State<HrComplianceSummaryCard> {
  Map<String, dynamic>? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final stats = await HrComplianceService().getDashboardSummary();
    if (mounted) {
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine status text
    String statusText = "Cargando...";
    if (!_isLoading && _stats != null) {
      if (_stats!['total'] == 0) {
        statusText = "Aún sin registros. Configura obligaciones para comenzar.";
      } else {
        statusText = "Este mes: ${_stats!['total']} total | ${_stats!['compliance'] != null ? ((_stats!['compliance'] as double) * _stats!['total']).toInt() : 0} cumplidas | ${_stats!['overdue']} vencidas";
      }
    }

    return NeonWideCard(
      borderColor: const Color(0xFFFF4081), // Neon Pink
      onTap: () async {
        // Navigate and reload stats when returning
        await context.push('/rrhh/cumplimiento');
        _loadStats();
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Title and Info Icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.pink.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.assignment_turned_in, color: Color(0xFFFF4081), size: 20),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Obligaciones Laborales', style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        Text('Cumplimiento 360°', style: GoogleFonts.outfit(color: Colors.white54, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.info_outline, color: Colors.white38, size: 20),
                  tooltip: 'Ver origen de datos',
                  onPressed: () {
                    // Show origin info dialog or simple tooltip
                    showDialog(context: context, builder: (_) => AlertDialog(
                       backgroundColor: const Color(0xFF1E1E24),
                       title: Text('Origen de Datos', style: GoogleFonts.outfit(color: Colors.white)),
                       content: Text('Los datos provienen del Código de Trabajo de Panamá y la configuración de tu negocio.', style: GoogleFonts.outfit(color: Colors.white70)),
                       actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('OK', style: GoogleFonts.outfit(color: Colors.pinkAccent)))],
                    ));
                  },
                )
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Didactic Bullets "Cómo funciona"
            _buildBullet('Configura tus obligaciones una sola vez.'),
            _buildBullet('Cada mes se generan tareas: Pendiente, Cumplida o Vencida.'),
            _buildBullet('Adjunta evidencia y mira el % de cumplimiento.'),
            
            const SizedBox(height: 12),
            
            // Status Text
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
              child: Text(
                statusText,
                style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12, fontStyle: FontStyle.italic),
              ),
            ),

            const SizedBox(height: 16),

            // Arrow indicator instead of button
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('GESTIONAR', style: GoogleFonts.outfit(color: const Color(0xFFFF4081), fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_ios, color: Color(0xFFFF4081), size: 14),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 4, right: 8),
            child: Icon(Icons.circle, size: 4, color: Color(0xFFFF4081)),
          ),
          Expanded(child: Text(text, style: GoogleFonts.outfit(color: Colors.white60, fontSize: 12))),
        ],
      ),
    );
  }
}
