import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PremiumNegocioAccordionCard extends StatefulWidget {
  const PremiumNegocioAccordionCard({Key? key}) : super(key: key);

  @override
  State<PremiumNegocioAccordionCard> createState() => _PremiumNegocioAccordionCardState();
}

class _PremiumNegocioAccordionCardState extends State<PremiumNegocioAccordionCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    // 🎨 PALETTE
    // Base: Glass Dark (slightly more transparent to let pink shine)
    final Color glassBg = const Color(0xFF151C2B).withOpacity(0.75); 
    // Overlay: Pale Pink (#F6D6E6) - FORCE VISIBILITY (20%)
    final Color pinkOverlay = const Color(0xFFF6D6E6).withOpacity(0.20); 
    // Border: Gold Neon Sutil
    final Color goldBorder = const Color(0xFFD4AF37).withOpacity(0.6); 
    const Color goldText = Color(0xFFD4AF37);
    
    // Action Button: Flat Yellow (#E2C15A)
    const Color yellowButton = Color(0xFFE2C15A);
    const Color navyText = Color(0xFF0F1520);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: double.infinity,
      decoration: BoxDecoration(
        color: glassBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: goldBorder, width: 1.5),
        boxShadow: [
          // Neon Glow Sutil
          BoxShadow(
            color: goldText.withOpacity(0.2),
            blurRadius: 16,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Pink Tint Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: pinkOverlay,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- CARD HEADER (Title + Brief + Action Button) ---
              Padding(
                padding: const EdgeInsets.all(22), // Slightly more padding
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Row: Icon + Title
                    Row(
                      children: [
                        const Icon(Icons.shield_outlined, color: goldText, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '¿Por qué formalizarse?',
                            style: GoogleFonts.outfit(
                              color: goldText,
                              fontSize: 20, // Larger
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                              shadows: [
                                BoxShadow(color: goldText.withOpacity(0.4), blurRadius: 10) // Neon Sutil Glow
                              ]
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Main Text Paragraph 1
                    Text(
                      'Muchas empresas fracasan por no formalizar a tiempo: permisos, registros y obligaciones.',
                      style: GoogleFonts.outfit(
                        color: Colors.white, // Pure White
                        fontSize: 15, 
                        height: 1.5
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Main Text Paragraph 2
                    Text(
                      'Una gran parte de los cierres temporales ocurren por operar sin bases legales y sin orden.',
                      style: GoogleFonts.outfit(
                         color: Colors.white, // Pure White
                         fontSize: 15, 
                         height: 1.5
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Subtitle
                    Text(
                      'Beneficios de legalizarse:',
                      style: GoogleFonts.outfit(
                        color: Colors.white, // Or soft gold, keeping white for clarity as requested
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Benefits Bullets
                    _buildBullet('Evita multas y cierres por permisos.'),
                    _buildBullet('Puedes facturar y trabajar con empresas.'),
                    _buildBullet('Accede a bancos y proveedores.'),
                    _buildBullet('Protege tu marca e inversión.'),

                    const SizedBox(height: 24),

                    // --- ACTION BUTTON (Yellow Flat Pill) ---
                    // Toggle Expansion
                    GestureDetector(
                      onTap: () {
                         setState(() {
                           _isExpanded = !_isExpanded;
                         });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        decoration: BoxDecoration(
                          color: yellowButton, // Flat Yellow
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _isExpanded ? 'MENOS INFORMACIÓN' : 'INFÓRMATE',
                              style: GoogleFonts.outfit(
                                color: navyText, 
                                fontWeight: FontWeight.bold, 
                                fontSize: 13,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, 
                              color: navyText, 
                              size: 18
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // --- EXPANDED SECTION (Accordion) ---
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(22, 0, 22, 22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(color: Colors.white12, height: 24),
                      Text(
                        '¿Cómo usar esta sección?',
                        style: GoogleFonts.outfit(color: goldText, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 12),
                       _buildStep(1, 'Elige tu rubro (industria) según tu idea.'),
                       _buildStep(2, 'Selecciona tu modelo de negocio.'),
                       _buildStep(3, 'Revisa los requisitos por secciones (legales, permisos, etc.).'),
                       _buildStep(4, 'Toca cada requisito para ver detalles y enlaces.'),
                       _buildStep(5, 'Marca lo que ya completaste.'),
                       
                       const SizedBox(height: 16),
                       Text(
                         'Guía informativa. Verifica siempre en fuentes oficiales.',
                         style: GoogleFonts.outfit(color: Colors.white54, fontSize: 13, fontStyle: FontStyle.italic),
                       ),
                    ],
                  ),
                ),
                crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 300),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8), // Increased spacing
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Icon(Icons.check, size: 14, color: Color(0xFFD4AF37)), 
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text, 
              style: GoogleFonts.outfit(
                color: Colors.white, // Pure White
                fontSize: 14, // Larger
                height: 1.4
              )
            )
          ),
        ],
      ),
    );
  }
  
  Widget _buildStep(int num, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
             width: 20, height: 20,
             decoration: BoxDecoration(color: Colors.white10, shape: BoxShape.circle),
             child: Center(child: Text('$num', style: GoogleFonts.outfit(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13))),
        ],
      ),
    );
  }
}
