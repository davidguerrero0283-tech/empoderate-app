import 'package:flutter/material.dart';
import '../../ui/theme/empoderate_theme.dart';
import '../components/premium_scaffold.dart';
import '../components/section_option_card.dart';
import '../components/premium_placeholders.dart';

class RecordatoriosScreen extends StatelessWidget {
  const RecordatoriosScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      title: 'RECORDATORIOS',
      showBackButton: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Text(
            'Recordatorios y Agenda',
            style: EmpoderateTheme.titleStyle.copyWith(fontSize: 22),
          ),
          const SizedBox(height: 8),
          Text(
            'Gestiona tus tareas y fechas importantes.',
            style: EmpoderateTheme.subtitleStyle,
          ),
          const SizedBox(height: 24),
          
          SectionOptionCard(
            icon: Icons.notifications_active,
            title: 'Recordatorios activos',
            subtitle: 'Próximos vencimientos',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Próximamente disponible')),
              );
            },
          ),
          SectionOptionCard(
            icon: Icons.add_alarm,
            title: 'Crear recordatorio',
            subtitle: 'Nueva alerta personalizada',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Próximamente disponible')),
              );
            },
          ),
          SectionOptionCard(
            icon: Icons.history,
            title: 'Historial de recordatorios',
            subtitle: 'Alertas pasadas',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Próximamente disponible')),
              );
            },
          ),

          const SizedBox(height: 24),
          Text(
            'Resumen de Actividades',
            style: EmpoderateTheme.titleStyle.copyWith(color: EmpoderateTheme.white, fontSize: 18),
          ),
          const SizedBox(height: 12),
          const PremiumTablePlaceholder(),
        ],
      ),
    );
  }
}
