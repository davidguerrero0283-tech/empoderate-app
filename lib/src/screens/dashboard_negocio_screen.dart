import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../components/premium_scaffold.dart';
import '../components/premium_cards.dart'; // Using Styles A & B
import '../navigation/app_routes.dart';

class DashboardNegocioScreen extends StatelessWidget {
  const DashboardNegocioScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      title: 'DASHBOARD DE PROGRESO',
      showBackButton: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tu resumen general como emprendedor.',
            style: GoogleFonts.outfit(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),
          
          // BLOCK 1: Progreso de la Ruta (Style B)
          _buildRouteProgressBlock(context),
          const SizedBox(height: 16),
          
          // BLOCK 2: Misiones del Día (Style A)
          _buildSectionTitle('Misiones'),
          const SizedBox(height: 12),
          ComponenteTarjetaPremium(
            icon: Icons.track_changes,
            title: 'Misiones del Día',
            subtitle: 'Tu misión actual: Registra 3 ventas nuevas.', // Placeholder
            onTap: () => Navigator.pushNamed(context, AppRoutes.misionesDiarias),
            iconColor: Colors.redAccent,
          ),
          
          // BLOCK 3: Misiones Semanales (Style A)
          ComponenteTarjetaPremium(
            icon: Icons.emoji_events,
            title: 'Misiones Semanales',
            subtitle: 'Objetivo: Completa el módulo de Finanzas.', // Placeholder
            onTap: () => Navigator.pushNamed(context, AppRoutes.misionesDiarias),
            iconColor: Colors.amber,
          ),
          const SizedBox(height: 16),
          
          // BLOCK 4: Actividad Reciente (Style A)
          _buildSectionTitle('Actividad'),
          const SizedBox(height: 12),
          Container( // Custom container to group list items visually if needed, or just list cards
            child: Column(
              children: [
                ComponenteTarjetaPremium(
                  icon: Icons.check_circle_outline,
                  title: 'Actividad Reciente',
                  subtitle: '• Completaste el Paso 2 de Fase 1\n• Leíste: ¿Cómo poner precios?',
                  onTap: () {}, // Could navigate to history if exists
                  iconColor: Colors.blueAccent,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // BLOCK 5: Logros (Style A)
          _buildSectionTitle('Logros'),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, AppRoutes.laRutaAlExito),
            child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(255, 255, 255, 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.stars, color: Color(0xFFD4AF37), size: 24),
                        const SizedBox(width: 16),
                        Text(
                          'Logros Obtenidos',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Reconocimientos por tu avance',
                      style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: const [
                        Icon(Icons.workspace_premium, color: Color(0xFFC0C0C0), size: 36), // Silver
                        Icon(Icons.workspace_premium, color: Color(0xFFD4AF37), size: 48), // Gold
                        Icon(Icons.workspace_premium, color: Color(0xFFCD7F32), size: 36), // Bronze
                      ],
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        'Ver todos los logros',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFD4AF37),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildRouteProgressBlock(BuildContext context) {
    // Customizing ComponenteTarjetaPrincipal for Progress Block special layout or using it directly
    // The prompt asks for title, subtitle, progress bar, etc.
    // ComponenteTarjetaPrincipal mainly has Icon, Title, Subtitle.
    // I'll build a custom "Style B" card here to fit the specific "Progress Bar" requirement if ComponenteTarjetaPrincipal doesn't fit perfectly.
    // Or simpler: Use ComponenteTarjetaPrincipal and wrap it? No, Style B is generally "The Big Card".
    // I will implement a custom widget that LOOKS like Style B but includes the stats requested.
    
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.rutaEmprendedor),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(255, 255, 255, 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.5), width: 1.5),
          boxShadow: [
             BoxShadow(
              color: const Color(0xFFD4AF37).withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.map, color: Color(0xFFD4AF37), size: 30),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ruta del Emprendedor',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Fase actual: Fase 1 (Legalizar)',
                        style: GoogleFonts.outfit(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Progress Bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Progreso', style: GoogleFonts.outfit(color: Colors.white, fontSize: 12)),
                    Text('3/10 pasos', style: GoogleFonts.outfit(color: const Color(0xFFD4AF37), fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: 0.3,
                    minHeight: 8,
                    backgroundColor: Colors.white10,
                    color: const Color(0xFFD4AF37),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.rutaEmprendedor),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFD4AF37),
                  side: const BorderSide(color: Color(0xFFD4AF37)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: Text(
                  'Ver Ruta Completa',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
