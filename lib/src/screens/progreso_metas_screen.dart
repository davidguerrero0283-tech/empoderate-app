import 'package:flutter/material.dart';
import '../components/premium_scaffold.dart';
import '../components/section_option_card.dart';
import '../analytics/analytics_components.dart';
import '../analytics/analytics_charts.dart';
import '../analytics/analytics_tables.dart';

class ProgresoMetasScreen extends StatelessWidget {
  const ProgresoMetasScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      title: 'MI PROGRESO',
      showBackButton: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const EmpoderaSectionTitle(title: 'Resumen de tu progreso'),
          const Row(
            children: [
              Expanded(
                child: EmpoderaKpiCard(
                  label: 'Metas completadas',
                  value: '12',
                  icon: Icons.check_circle_outline,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: EmpoderaKpiCard(
                  label: 'Metas en curso',
                  value: '5',
                  icon: Icons.trending_up,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const EmpoderaLineChart(),
          const SizedBox(height: 24),
          const EmpoderaSectionTitle(title: 'Detalle de metas'),
          const EmpoderaDataTable(
            columns: ['Meta', 'Estado', 'Límite'],
            rows: [
              ['Registro DGI', 'Completado', '15/01'],
              ['Aviso Op.', 'En curso', '20/01'],
              ['Cta. Bancaria', 'Pendiente', '30/01'],
              ['Plan Mkt', 'Pendiente', '15/02'],
            ],
          ),
          const EmpoderaDividerGold(),
          SectionOptionCard(
            icon: Icons.show_chart,
            title: 'Tu avance',
            subtitle: 'Métricas generales',
            onTap: () {},
          ),
          SectionOptionCard(
            icon: Icons.speed,
            title: 'Metas rápidas',
            subtitle: 'Objetivos a corto plazo',
            onTap: () {},
          ),
          SectionOptionCard(
            icon: Icons.flag,
            title: 'Metas largas',
            subtitle: 'Visión a futuro',
            onTap: () {},
          ),
          SectionOptionCard(
            icon: Icons.check_circle,
            title: 'Checklist inteligente',
            subtitle: 'Tareas pendientes',
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
