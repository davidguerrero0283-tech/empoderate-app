import 'package:flutter/material.dart';
import '../components/premium_scaffold.dart';
import '../components/info_button.dart';

class IALegalScreen extends StatelessWidget {
  const IALegalScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      title: 'IA LEGAL',
      useScroll: false,
      body: Stack(
        children: [
          const Center(
            child: Text(
              'IA Legal - Placeholder',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: InfoButton(
              title: 'IA Legal',
              content: '''
La IA Legal es tu asistente de orientación básica sobre temas laborales, contractuales y formales relacionados con tu negocio. No sustituye el consejo de un abogado, pero te ayuda a entender conceptos, términos y obligaciones de forma sencilla, para que no te sientas perdido frente a temas legales.

Puedes usarla para aclarar dudas sobre contratos laborales, tipos de contratos, términos comunes, obligaciones del empleador y del trabajador, permisos, licencias, despidos, renuncias, entre otros. También puede ayudarte a entender documentos, señalar partes importantes de un contrato y explicar en lenguaje sencillo qué significa cada cláusula.

La IA Legal te ayuda a prepararte mejor antes de hablar con un abogado o con el Ministerio de Trabajo. Puedes preguntarle: ‘¿Qué debería incluir un contrato básico?’, ‘¿Qué pasa si un trabajador no firma?’, ‘¿Qué es el período de prueba?’ o ‘¿Qué riesgos tengo si contrato sin contrato escrito?’.
Es una herramienta pensada para reducir el miedo a lo legal y darte más confianza para hacer las cosas de forma ordenada y correcta.
''' 
            ),
          ),
        ],
      ),
    );
  }
}
