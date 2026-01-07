import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../ui/theme/empoderate_theme.dart';
import '../components/premium_scaffold.dart';
import '../components/neon_widgets.dart';
import '../config/features.dart';

class TiendaPremiumScreen extends StatelessWidget {
  const TiendaPremiumScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Feature Flag: Hide Store if disabled
    if (!AppFeatures.premiumStoreEnabled) {
      return PremiumScaffold(
        title: 'TIENDA PREMIUM',
        showBackButton: true,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.stars, size: 60, color: Colors.white24),
              const SizedBox(height: 16),
              Text(
                'Disponible Próximamente',
                style: GoogleFonts.outfit(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                'Estamos preparando los mejores planes para ti.',
                style: GoogleFonts.outfit(color: Colors.white54, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return PremiumScaffold(
      title: 'Tienda Premium',
      showBackButton: true,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header
              const Icon(Icons.workspace_premium, color: Color(0xFFD4AF37), size: 60),
              const SizedBox(height: 16),
              Text(
                'Desbloquea el Poder Total',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Accede a herramientas avanzadas, IA ilimitada y soporte prioritario.',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 32),

              // Free Plan Card
              _buildPlanCard(
                context,
                title: 'Plan Gratuito',
                price: 'GRATIS',
                features: [
                  'Acceso básico a calculadoras',
                  'Ruta del Emprendedor (Limitada)',
                  'Misiones Diarias',
                  'Comunidad Empodérate',
                ],
                isPremium: false,
              ),

              const SizedBox(height: 24),

              // Premium Plan Card
              _buildPlanCard(
                context,
                title: 'Plan PRO',
                price: '\$9.99 / mes',
                features: [
                  'Todas las calculadoras PRO',
                  'Asistentes de IA Ilimitados',
                  'Generador de Contratos y Docs',
                  'Bóveda Digital (50GB)',
                  'Soporte Prioritario',
                  'Ruta del Éxito Completa',
                ],
                isPremium: true,
                onTap: () => _showMockPayment(context),
              ),

              const SizedBox(height: 40),
              
              Text(
                '¿Tienes dudas? Contáctanos',
                style: GoogleFonts.outfit(color: Colors.white30, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlanCard(BuildContext context, {
    required String title,
    required String price,
    required List<String> features,
    required bool isPremium,
    VoidCallback? onTap,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isPremium ? const Color(0xFF131A2A) : const Color(0xFF0B1220),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isPremium ? const Color(0xFFD4AF37) : Colors.white10,
          width: isPremium ? 2 : 1,
        ),
        boxShadow: isPremium 
          ? [BoxShadow(color: const Color(0xFFD4AF37).withOpacity(0.2), blurRadius: 20, spreadRadius: 0)]
          : [],
      ),
      child: Column(
        children: [
          if (isPremium)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFD4AF37),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'RECOMENDADO',
                style: GoogleFonts.outfit(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          
          Text(
            title,
            style: GoogleFonts.outfit(
              color: isPremium ? const Color(0xFFD4AF37) : Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            price,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          ...features.map((f) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Icon(
                   isPremium ? Icons.check_circle : (f.contains('Limitada') ? Icons.info_outline : Icons.check),
                   color: isPremium ? const Color(0xFFD4AF37) : Colors.white38,
                   size: 20
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    f,
                    style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14),
                  ),
                ),
              ],
            ),
          )).toList(),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: isPremium ? const Color(0xFFD4AF37) : Colors.white10,
                foregroundColor: isPremium ? Colors.black : Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                isPremium ? 'OBTENER PRO' : 'PLAN ACTUAL',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMockPayment(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: const Color(0xFF0F1520),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 60),
              const SizedBox(height: 16),
              Text(
                '¡Suscripción Exitosa!',
                style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Ahora eres usuario PRO. Disfruta de todas las herramientas.',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(color: Colors.white70),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37)),
                child: const Text('Comenzar', style: TextStyle(color: Colors.black)),
              )
            ],
          ),
        ),
      ),
    );
  }
}
