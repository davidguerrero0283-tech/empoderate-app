import 'package:flutter/material.dart';
import '../../ui/theme/empoderate_theme.dart';
import '../components/premium_scaffold.dart';
import '../components/premium_cards.dart';
import '../navigation/app_routes.dart';
import 'package:go_router/go_router.dart';
import '../components/info_button.dart';

class QuickAccessScreen extends StatelessWidget {
  const QuickAccessScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      title: 'ACCESOS RÁPIDOS',
      showBackButton: true,
      floatingActionButton: InfoButton(
        title: 'Guía de Accesos Rápidos',
        content: '''
Los accesos rápidos están diseñados para que puedas llegar a las partes más importantes de la aplicación en solo un toque. En lugar de navegar por menús y secciones, esta área te permite entrar directamente en las herramientas esenciales de tu negocio, como contabilidad, ventas, marketing, trámites, recursos humanos, IA y otros módulos clave.

Cada tarjeta representa una función importante y de uso frecuente. Por ejemplo, puedes entrar rápidamente a una calculadora que usas todos los días, a una guía que necesitas revisar con frecuencia, o a una IA que te ayuda a resolver dudas al instante. El objetivo es ahorrarte tiempo y permitirte trabajar de forma más fluida.

Esta sección está pensada para emprendedores que manejan varias responsabilidades a la vez y necesitan moverse rápido. En lugar de perder tiempo buscando una herramienta específica, aquí la encuentras en segundos. A medida que tu negocio crece, los accesos rápidos te ayudan a mantener orden, eficiencia y claridad en tu trabajo diario.

Además, esta área puede mostrar herramientas destacadas que el sistema recomienda para ti según tu progreso en la app o según las acciones que has realizado recientemente. Esto permite que la experiencia sea personalizada y que siempre tengas a mano lo que más necesitas para avanzar.
''' 
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Principales'),
          _buildPrincipalGrid(context),
          const SizedBox(height: 24),
          
          _buildSectionHeader('Herramientas Útiles'),
          _buildToolsGrid(context),
          const SizedBox(height: 24),
          
          _buildSectionHeader('Secciones Avanzadas'),
          _buildAdvancedGrid(context),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: EmpoderateTheme.titleStyle.copyWith(
          color: EmpoderateTheme.white.withOpacity(0.7),
          fontSize: 16,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildPrincipalGrid(BuildContext context) {
    return Column(
      children: [
        ComponenteTarjetaPrincipal(
          icon: Icons.map,
          title: 'Ruta Emprendedor',
          subtitle: 'Camino completo paso a paso',
          color: Colors.white,
          onTap: () => context.push(AppRoutes.rutaEmprendedor),
        ),
        ComponenteTarjetaPrincipal(
          icon: Icons.dashboard,
          title: 'Dashboard',
          subtitle: 'Tu progreso y métricas',
          color: Colors.blueAccent,
          onTap: () => context.push(AppRoutes.dashboardNegocio),
        ),
        ComponenteTarjetaPrincipal(
          icon: Icons.track_changes,
          title: 'Misiones',
          subtitle: 'Objetivos del día',
          color: Colors.greenAccent,
          onTap: () => context.push(AppRoutes.misionesDiarias),
        ),
        ComponenteTarjetaPrincipal(
          icon: Icons.person_pin,
          title: 'Asesor EMPO',
          subtitle: 'Tu coach virtual',
          color: Colors.purpleAccent,
          onTap: () => context.push(AppRoutes.sbot),
        ),
        ComponenteTarjetaPrincipal(
          icon: Icons.school,
          title: 'Centro de Aprendizaje',
          subtitle: 'Cursos y guías',
          color: Colors.white,
          onTap: () => context.push(AppRoutes.learningCenter),
        ),
      ],
    );
  }

  Widget _buildToolsGrid(BuildContext context) {
    return Column(
      children: [
        ComponenteTarjetaPremium(
          icon: Icons.calculate,
          title: 'Calculadoras',
          subtitle: 'De negocio',
          iconColor: Colors.orangeAccent,
          onTap: () => context.push(AppRoutes.calculadoras),
        ),

        ComponenteTarjetaPremium(
          icon: Icons.assignment,
          title: 'Trámites',
          subtitle: 'Legales',
          iconColor: Colors.redAccent,
          onTap: () => context.push(AppRoutes.tramites),
        ),
        ComponenteTarjetaPremium(
          icon: Icons.campaign,
          title: 'Marketing',
          subtitle: 'Campañas',
          iconColor: Colors.pinkAccent,
          onTap: () => context.push(AppRoutes.marketing),
        ),
        ComponenteTarjetaPremium(
          icon: Icons.attach_money,
          title: 'Finanzas',
          subtitle: 'Control',
          iconColor: Colors.lightGreenAccent,
          onTap: () => context.push(AppRoutes.accounting),
        ),
      ],
    );
  }

  Widget _buildAdvancedGrid(BuildContext context) {
     return Column(
      children: [
        ComponenteTarjetaPremium(
          icon: Icons.store,
          title: 'Por Rubro',
          subtitle: 'Específico',
          iconColor: Colors.cyanAccent,
          onTap: () => context.push(AppRoutes.miNegocioRubro),
        ),
        ComponenteTarjetaPremium(
          icon: Icons.diamond,
          title: 'Tienda Premium',
          subtitle: 'Exclusivo',
          iconColor: Colors.white,
          onTap: () => context.push(AppRoutes.tiendaPremium),
        ),
        ComponenteTarjetaPremium(
          icon: Icons.notifications,
          title: 'Notificaciones',
          subtitle: 'Alertas',
          iconColor: Colors.amberAccent,
          onTap: () => context.push(AppRoutes.notifications),
        ),
        ComponenteTarjetaPremium(
          icon: Icons.help_outline,
          title: 'Ayuda',
          subtitle: 'Centro de soporte',
          iconColor: Colors.white,
          onTap: () => context.push(AppRoutes.settings),
        ),
      ],
    );
  }
}


