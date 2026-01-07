import 'package:flutter/material.dart';
import '../components/premium_scaffold.dart';
import '../components/info_button.dart';

class IAMarketingScreen extends StatelessWidget {
  const IAMarketingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      title: 'IA MARKETING',
      useScroll: false,
      body: Stack(
        children: [
          const Center(
            child: Text(
              'IA Marketing - Placeholder',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: InfoButton(
              title: 'IA de Marketing',
              content: '''
La IA de Marketing es tu creativa de confianza, disponible 24/7, para ayudarte a generar ideas de contenido, mensajes, campañas y estrategias de promoción adaptadas a tu negocio. Puedes usarla para crear textos para redes sociales, descripciones de productos, ideas de historias, guiones para videos cortos y mensajes para captar la atención de tus clientes.

También puede ayudarte a definir tu público objetivo, encontrar el tono adecuado para tu marca, proponer temas de valor para educar a tu audiencia y diseñar estructuras de campañas sencillas que puedas implementar paso a paso. Puedes decirle qué tipo de negocio tienes, a quién le vendes y qué estás intentando lograr, y la IA te dará propuestas concretas.

Puedes preguntarle cosas como: ‘Dame ideas de publicaciones para esta semana’, ‘Ayúdame a explicar mi producto en palabras simples’, ‘Cómo puedo diferenciarme de mi competencia?’ o ‘Qué contenido puedo crear para atraer más clientes?’. La IA de Marketing no solo genera textos, también puede darte sugerencias estratégicas: qué tipo de contenido usar, con qué frecuencia publicar y cómo combinar contenido educativo, promocional y emocional para construir una marca sólida.
''' 
            ),
          ),
        ],
      ),
    );
  }
}
