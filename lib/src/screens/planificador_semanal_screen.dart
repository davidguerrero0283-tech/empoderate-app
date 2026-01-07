// Placeholder screen for Planificador Semanal
import 'package:flutter/material.dart';
import '../components/premium_scaffold.dart';

class PlanificadorSemanalScreen extends StatelessWidget {
  const PlanificadorSemanalScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      title: 'MEJORA TU PRODUCTIVIDAD',
      showBackButton: true,
      useScroll: false, // Allows Center to work
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.calendar_month, size: 60, color: Colors.white54),
            const SizedBox(height: 20),
            const Text(
              'Planificador Semanal',
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
             const SizedBox(height: 10),
            const Text(
              'Próximamente disponible',
              style: TextStyle(color: Colors.white54, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
