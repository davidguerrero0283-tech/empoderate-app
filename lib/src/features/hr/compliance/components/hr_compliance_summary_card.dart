import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../hr_compliance_service.dart';
import '../../../../components/neon_widgets.dart';

class HrComplianceSummaryCard extends StatefulWidget {
  const HrComplianceSummaryCard({Key? key}) : super(key: key);

  @override
  State<HrComplianceSummaryCard> createState() => _HrComplianceSummaryCardState();
}

class _HrComplianceSummaryCardState extends State<HrComplianceSummaryCard> {
  Map<String, dynamic> _stats = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }
  
  // Expose reload option
  void reload() => _loadStats();

  Future<void> _loadStats() async {
    setState(() => _loading = true);
    final stats = await HrComplianceService().getDashboardSummary();
    if (mounted) {
      setState(() {
        _stats = stats;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: Colors.cyanAccent));
    }

    final compliance = _stats['compliance'] ?? 0.0;
    final score = (compliance * 100).round();
    final nextDeadline = _stats['next_deadline'] ?? 'Sin pendientes';
    final overdue = _stats['overdue'] ?? 0;
    final daysUntil = _stats['days_until'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
        boxShadow: [
          BoxShadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          // Graphic Score
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  value: compliance,
                  strokeWidth: 8,
                  backgroundColor: Colors.white10,
                  valueColor: AlwaysStoppedAnimation<Color>(_getColor(compliance)),
                ),
              ),
              Text(
                '$score%',
                style: GoogleFonts.outfit(
                  fontSize: 22, 
                  fontWeight: FontWeight.bold,
                  color: Colors.white
                ),
              )
            ],
          ),
          const SizedBox(width: 20),
          // Info Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Próximo Vencimiento',
                  style: GoogleFonts.outfit(fontSize: 12, color: Colors.white54),
                ),
                Text(
                  nextDeadline,
                  style: GoogleFonts.outfit(
                    fontSize: 18, 
                    fontWeight: FontWeight.w600, 
                    color: Colors.white
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _Badge(
                      label: overdue > 0 ? '$overdue Vencidos' : 'Al día',
                      color: overdue > 0 ? Colors.redAccent : Colors.greenAccent,
                    ),
                    const SizedBox(width: 8),
                    if (daysUntil > 0 && daysUntil < 10)
                       _Badge(
                          label: '$daysUntil días', 
                          color: Colors.orangeAccent
                       )
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Color _getColor(double val) {
    if (val < 0.5) return Colors.redAccent;
    if (val < 0.8) return Colors.orangeAccent;
    return Colors.greenAccent;
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: GoogleFonts.outfit(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w600
        ),
      ),
    );
  }
}
