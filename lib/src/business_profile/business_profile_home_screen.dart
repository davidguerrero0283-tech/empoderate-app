import 'package:flutter/material.dart';
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
            onTap: () => Navigator.pushNamed(context, AppRoutes.businessProfileForm),
          ),
          SectionOptionCard(
            icon: Icons.visibility,
            title: 'Ver perfil registrado',
            subtitle: 'Consulta tus datos',
            onTap: () => Navigator.pushNamed(context, AppRoutes.businessProfileReview),
          ),
          SectionOptionCard(
            icon: Icons.notifications_active,
            title: 'Recordatorios automáticos',
            subtitle: 'Alertas generadas por IA',
            onTap: () => Navigator.pushNamed(context, AppRoutes.reminders),
          ),
          SectionOptionCard(
            icon: Icons.add_alarm,
            title: 'Crear recordatorio manual',
            subtitle: 'Personaliza tus alertas',
            onTap: () => Navigator.pushNamed(context, AppRoutes.reminderDetail),
          ),
        ],
      ),
    );
  }
}
