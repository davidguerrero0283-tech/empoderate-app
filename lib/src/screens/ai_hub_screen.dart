import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../components/premium_scaffold.dart';
import '../components/section_option_card.dart';
import '../components/neon_widgets.dart';
import '../navigation/app_routes.dart';
import '../components/info_button.dart';

class AIHubScreen extends StatelessWidget {
  const AIHubScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Unused args? Keeping for safety.
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    // final String? contentTitle = args?['title'];
    // final String? contentBody = args?['content'];

    return PremiumScaffold(
      title: 'CENTRO IA',
      useScroll: false,
      usePadding: false,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 80),
            child: Column(
              children: [
                SectionOptionCard(
                  icon: Icons.edit_note,
                  title: 'IA para textos',
                  subtitle: 'Genera copys y artículos',
                  onTap: () => Navigator.pushNamed(context, AppRoutes.aiTexts),
                ),
                SectionOptionCard(
                  icon: Icons.support_agent,
                  title: 'IA para clientes',
                  subtitle: 'Estrategias y perfiles de cliente',
                  onTap: () => Navigator.pushNamed(context, AppRoutes.aiCustomers),
                ),
                SectionOptionCard(
                  icon: Icons.inventory_2,
                  title: 'IA para productos',
                  subtitle: 'Descripciones optimizadas',
                  onTap: () => Navigator.pushNamed(context, AppRoutes.aiProducts),
                ),
                SectionOptionCard(
                  icon: Icons.description,
                  title: 'IA para contratos',
                  subtitle: 'Borradores legales básicos',
                  onTap: () => Navigator.pushNamed(context, AppRoutes.aiContracts),
                ),
                SectionOptionCard(
                  icon: Icons.settings_suggest,
                  title: 'IA para procesos',
                  subtitle: 'Optimización operativa',
                  onTap: () => Navigator.pushNamed(context, AppRoutes.aiProcesses),
                ),
                SectionOptionCard(
                  icon: Icons.trending_up,
                  title: 'IA para estrategias',
                  subtitle: 'Planes de crecimiento',
                  onTap: () => Navigator.pushNamed(context, AppRoutes.aiStrategies),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: InfoButton(
              title: 'Cómo usar el Centro IA de Empodérate',
              content: '''
El Centro IA de Empodérate es el espacio donde se reúnen todas las inteligencias artificiales que te acompañan en tu camino como emprendedor. Aquí puedes ver y acceder de forma organizada a la IA Contable, IA Legal, IA de Marketing, IA de Ventas, IA de Productividad, IA Docente y cualquier otra IA especializada que se haya incorporado a la app.

Este centro está diseñado para que no tengas que adivinar a quién preguntarle qué. Desde aquí puedes entender el propósito de cada IA, en qué situaciones usarla y qué tipo de preguntas puedes hacerle para obtener mejores resultados. Es como una sala de control donde tienes a todos tus “asesores digitales” reunidos en un solo lugar.

En el Centro IA también puedes aprender buenas prácticas para conversar con la inteligencia artificial: cómo describir tu negocio, cómo explicar un problema, cómo pedir ejemplos, cómo solicitar pasos concretos o cómo adaptar las respuestas a tu realidad. Esto te ayuda a aprovechar al máximo las capacidades de cada IA, sin perder tiempo ni sentirte confundido.

Además, el Centro IA puede mostrarte atajos inteligentes, sugerencias basadas en lo que estás trabajando y accesos a plantillas de prompts que te facilitan hacer las preguntas correctas. Por ejemplo, puedes usar plantillas para revisar tus finanzas, mejorar tus precios, pulir tu discurso de ventas, revisar un contrato, organizar tu día o entender un concepto nuevo.

La idea es que veas a este Centro como tu “equipo de asesores virtuales”: no estás solo, siempre tendrás una IA lista para ayudarte a pensar, organizar, analizar y decidir, de forma rápida y accesible desde tu celular.
''' 
            ),
          ),
        ],
      ),
    );
  }
}
