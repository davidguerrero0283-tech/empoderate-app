import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PremiumNegocioIntroCard extends StatelessWidget {
  const PremiumNegocioIntroCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Premium Styles - Consistent with Negocio Module
    final Color glassBg = const Color(0xFF151C2B).withOpacity(0.40);
    final Color goldBorder = const Color(0xFFD4AF37).withOpacity(0.35); // Stronger opacity as requested
    const Color goldText = Color(0xFFD4AF37);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: glassBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: goldBorder, width: 1.25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row with Icon
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: goldText.withOpacity(0.1),
                ),
                child: const Icon(Icons.shield_outlined, color: goldText, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'El 80% del camino empieza por formalizar',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Antes de invertir fuerte, asegúrate de estar en regla. Formalizar te abre puertas y evita bloqueos.',
                      style: GoogleFonts.outfit(
                        color: Colors.white70,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Bullets
          _buildBullet('Evitas multas y cierres inesperados'),
          const SizedBox(height: 6),
          _buildBullet('Puedes facturar y trabajar con empresas'),
          const SizedBox(height: 6),
          _buildBullet('Accedes a banco, proveedores y crecimiento'),
        ],
      ),
    );
  }

  Widget _buildBullet(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 6),
          child: Icon(Icons.circle, size: 6, color: Color(0xFFD4AF37)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.outfit(
              color: Colors.white60,
              fontSize: 13,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}
