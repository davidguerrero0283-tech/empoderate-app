import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EmpoderaLineChart extends StatelessWidget {
  const EmpoderaLineChart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(0, 0, 0, 0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Evolución Mensual',
            style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: CustomPaint(
              painter: _MockLineChartPainter(),
              size: Size.infinite,
            ),
          ),
        ],
      ),
    );
  }
}

class _MockLineChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD4AF37)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(0, size.height * 0.8);
    path.quadraticBezierTo(size.width * 0.25, size.height * 0.6, size.width * 0.5, size.height * 0.4);
    path.quadraticBezierTo(size.width * 0.75, size.height * 0.5, size.width, size.height * 0.2);

    canvas.drawPath(path, paint);

    // Draw dots
    final dotPaint = Paint()..color = const Color(0xFFD4AF37);
    canvas.drawCircle(Offset(0, size.height * 0.8), 4, dotPaint);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.4), 4, dotPaint);
    canvas.drawCircle(Offset(size.width, size.height * 0.2), 4, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class EmpoderaBarChart extends StatelessWidget {
  const EmpoderaBarChart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(0, 0, 0, 0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildBar(context, 0.4, 'Ene'),
          _buildBar(context, 0.6, 'Feb'),
          _buildBar(context, 0.8, 'Mar'),
          _buildBar(context, 0.5, 'Abr'),
          _buildBar(context, 0.9, 'May'),
        ],
      ),
    );
  }

  Widget _buildBar(BuildContext context, double heightFactor, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 20,
          height: 120 * heightFactor,
          decoration: BoxDecoration(
            color: const Color(0xFFD4AF37),
            borderRadius: BorderRadius.circular(4),
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                const Color(0xFFD4AF37).withOpacity(0.5),
                const Color(0xFFD4AF37),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.outfit(color: Colors.white70, fontSize: 10),
        ),
      ],
    );
  }
}

class EmpoderaDonutChart extends StatelessWidget {
  const EmpoderaDonutChart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(0, 0, 0, 0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: CustomPaint(
              painter: _MockDonutChartPainter(),
              size: Size.infinite,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLegendItem(const Color(0xFFD4AF37), 'Categoría A'),
              _buildLegendItem(Colors.white30, 'Categoría B'),
              _buildLegendItem(Colors.white12, 'Categoría C'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(width: 12, height: 12, color: color),
          const SizedBox(width: 8),
          Text(label, style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }
}

class _MockDonutChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width < size.height ? size.width / 2 : size.height / 2;
    final strokeWidth = 20.0;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    // Segment 1
    paint.color = const Color(0xFFD4AF37);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius - strokeWidth), -1.5, 3, false, paint);

    // Segment 2
    paint.color = Colors.white30;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius - strokeWidth), 1.6, 2, false, paint);

    // Segment 3
    paint.color = Colors.white12;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius - strokeWidth), 3.7, 1, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
