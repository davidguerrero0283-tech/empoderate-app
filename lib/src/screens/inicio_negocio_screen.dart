import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../components/premium_scaffold.dart';
import '../components/neon_widgets.dart';
import '../navigation/app_routes.dart';

class InicioNegocioScreen extends StatelessWidget {
  const InicioNegocioScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Specific Palette for Accents
    final Color mainColor = const Color(0xFF00E5FF); // Cyan Neon
    final Color secondaryColor = const Color(0xFF80D8FF); // Soft Light Blue
    final Color silverColor = const Color(0xFFB0BEC5); // Blue Grey Silver

    return PremiumScaffold(
      title: 'Inicia tu Negocio',
      // backgroundGradient: removed to use global

      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              
              // 1. Featured Guide Card (Styled as NeonWideCard)
              GestureDetector(
                onTap: () {
                   ScaffoldMessenger.of(context).showSnackBar(
                     const SnackBar(content: Text('Guía detallada próximamente.')),
                   );
                },
                child: NeonWideCard(
                  borderColor: mainColor,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle, 
                          color: mainColor.withOpacity(0.1), 
                          border: Border.all(color: mainColor.withOpacity(0.5)),
                          boxShadow: [BoxShadow(color: mainColor.withOpacity(0.2), blurRadius: 8)],
                        ),
                        child: const Icon(Icons.star, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Guía Rápida', 
                              style: GoogleFonts.outfit(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)
                            ),
                            const SizedBox(height: 4),
                            Text('Pasos clave para lanzar tu empresa.', 
                              style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13)
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // 2. Neon Grid (Steps)
              NeonSectionTitle(title: 'Pasos Esenciales', color: mainColor),
              const SizedBox(height: 24),
              
              LayoutBuilder(
                 builder: (context, constraints) {
                   double spacing = 16;
                   double itemWidth = (constraints.maxWidth - spacing) / 2;
                   return Wrap(
                     spacing: spacing,
                     runSpacing: spacing,
                     children: [
                       SizedBox(width: itemWidth, child: 
                          NeonGridCard(
                            title: '1. Formalización', subtitle: 'Legal y registro', 
                            icon: Icons.gavel_outlined, 
                            neonColor: mainColor,
                            onTap: (){},
                          )
                       ),
                       SizedBox(width: itemWidth, child: 
                          NeonGridCard(
                            title: '2. Trámites', subtitle: 'Permisos clave', 
                            icon: Icons.assignment_outlined, 
                            neonColor: secondaryColor,
                            onTap: (){},
                          )
                       ),
                       SizedBox(width: itemWidth, child: 
                          NeonGridCard(
                            title: '3. Obligaciones', subtitle: 'Fiscales', 
                            icon: Icons.account_balance_outlined, 
                            neonColor: const Color(0xFF82B1FF), // Blue Accent
                            onTap: (){},
                          )
                       ),
                       SizedBox(width: itemWidth, child: 
                          NeonGridCard(
                            title: '4. Marketing', subtitle: 'Lanzamiento', 
                            icon: Icons.campaign_outlined, 
                            neonColor: const Color(0xFFEA80FC), // Purple Accent (Touch of color)
                            onTap: (){},
                          )
                       ),
                     ],
                   );
                 }
              ),

              const SizedBox(height: 32),
              
              // 3. Extended Content
              NeonWideCard(
                borderColor: secondaryColor,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                           Icon(Icons.tips_and_updates_outlined, color: secondaryColor, size: 30, shadows: [BoxShadow(color: secondaryColor.withOpacity(0.6), blurRadius: 8)]),
                           const SizedBox(width: 12),
                           Expanded(
                             child: Text(
                               '¿Por qué formalizar?', 
                               style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)
                             ),
                           ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'El 80% de los negocios informales no superan los 2 años. Formalizarte te abre puertas a créditos bancarios, contratos con el estado y mayor confianza de tus clientes. Sigue los pasos arriba para iniciar correctamente.',
                        style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14, height: 1.6),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}
