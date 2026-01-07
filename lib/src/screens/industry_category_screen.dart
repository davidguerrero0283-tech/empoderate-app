import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../ui/theme/empoderate_theme.dart';
import '../components/premium_scaffold.dart';
import '../models/business_data.dart';
import 'business_rubro_detail_screen.dart';
import '../components/premium_negocio_list_card.dart';
import 'package:go_router/go_router.dart';
import 'niche_confirmation_screen.dart';

class IndustryCategoryScreen extends StatelessWidget {
  final IndustryCategory category;

  const IndustryCategoryScreen({Key? key, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      title: category.name.toUpperCase(),
      showBackButton: true,
      body: SingleChildScrollView( 
        padding: const EdgeInsets.only(bottom: 40),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Text(
              'Selecciona tu Modelo de Negocio',
              style: GoogleFonts.outfit(
                color: const Color(0xFFD4AF37), // Gold H1
                fontSize: 20,
                fontWeight: FontWeight.bold,
                shadows: [
                   BoxShadow(color: const Color(0xFFD4AF37).withOpacity(0.2), blurRadius: 10),
                ]
              ),
            ),
             const SizedBox(height: 4),
             Text(
              'Elige la opción que mejor describa tu emprendimiento.',
              style: GoogleFonts.outfit(
                color: Colors.white60,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),

            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: category.rubros.length,
              itemBuilder: (context, index) {
                final rubro = category.rubros[index];
                
                // Use the color defined in BusinessRubro, or fallback to Gold
                final Color accentColor = rubro.color ?? const Color(0xFFD4AF37);

                return PremiumNegocioListCard(
                  title: rubro.name,
                  subtitle: rubro.description,
                  icon: category.icon, // Use category icon instead of generic storefront
                  accentColor: accentColor,
                  tags: rubro.tags,
                  investmentLevel: rubro.investmentLevel,
                  timeEstimate: rubro.timeEstimate,
                  onTap: () {
                      // Navigate to confirmation for ALL niches
                      context.push('/mi_negocio_rubro/category/${category.id}/rubro/${rubro.id}');
                  }
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
