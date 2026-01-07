import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../components/premium_scaffold.dart';
import '../../components/neon_widgets.dart';

class SalarioComingSoonScreen extends StatelessWidget {
  const SalarioComingSoonScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      title: 'CALCULADORA DE SALARIO',
      subtitle: 'En reconstrucción',
      showBackButton: true,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.construction,
                size: 100,
                color: kNeonCyan.withOpacity(0.5),
              ),
              const SizedBox(height: 32),
              Text(
                'Calculadora en Reconstrucción',
                style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Esta calculadora está siendo mejorada con un diseño moderno de dos columnas.',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              NeonButton(
                text: 'Ir a Calculadora de Liquidación',
                onTap: () => Navigator.pushNamed(context, '/liquidacion'),
                color: kNeonCyan,
                textColor: Colors.white,
                icon: Icons.arrow_forward,
              ),
              const SizedBox(height: 16),
              Text(
                'La calculadora de liquidación ya tiene el nuevo diseño',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: Colors.white38,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
