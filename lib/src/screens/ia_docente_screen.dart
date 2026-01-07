import 'package:flutter/material.dart';
import '../components/premium_scaffold.dart';
import '../components/info_button.dart';

class IADocenteScreen extends StatelessWidget {
  const IADocenteScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      title: 'IA DOCENTE',
      useScroll: false,
      body: Stack(
        children: [
          const Center(
            child: Text(
              'IA Docente - Placeholder',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: InfoButton(
              title: 'IA Docente',
              content: '''
La IA Docente es tu guía educativa dentro de Empodérate. Está diseñada para explicarte conceptos, enseñarte temas nuevos y ayudarte a entender cada parte del mundo del emprendimiento paso a paso. Puedes utilizarla como un profesor personal que responde preguntas, desarrolla temas y te acompaña en tu proceso de aprendizaje.

Puedes pedirle que te explique temas como flujo de caja, costos, marketing, ventas, trámites, términos legales o herramientas digitales, usando ejemplos sencillos y adaptados a tu tipo de negocio. También puede ayudarte a estudiar poco a poco: resúmenes, listas de pasos, comparaciones y ejercicios prácticos.

La IA Docente puede funcionar como soporte del Centro de Aprendizaje: puedes preguntarle cosas como: ‘Explícame esto como si fuera principiante’, ‘Dame un ejemplo aplicado a mi negocio’, ‘Qué debería aprender primero?’ o ‘Explícame esto paso a paso’. Su objetivo es que nunca más te sientas perdido frente a un concepto, sino que puedas aprender a tu ritmo, con paciencia y con explicaciones claras.
''' 
            ),
          ),
        ],
      ),
    );
  }
}
