import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../components/premium_scaffold.dart';
import '../components/neon_widgets.dart';
import '../navigation/app_routes.dart';
import 'package:go_router/go_router.dart';

class PremiumPlansScreen extends StatelessWidget {
  const PremiumPlansScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      title: 'TIENDA PREMIUM',
      useScroll: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // Title & Subtitle
            Text(
              'Planes Premium de Empodérate',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                shadows: [
                  BoxShadow(color: kNeonGold.withOpacity(0.3), blurRadius: 12)
                ]
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Elige el plan que impulsa tu negocio al siguiente nivel.',
              style: GoogleFonts.outfit(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w300,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // 1. PLAN INICIO
            _buildPlanCard(
              context,
              title: 'Plan Inicio',
              price: 'Gratis',
              description: 'Comenzar tu negocio.',
              features: ['Acceso básico a herramientas', '1 perfil de negocio', 'Blog informativo'],
              buttonText: 'Plan Actual',
              buttonColor: Colors.grey,
              isCurrent: true,
            ),
            const SizedBox(height: 24),

            // 2. PLAN CRECIMIENTO
            _buildPlanCard(
              context,
              title: 'Plan Crecimiento',
              price: 'B/. 9.99 / mes',
              description: 'Ordenar y formalizar.',
              features: ['Calculadoras ilimitadas', 'Auditoría básica', 'Soporte por email'],
              buttonText: 'Actualizar a Crecimiento',
              buttonColor: kNeonCyan,
              onTap: () {
                // TODO: Integrar pasarela de pagos aquí
                // AppRoutes.checkoutEmprendedor es un placeholder
                context.push(AppRoutes.checkoutEmprendedor);
              },
              borderColor: kNeonCyan,
            ),
            const SizedBox(height: 24),

            // 3. PLAN PRO
            Stack(
              clipBehavior: Clip.none,
              children: [
                _buildPlanCard(
                  context,
                  title: 'Plan Pro',
                  price: 'B/. 19.99 / mes',
                  description: 'Escalar y optimizar.',
                  features: ['Todas las herramientas PRO', 'Auditoría IA avanzada', 'Soporte prioritario', 'Acceso a Bóveda Digital'],
                  buttonText: 'Obtener Plan Pro',
                  buttonColor: kNeonViolet,
                  onTap: () {
                    // TODO: Integrar pasarela de pagos aquí
                    // AppRoutes.checkoutPro es un placeholder
                    context.push(AppRoutes.checkoutPro);
                  },
                  borderColor: kNeonViolet,
                  isRecommended: true,
                ),
                Positioned(
                  top: -12,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: kNeonViolet,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: kNeonViolet.withOpacity(0.5), blurRadius: 8)],
                    ),
                    child: Text(
                      'RECOMENDADO',
                      style: GoogleFonts.outfit(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 4. PLAN EMPRESARIAL
            _buildPlanCard(
              context,
              title: 'Plan Empresarial',
              price: 'B/. 39.99 / mes',
              description: 'Automatizar y escalar.',
              features: [
                'Todo en Plan Pro',
                'Auditoría IA completa 24/7',
                'Múltiples negocios',
                'Soporte dedicado',
                'APIs personalizadas',
                'Capacitación personalizada',
              ],
              buttonText: 'Obtener Plan Empresarial',
              buttonColor: kNeonGold,
              onTap: () {
                // TODO: Implementar pasarela de pagos
                // Ejemplo: Stripe, PayPal, Yappy, etc.
                // Navigator.pushNamed(context, AppRoutes.checkoutEmpresarial);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('🚀 Próximamente: Integración de pagos'),
                    backgroundColor: Color(0xFFFFD700),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              borderColor: kNeonGold,
              badgeIcon: Icons.apartment,
            ),


            const SizedBox(height: 48),
            
            // COMPARISON TABLE (Optional but implemented)
            NeonSectionTitle(title: 'Comparativa de Beneficios', color: Colors.white),
            const SizedBox(height: 16),
            _buildComparisonTable(),
            
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(
    BuildContext context, {
    required String title,
    required String price,
    required String description,
    required List<String> features,
    required String buttonText,
    required Color buttonColor,
    VoidCallback? onTap,
    Color? borderColor,
    bool isCurrent = false,
    bool isRecommended = false,
    IconData? badgeIcon, // New
  }) {
    final color = borderColor ?? Colors.white;
    
    return NeonWideCard(
      borderColor: color,
      isPremium: isRecommended, 
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // BADGE TITLE
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
               if (badgeIcon != null) ...[
                   Icon(badgeIcon, color: color, size: 24),
                   const SizedBox(width: 10),
               ],
               Text(
                   title, 
                   style: GoogleFonts.outfit(
                       color: color, 
                       fontSize: 22, 
                       fontWeight: FontWeight.bold,
                       shadows: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 10)]
                   )
               ),
            ],
          ),
          const SizedBox(height: 8),
          
          Text(price, style: GoogleFonts.outfit(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(description, style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14), textAlign: TextAlign.center),
          const Divider(color: Colors.white12, height: 32),
          
          ...features.map((f) => Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center, 
              children: [
                Icon(Icons.check_circle, color: color, size: 18),
                const SizedBox(width: 8),
                Text(f, style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.9), fontSize: 15)),
              ],
            ),
          )),
          
          const SizedBox(height: 24),
          
          // Button
          SizedBox(
            width: double.infinity,
            child: NeonButton(
              text: buttonText,
              onTap: onTap ?? () {},
              primary: !isCurrent,
              color: isCurrent ? Colors.white12 : buttonColor,
              textColor: isCurrent ? Colors.white54 : Colors.black, // CTA text black
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: NeonTable(
        headers: const ['Beneficio', 'Inicio', 'Crecimiento', 'Pro', 'Empresarial'],
        rows: [
          [
            _cellText('Herramientas Básicas'),
            _iconCheck(true),
            _iconCheck(true),
            _iconCheck(true),
            _iconCheck(true),
          ],
          [
            _cellText('Auditoría IA'),
            _iconCheck(false), // X
            _cellText('Básica'),
            _cellText('Avanzada'),
            _cellText('24/7'),
          ],
          [
            _cellText('Calculadoras'),
            _cellText('Limitadas'),
            _iconCheck(true),
            _iconCheck(true),
            _iconCheck(true),
          ],
          [
            _cellText('Soporte'),
            _cellText('Comunidad'),
            _cellText('Email'),
            _cellText('Prioritario'),
            _cellText('Dedicado'),
          ],
          [
            _cellText('Bóveda Digital'),
            _iconCheck(false),
            _iconCheck(false),
            _iconCheck(true),
            _iconCheck(true),
          ],
          [
            _cellText('Múltiples Negocios'),
            _iconCheck(false),
            _iconCheck(false),
            _iconCheck(false),
            _iconCheck(true),
          ],
        ], 
        accentColor: kNeonGold,
        columnWidths: const {
          0: FixedColumnWidth(140),
          1: FixedColumnWidth(80),
          2: FixedColumnWidth(100),
          3: FixedColumnWidth(80),
          4: FixedColumnWidth(100),
        },
      ),
    );
  }
  
  Widget _cellText(String text) {
    return Text(text, style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13));
  }

  Widget _iconCheck(bool check) {
    return Icon(
      check ? Icons.check : Icons.close,
      color: check ? kNeonGreen : Colors.white24,
      size: 18,
    );
  }
}
