import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../calculators/salario_models.dart';
import '../../features/payroll/domain/payroll_record.dart';
import '../../ui/theme/empoderate_theme.dart';
import 'hr_dashboard_widgets.dart'; // Reuse HrGlassContainer

class WorkerAnnualSummary extends StatelessWidget {
  final List<PayrollRecord> history;

  const WorkerAnnualSummary({Key? key, required this.history}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final thisYear = now.year;
    
    // Filter for current year
    final yearRecords = history.where((r) => r.createdAt.year == thisYear).toList();
    
    double totalGross = 0;
    double totalNet = 0;
    double totalDeductions = 0;
    
    for (var r in yearRecords) {
      totalGross += r.grossSalary;
      totalNet += r.netSalary;
      totalDeductions += (r.grossSalary - r.netSalary); // Approx if deduction not explicit
      // If we had totalDeductions in PayrollRecord, use it. 
      // PayrollRecord has 'totalDeductions' via inputSnapshot if available, or calc.
      // But let's stick to simple gross - net for now if totalDeductions field isn't direct.
      // Wait, PayrollRecord defines: netSalary, grossSalary. 
      // Diff = Deductions.
    }

    return HrGlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'RESUMEN ANUAL $thisYear',
            style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12, letterSpacing: 1.2, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildSummaryItem('Devengado', totalGross, const Color(0xFFD4AF37))),
              Container(width: 1, height: 40, color: Colors.white10),
              Expanded(child: _buildSummaryItem('Deducciones', totalDeductions, Colors.pinkAccent)),
              Container(width: 1, height: 40, color: Colors.white10),
              Expanded(child: _buildSummaryItem('Neto Recibido', totalNet, const Color(0xFF00E676))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, double value, Color color) {
    return Column(
      children: [
        Text(
          '\$${_formatValue(value)}',
          style: GoogleFonts.outfit(color: color, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.outfit(color: Colors.white38, fontSize: 10),
        ),
      ],
    );
  }
  
  String _formatValue(double v) {
    if (v >= 10000) return '${(v/1000).toStringAsFixed(1)}k';
    return v.toStringAsFixed(0);
  }
}

class SalaryHistoryChart extends StatelessWidget {
  final List<PayrollRecord> history;

  const SalaryHistoryChart({Key? key, required this.history}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 1. Prepare Data
    // Sort by date ascending
    final sorted = List<PayrollRecord>.from(history)..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    
    // Take last 6-12 items to avoid overcrowding
    final data = sorted.length > 12 ? sorted.sublist(sorted.length - 12) : sorted;
    
    if (data.isEmpty) return const SizedBox.shrink();

    // 2. Map to Spots
    List<FlSpot> spots = [];
    double maxY = 0;
    for (int i = 0; i < data.length; i++) {
      final y = data[i].netSalary;
      if (y > maxY) maxY = y;
      spots.add(FlSpot(i.toDouble(), y));
    }
    
    // Add buffer to maxY
    maxY = maxY * 1.2;

    return HrGlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('TENDENCIA SALARIAL', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
              Icon(Icons.show_chart, color: Colors.blueAccent.withOpacity(0.5), size: 16),
            ],
          ),
          const SizedBox(height: 24),
          AspectRatio(
            aspectRatio: 1.7,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(color: Colors.white10, strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1, // Ensure distinct logic if sparse
                      getTitlesWidget: (value, meta) {
                        int index = value.toInt();
                        if (index >= 0 && index < data.length) {
                           // Show label e.g. "JAN" or period ID
                           // Use periodLabel but short
                           // E.g. "01/15" -> "15 Jan"
                           final d = data[index].createdAt;
                           return Padding(
                             padding: const EdgeInsets.only(top: 8.0),
                             child: Text(
                               '${d.day}/${d.month}', 
                               style: GoogleFonts.outfit(color: Colors.white30, fontSize: 10)
                             ),
                           );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (data.length - 1).toDouble(),
                minY: 0,
                maxY: maxY,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    gradient: const LinearGradient(colors: [Color(0xFF00E676), Color(0xFF00E5FF)]),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [const Color(0xFF00E676).withOpacity(0.2), const Color(0xFF00E5FF).withOpacity(0.0)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
