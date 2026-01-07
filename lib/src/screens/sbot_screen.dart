import 'package:flutter/material.dart';
import '../components/premium_scaffold.dart';

class SBotScreen extends StatelessWidget {
  const SBotScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const PremiumScaffold(
      title: 'S-BOT',
      showBackButton: true,
      body: Center(
        child: Text(
          'Asistente inteligente de organización del negocio (S‑BOT) – placeholder',
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
