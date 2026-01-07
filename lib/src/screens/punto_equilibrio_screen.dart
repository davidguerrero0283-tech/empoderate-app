import 'package:flutter/material.dart';
import 'package:proyecto_empoderate/src/widgets/feature_intro_screen.dart';
import '../../ui/theme/empoderate_theme.dart';
import '../components/premium_scaffold.dart';
import '../components/section_option_card.dart';
import '../components/premium_placeholders.dart';
import '../components/calculator_info_panel.dart';

class PuntoEquilibrioScreen extends StatefulWidget {
  const PuntoEquilibrioScreen({Key? key}) : super(key: key);

  @override
  State<PuntoEquilibrioScreen> createState() => _PuntoEquilibrioScreenState();
}

class _PuntoEquilibrioScreenState extends State<PuntoEquilibrioScreen> {
  bool _showIntro = true;

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      title: 'PUNTO DE EQUILIBRIO',
      showBackButton: true,
      body: Stack(
        children: [
          // MAIN CONTENT - wrapped in Positioned.fill
          Positioned.fill(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Punto de equilibrio del negocio',
                    style: EmpoderateTheme.titleStyle.copyWith(fontSize: 22),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Calcula la rentabilidad mínima para cubrir costos fijos y variables.',
                    style: EmpoderateTheme.subtitleStyle,
                  ),
                  const SizedBox(height: 16),
                  const CalculatorInfoPanel(configId: 'break_even'),
                  const SizedBox(height: 16),
                  
                  SectionOptionCard(
                    icon: Icons.calculate,
                    title: 'Calcular punto de equilibrio',
                    subtitle: 'Ingresa costos y precios',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Próximamente disponible')),
                      );
                    },
                  ),
                  SectionOptionCard(
                    icon: Icons.show_chart,
                    title: 'Ver escenario comparativo',
                    subtitle: 'Simula diferentes escenarios de ventas',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Próximamente disponible')),
                      );
                    },
                  ),
    
                  const SizedBox(height: 24),
                  Text(
                    'Análisis de Rentabilidad',
                    style: EmpoderateTheme.titleStyle.copyWith(color: EmpoderateTheme.white, fontSize: 18),
                  ),
                  const SizedBox(height: 12),
                  const PremiumChartPlaceholder(),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),

          // --- INTRO OVERLAY ---
          if (_showIntro)
            Positioned.fill(
              child: FeatureIntroScreen(
                key: const ValueKey('IntroOverlay'),
                title: 'PUNTO DE EQUILIBRIO',
                subTitle: 'Descubre cuánto debes vender para cubrir todos tus gastos y empezar a generar ganancias.',
                heroEmoji: '⚖️',
                primaryColor: const Color(0xFFBA68C8), // Purple
                features: const [
                  IntroFeatureItem(Icons.balance, 'Equilibrio'),
                  IntroFeatureItem(Icons.trending_up, 'Rentabilidad'),
                  IntroFeatureItem(Icons.analytics, 'Simulación'),
                ],
                processSteps: const [
                  IntroStepItem('1. Costos Fijos', 'Ingresa alquiler, salarios, servicios.'),
                  IntroStepItem('2. Costos Variables', 'Agrega materiales por unidad.'),
                  IntroStepItem('3. Precio', 'Define tu precio de venta.'),
                ],
                proTip: 'Si vendes por debajo del equilibrio, ¡estás perdiendo dinero aunque vendas!',
                onDismiss: () => setState(() => _showIntro = false),
              ),
            ),
        ],
      ),
    );
  }
}

