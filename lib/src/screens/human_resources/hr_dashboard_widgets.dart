import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../ui/theme/empoderate_theme.dart';
import 'dart:math' as math;
import 'dart:ui';

// --- GLASS CONTAINER HELPER ---
class HrGlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  const HrGlassContainer({
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.only(bottom: 24),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: const Color(0xFF151C2B).withOpacity(0.4), // Reduced opacity for effective blur
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.15), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}

// --- PAYROLL DASHBOARD (RADIAL) ---
class PayrollDashboard extends StatelessWidget {
  final double netSalary;
  final double grossSalary;
  final double deductions;

  const PayrollDashboard({
    Key? key,
    required this.netSalary,
    required this.grossSalary,
    required this.deductions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Prevent division by zero
    final double total = grossSalary > 0 ? grossSalary : 1.0;
    final double netPercentage = (netSalary / total).clamp(0.0, 1.0);
    // Deductions is the rest usually, or specific value
    
    return Container(
      height: 140, // Height for dashboard area
      child: Row(
        children: [
          // 1. Radial Chart
          AspectRatio(
            aspectRatio: 1,
            child: CustomPaint(
              painter: _PayrollRadialPainter(
                netPercent: netPercentage,
                deductionPercent: (deductions / total).clamp(0.0, 1.0),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${(netPercentage * 100).toStringAsFixed(0)}%',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'NETO',
                      style: GoogleFonts.outfit(
                        color: Colors.white54,
                        fontSize: 10,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // 2. Stats Column
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 _buildStatRow('Salario Bruto', grossSalary, const Color(0xFFD4AF37)), // Gold
                 const SizedBox(height: 8),
                 _buildStatRow('Deducciones', -deductions, const Color(0xFFFF4081)), // Pink
                 const Divider(color: Colors.white24, height: 16),
                 _buildStatRow('Salario Neto', netSalary, const Color(0xFF00E676), isLarge: true), // Green
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, double value, Color color, {bool isLarge = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            color: Colors.white70,
            fontSize: isLarge ? 14 : 12,
            fontWeight: isLarge ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          '\$${value.abs().toStringAsFixed(2)}',
          style: GoogleFonts.outfit(
            color: color,
            fontSize: isLarge ? 18 : 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _PayrollRadialPainter extends CustomPainter {
  final double netPercent;
  final double deductionPercent;

  _PayrollRadialPainter({required this.netPercent, required this.deductionPercent});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 8;
    final strokeWidth = 10.0;

    final bgPaint = Paint()
      ..color = Colors.white10
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    final netPaint = Paint()
      ..color = const Color(0xFF00E676) // Green for money in pocket
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw Net Arc (Green)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // Start at top
      2 * math.pi * netPercent,
      false,
      netPaint,
    );

    // Draw Deduction Arc (Pink) - Visualization only, starts after net? Or separate?
    // Let's overlap slightly from the other side for cool effect, or just standard pie style
    // For "Deductions", standard UX is usually "taken away".
    // Let's draw deductions starting from top counter-clockwise to indicate "loss"
    
    final dedPaint = Paint()
      ..color = const Color(0xFFFF4081).withOpacity(0.7)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

     canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // Start at top
      -(2 * math.pi * deductionPercent), // Go backwards
      false,
      dedPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// --- LIQUIDACION DASHBOARD (RADIAL) ---
class LiquidacionDashboard extends StatelessWidget {
  final double totalLiquidacion;
  final double prestaciones; // Prima + Indemnizacion
  final double derechos; // Vacaciones + Decimo

  const LiquidacionDashboard({
    Key? key,
    required this.totalLiquidacion,
    required this.prestaciones,
    required this. derechos,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double safeTotal = totalLiquidacion > 0 ? totalLiquidacion : 1;
    
    return Container(
      height: 140,
      child: Row(
        children: [
          // Radial
          AspectRatio(
            aspectRatio: 1,
            child: CustomPaint(
              painter: _LiquidacionRadialPainter(
                prestacionesPercent: (prestaciones / safeTotal).clamp(0.0, 1.0),
                derechosPercent: (derechos / safeTotal).clamp(0.0, 1.0),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'TOTAL',
                      style: GoogleFonts.outfit(color: Colors.white54, fontSize: 10),
                    ),
                    Text(
                      totalLiquidacion > 999 
                        ? '${(totalLiquidacion/1000).toStringAsFixed(1)}k' 
                        : totalLiquidacion.toStringAsFixed(0),
                      style: GoogleFonts.outfit(
                        color: const Color(0xFFD4AF37),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Stats
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStatItem('Derechos Adquiridos', derechos, const Color(0xFF00E5FF)), // Cyan
                const SizedBox(height: 8),
                _buildStatItem('Prestaciones Laborales', prestaciones, const Color(0xFFFFAB40)), // Copper/Orange
                const SizedBox(height: 8),
                const Divider(color: Colors.white12, height: 8),
                Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   children: [
                      Text('Total a Recibir', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
                      Text('\$${totalLiquidacion.toStringAsFixed(2)}', style: GoogleFonts.outfit(color: const Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 16)),
                   ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, double value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Text(label, style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12))),
        Text('\$${value.toStringAsFixed(2)}', style: GoogleFonts.outfit(color: color, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _LiquidacionRadialPainter extends CustomPainter {
  final double prestacionesPercent;
  final double derechosPercent;

  _LiquidacionRadialPainter({required this.prestacionesPercent, required this.derechosPercent});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width/2, size.height/2);
    final radius = math.min(size.width, size.height)/2 - 8;
    final strokeWidth = 8.0;

    final bg = Paint()..color = Colors.white10..style = PaintingStyle.stroke..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, bg);

    // 1. Derechos (Cyan) - Starts at -90
    final p1 = Paint()..color = const Color(0xFF00E5FF)..style = PaintingStyle.stroke..strokeWidth = strokeWidth..strokeCap = StrokeCap.round;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -math.pi/2, 2*math.pi*derechosPercent, false, p1);

    // 2. Prestaciones (Orange) - Starts after Derechos
    final p2 = Paint()..color = const Color(0xFFFFAB40)..style = PaintingStyle.stroke..strokeWidth = strokeWidth..strokeCap = StrokeCap.round;
    // Gap of 0.1 rad
    double startAngle = -math.pi/2 + (2*math.pi*derechosPercent) + 0.1; 
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, 2*math.pi*prestacionesPercent, false, p2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
