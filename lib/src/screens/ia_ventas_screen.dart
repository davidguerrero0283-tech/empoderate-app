// Placeholder screen for IA Ventas
import 'package:flutter/material.dart';
import '../components/premium_scaffold.dart';
import '../components/info_button.dart';

class IAVentasScreen extends StatelessWidget {
  const IAVentasScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      title: 'IA VENTAS',
      useScroll: false,
      body: Stack(
        children: [
          const Center(
            child: Text(
              'IA Ventas - Placeholder',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: InfoButton(
              title: 'IA de Ventas',
              content: '''
La IA de Ventas es una herramienta pensada para ayudarte a mejorar tus habilidades para cerrar ventas y atender mejor a tus clientes. Puedes usarla para practicar respuestas, pulir tu discurso de venta y preparar mensajes efectivos para WhatsApp, redes sociales o llamadas.

Puedes describirle una situación real y pedirle ayuda: por ejemplo, un cliente que dice que está caro, alguien que duda, alguien que quiere pensarlo, un cliente que pregunta mucho, o un cliente que desaparece después de pedir información. La IA de Ventas puede darte frases concretas, respetuosas y profesionales para responder, siempre enfocadas en generar confianza sin presionar demasiado.

También puede ayudarte a estructurar tu propuesta de valor, definir cómo presentar tu producto, cómo hacer seguimiento a un cliente sin parecer insistente y cómo pedir una decisión de manera clara. Puedes preguntarle: ‘Cómo cierro esta venta?’, ‘Qué respondo cuando me piden descuento?’ o ‘Cómo vuelvo a escribirle a un cliente que dejó de responder?’. Esta IA funciona como un “entrenador de ventas” personal, que te ayuda a ganar seguridad, mejorar tu comunicación y aumentar tus posibilidades de convertir interés en ingresos reales.
''' 
            ),
          ),
        ],
      ),
    );
  }
}
