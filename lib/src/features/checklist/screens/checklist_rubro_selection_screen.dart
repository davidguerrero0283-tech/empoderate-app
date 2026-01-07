import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_empoderate/src/components/premium_scaffold.dart';
import 'package:proyecto_empoderate/src/navigation/app_routes.dart';
import 'package:proyecto_empoderate/ui/theme/empoderate_theme.dart';

class ChecklistRubroSelectionScreen extends StatelessWidget {
  const ChecklistRubroSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      title: 'SELECCIONA TU RUBRO',
      isNeonTitle: true,
      showBackButton: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Encuentra los requisitos específicos para tu tipo de negocio.',
              style: GoogleFonts.outfit(color: Colors.white70, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _buildRubroCard(context, 'Restaurante / Comida', Icons.restaurant, 'restaurante', Colors.orangeAccent),
            _buildRubroCard(context, 'Tienda / Retail', Icons.store, 'retail', Colors.blueAccent),
            _buildRubroCard(context, 'Servicios Profesionales', Icons.work, 'servicios', Colors.purpleAccent),
            _buildRubroCard(context, 'Construcción / Otros', Icons.construction, 'otros', Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildRubroCard(BuildContext context, String title, IconData icon, String rubroId, Color accentColor) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context, 
          AppRoutes.checklistRubroDetail, 
          arguments: {'rubroId': rubroId, 'title': title}
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: EmpoderateTheme.premiumGlassCard, // Standard Premium Look
        child: Row(
          children: [
            Container(
               padding: const EdgeInsets.all(12),
               decoration: EmpoderateTheme.safeBoxDecoration(
                 color: accentColor.withOpacity(0.1), 
                 shape: BoxShape.circle,
                 border: Border.all(color: accentColor.withOpacity(0.3))
               ),
               child: Icon(icon, color: accentColor, size: 28),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                title, 
                style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 16),
          ],
        ),
      ),
    );
  }
}
