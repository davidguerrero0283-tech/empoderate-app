import 'package:flutter/material.dart';
import '../../ui/theme/empoderate_theme.dart';
import '../components/premium_scaffold.dart';
import '../components/neon_widgets.dart'; 
import '../components/neon_style.dart';
import '../components/premium_placeholders.dart';
import '../components/legal_shielding.dart';
import '../components/info_button.dart';

class SalarioNetoScreen extends StatelessWidget {
  const SalarioNetoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final String? contentTitle = args?['title'];
    final String? contentBody = args?['content'];

    return PremiumScaffold(
      title: 'SALARIO / PLANILLA',
      showBackButton: true,
      floatingActionButton: (contentTitle != null && contentBody != null)
          ? InfoButton(title: contentTitle, content: contentBody)
          : null,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Calculadora de Salario Neto',
            style: EmpoderateTheme.titleStyle.copyWith(fontSize: 24),
          ),
          const SizedBox(height: 8),
          Text(
            'Estima tu ingreso líquido mensual tras deducciones de ley (CSS, SE, ISR).',
            style: EmpoderateTheme.subtitleStyle,
          ),
          const SizedBox(height: 24),
          
          NeonCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NeonSectionTitle(title: 'Datos de Salario', color: EmpoderateTheme.goldStrong),
                NeonInput(
                  label: 'Salario Mensual Bruto (\$)',
                  isNumber: true,
                  onChanged: (v) {}, 
                ),
                const SizedBox(height: 16),
                NeonButton(
                  text: 'CALCULAR SALARIO NETO',
                  primary: true,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Lógica completa en próxima fase.')),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          
          NeonSectionTitle(title: 'Desglose Estimado'),
          const SizedBox(height: 12),
          const PremiumTablePlaceholder(),
          const SizedBox(height: 16),
          const PremiumChartPlaceholder(),
          const SizedBox(height: 20),
          const LegalShielding(type: ShieldType.calculators),
        ],
      ),
    );
  }
}
