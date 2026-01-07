import 'package:flutter/material.dart';
import '../components/premium_scaffold.dart';
import '../components/info_button.dart';
import '../navigation/app_routes.dart';
import '../../ui/theme/empoderate_theme.dart';

class IAContableScreen extends StatelessWidget {
  const IAContableScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      title: 'IA CONTABLE',
      useScroll: false,
      floatingActionButton: InfoButton(
        title: 'IA Contable',
        content: '''
La IA Contable es tu asistente financiero inteligente dentro de Empodérate. Está diseñada para ayudarte a entender tus números, identificar problemas en tus finanzas y tomar decisiones más seguras sin necesidad de ser contador. Puedes consultarle dudas sobre ingresos, gastos, ganancias, flujo de caja, márgenes de utilidad y más, usando lenguaje sencillo y ejemplos de tu negocio real.

Con la IA Contable puedes analizar si tu negocio está ganando dinero de verdad o si solo está moviendo efectivo sin dejar ganancia. También puedes pedirle ayuda para organizar tus categorías de gastos, clasificar tus costos fijos y variables, calcular márgenes de ganancia aproximados y entender qué está afectando tu rentabilidad.

Además, te puede guiar para hacer revisiones periódicas de tus finanzas: qué revisar semanalmente, qué revisar cada mes, y qué alertas debes vigilar. Puedes preguntarle cosas como: ‘¿Por qué siento que vendo pero no me alcanza?’, ‘¿Qué gastos puedo recortar?’, ‘¿Cómo organizo mis ingresos y gastos?’ o ‘¿Cuánto debería ahorrar para imprevistos?’.
La IA Contable no reemplaza a un contador formal, pero es una herramienta poderosa para tener claridad diaria sobre tus finanzas y prepararte mejor para hablar con tu contador o tomar decisiones importantes en tu negocio.
''' 
      ),
      body: Center(
        child: Text(
          'IA Contable - Placeholder',
          style: EmpoderateTheme.titleStyle.copyWith(color: EmpoderateTheme.white),
        ),
      ),
    );
  }
}
