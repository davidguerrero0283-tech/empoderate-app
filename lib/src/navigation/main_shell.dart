import 'package:flutter/material.dart';
import 'app_routes.dart';
import '../screens/settings_screen.dart';
import '../screens/home_screen.dart';
import '../screens/tools_screen.dart';
import '../screens/boveda_digital_screen.dart';
import 'package:proyecto_empoderate/ui/components/drawer/premium_drawer.dart';
import 'package:proyecto_empoderate/ui/components/footer/bottom_nav_bar.dart';
import '../services/menu_persistent_state.dart';

class MainShell extends StatefulWidget {
  const MainShell({Key? key}) : super(key: key);

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  /*
   * REFACTOR: Real History Navigation
   * Instead of just switching index, we now PUSH routes.
   * Logic:
   * - Index 0 (Home): If we are not at root, popUntil root.
   * - Other Indexes: Push the named route.
   */
  void _onItemSelected(int index) {
    if (index == _currentIndex) return;

    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        // Go to Home (Root). Clear stack until first.
        Navigator.popUntil(context, (route) => route.isFirst);
        break;
      case 1:
        Navigator.pushNamed(context, AppRoutes.tools);
        break;
      case 2:
        Navigator.pushNamed(context, AppRoutes.bovedaDigital);
        break;
      case 3:
        Navigator.pushNamed(context, AppRoutes.settings);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Drawer removed here - Handled by child screens using PremiumScaffold
      body: const HomeScreen(), 
      bottomNavigationBar: NeonBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onItemSelected,
      ),
    );
  }
}
