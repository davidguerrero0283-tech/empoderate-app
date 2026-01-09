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

      floatingActionButton: null,
      body: Center(
        child: Text(
          'IA Contable - Placeholder',
          style: EmpoderateTheme.titleStyle.copyWith(color: EmpoderateTheme.white),
        ),
      ),
    );
  }
}
