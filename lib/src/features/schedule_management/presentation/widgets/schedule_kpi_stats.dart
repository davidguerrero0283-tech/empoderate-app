import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_empoderate/src/features/schedule_management/logic/schedule_controller.dart';

class ScheduleKPIStats extends StatelessWidget {
  const ScheduleKPIStats({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Connect to Controller
    final controller = Provider.of<ScheduleController>(context);
    final totalHours = controller.totalWeeklyHours;
    final cost = controller.projectedCost;
    final conflicts = controller.conflictCount;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('📊 Métricas de Operación', style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildMetricTile('Horas Totales', '${totalHours.toStringAsFixed(1)}h', Icons.timer, Colors.blue)),
              const SizedBox(width: 8),
              Expanded(child: _buildMetricTile('Costo Est.', '\$${cost.toStringAsFixed(2)}', Icons.attach_money, Colors.green)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildMetricTile(
                'Conflictos', 
                '$conflicts', 
                Icons.warning_amber_rounded, 
                conflicts > 0 ? Colors.redAccent : Colors.orange,
                onTap: conflicts > 0 ? () => _showComplianceDialog(context, controller) : null,
              )),
              const SizedBox(width: 8),
              Expanded(child: Builder(
                builder: (context) {
                  final analytics = controller.getAnalytics();
                  final efficiency = analytics.efficiencyScore;
                  return _buildMetricTile(
                    'Eficiencia', 
                    '${efficiency.toStringAsFixed(0)}%', 
                    Icons.speed, 
                    efficiency >= 80 ? Colors.green : (efficiency >= 50 ? Colors.amber : Colors.redAccent),
                  );
                },
              )),
            ],
          ),
        ],
      ),
    );
  }

  void _showComplianceDialog(BuildContext context, ScheduleController controller) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Alertas de Cumplimiento'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: controller.complianceIssues.length,
            itemBuilder: (context, index) {
              final issue = controller.complianceIssues[index];
              return ListTile(
                leading: Icon(Icons.error_outline, color: Colors.redAccent),
                title: Text(issue.title),
                subtitle: Text('${issue.workerName}: ${issue.description}'),
                trailing: Text(issue.article, style: const TextStyle(fontSize: 10)),
              );
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cerrar'))
        ],
      ),
    );
  }

  Widget _buildMetricTile(String label, String value, IconData icon, Color color, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black26,
          borderRadius: BorderRadius.circular(8),
          border: onTap != null ? Border.all(color: color.withOpacity(0.5)) : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                Text(label, style: GoogleFonts.outfit(color: Colors.white54, fontSize: 11)),
              ],
            )
          ],
        ),
      ),
    );
  }
}
