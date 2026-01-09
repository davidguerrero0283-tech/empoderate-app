import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../components/premium_scaffold.dart';
import '../components/section_option_card.dart';
import '../navigation/app_routes.dart';

class BusinessProfileHomeScreen extends StatelessWidget {
  const BusinessProfileHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      title: 'PERFIL DEL NEGOCIO',
      subtitle: 'Registra los datos clave de tu emprendimiento',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionOptionCard(
            icon: Icons.edit,
            title: 'Editar perfil del negocio',
            subtitle: 'Actualiza tu información',
            onTap: () => context.push(AppRoutes.businessProfileForm),
          ),
          SectionOptionCard(
            icon: Icons.visibility,
            title: 'Ver perfil registrado',
            subtitle: 'Consulta tus datos',
            onTap: () => context.push(AppRoutes.businessProfileReview),
          ),
          SectionOptionCard(
            icon: Icons.notifications_active,
            title: 'Recordatorios automáticos',
            subtitle: 'Alertas generadas por IA',
            onTap: () => context.push(AppRoutes.reminders),
          ),
          SectionOptionCard(
            icon: Icons.add_alarm,
            title: 'Crear recordatorio manual',
            subtitle: 'Personaliza tus alertas',
            onTap: () => context.push(AppRoutes.reminderDetail),
          ),
        ],
      ),
    );
  }
}
