import 'package:flutter/material.dart';
import '../../ui/theme/empoderate_theme.dart';
import '../components/neon_widgets.dart';
import '../components/premium_scaffold.dart';

class CalculatorPlaceholderScreen extends StatelessWidget {
  final String title;
  final String description;

  const CalculatorPlaceholderScreen({
    Key? key,
    this.title = 'Calculadora',
    this.description = '',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return PremiumScaffold(
      title: title,
      showBackButton: true,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              NeonCard(
                borderColor: EmpoderateTheme.cyanAccent,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      const Icon(Icons.build_circle_outlined, size: 64, color: EmpoderateTheme.cyanAccent),
                      const SizedBox(height: 24),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: EmpoderateTheme.titleStyle.copyWith(fontSize: 24),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        description,
                        textAlign: TextAlign.center,
                        style: EmpoderateTheme.bodyStyle.copyWith(
                          color: EmpoderateTheme.white.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: EmpoderateTheme.gold.withOpacity(0.1),
                          border: Border.all(color: EmpoderateTheme.goldStrong),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Próximamente — En construcción',
                          style: EmpoderateTheme.bodyStyle.copyWith(
                            color: EmpoderateTheme.goldStrong,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
