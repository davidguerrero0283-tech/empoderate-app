import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'neon_widgets.dart';

class PremiumTablePlaceholder extends StatelessWidget {
  const PremiumTablePlaceholder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NeonTable(
      headers: const ['Dato A', 'Dato B', 'Estado'],
      accentColor: kNeonGold,
      rows: [
        [Text('Ejemplo 1', style: GoogleFonts.outfit(color: Colors.white70)), Text('Valor X', style: GoogleFonts.outfit(color: Colors.white70)), Icon(Icons.check_circle, color: kNeonGreen, size: 16)],
        [Text('Ejemplo 2', style: GoogleFonts.outfit(color: Colors.white70)), Text('Valor Y', style: GoogleFonts.outfit(color: Colors.white70)), Icon(Icons.pending, color: Colors.orange, size: 16)],
        [Text('Ejemplo 3', style: GoogleFonts.outfit(color: Colors.white70)), Text('Valor Z', style: GoogleFonts.outfit(color: Colors.white70)), Icon(Icons.error, color: kNeonRed, size: 16)],
      ],
    );
  }
}

class PremiumChartPlaceholder extends StatelessWidget {
  const PremiumChartPlaceholder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF003366).withOpacity(0.3),
            Colors.black.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFD4AF37).withOpacity(0.2),
          width: 0.5,
        ),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.insert_chart,
              color: const Color(0xFFD4AF37).withOpacity(0.5), size: 40),
          const SizedBox(height: 8),
          Text(
            'Análisis gráfico interactivo',
            style: GoogleFonts.outfit(
              color: Colors.white54,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
