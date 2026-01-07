// Placeholder screen for IA Productividad
import 'package:flutter/material.dart';
import '../components/premium_scaffold.dart';
import '../components/info_button.dart';

class IAProductividadScreen extends StatelessWidget {
  const IAProductividadScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      title: 'IA PRODUCTIVIDAD',
      useScroll: false,
      body: Stack(
        children: [
          const Center(
            child: Text(
              'IA Productividad - Placeholder',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: InfoButton(
              title: 'IA de Productividad',
              content: '''
La IA de Productividad está diseñada para ayudarte a organizar mejor tu tiempo, tus tareas y tus prioridades como emprendedor. No se trata solo de hacer más cosas, sino de hacer lo que realmente importa para que tu negocio avance sin que te sientas abrumado todo el tiempo.

Puedes usarla para planear tu día, tu semana o tu mes, distribuyendo tareas de administración, marketing, atención al cliente, finanzas y descanso. La IA puede sugerirte rutinas, bloques de trabajo, tiempos de enfoque y descansos estratégicos para que no te quemes.

También puede ayudarte a dividir metas grandes en pasos pequeños, organizar listas de pendientes, identificar qué tareas puedes delegar y qué cosas estás haciendo que no suman valor. Puedes preguntarle: ‘Cómo organizo mi día?’, ‘Qué debería hacer primero?’, ‘Cómo dejo de procrastinar?’ o ‘Cómo equilibrar mi negocio y mi vida personal?’.
Es una herramienta diseñada para que dejes de sentir que estás apagando incendios y empieces a trabajar con más orden, intención y claridad.
''' 
            ),
          ),
        ],
      ),
    );
  }
}
