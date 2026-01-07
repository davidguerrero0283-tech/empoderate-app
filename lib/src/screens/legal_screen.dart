import 'package:flutter/material.dart';
import '../components/premium_scaffold.dart';
import '../components/section_option_card.dart';
import '../components/premium_placeholders.dart';
import 'package:google_fonts/google_fonts.dart';
import 'legal_text_screen.dart';

class LegalScreen extends StatelessWidget {
  const LegalScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      title: 'Legal y Términos',
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Documentación legal y políticas de uso.',
              style: GoogleFonts.outfit(
                color: Colors.white.withOpacity(0.85),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            
            SectionOptionCard(
              icon: Icons.description,
              title: 'Términos y condiciones',
              subtitle: 'Reglas de uso de la aplicación',
              onTap: () {
                 Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LegalTextScreen(
                      title: 'Términos y condiciones', 
                      content: 'Términos y condiciones de ejemplo...\n\n1. Uso de la aplicación.\n2. Responsabilidades.',
                    ),
                  ),
                );
              },
            ),
            SectionOptionCard(
              icon: Icons.privacy_tip,
              title: 'Política de privacidad',
              subtitle: 'Uso y protección de datos',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LegalTextScreen(
                      title: 'Política de privacidad', 
                      content: 'Política de privacidad de ejemplo...\n\nProtegemos tus datos personales conforme a la ley.',
                    ),
                  ),
                );
              },
            ),
            SectionOptionCard(
              icon: Icons.copyright,
              title: 'Propiedad intelectual',
              subtitle: 'Derechos de autor y marcas',
              onTap: () {},
            ),

            const SizedBox(height: 24),
            Text(
              'Versión y Licencias',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            const PremiumTablePlaceholder(),
          ],
        ),
      ),
    );
  }
}
