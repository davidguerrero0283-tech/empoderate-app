import 'package:flutter/material.dart';
import 'package:proyecto_empoderate/ui/components/drawer/premium_drawer.dart';
import '../services/menu_persistent_state.dart';

class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final menuService = MenuStateService();

    return ValueListenableBuilder<bool>(
      valueListenable: menuService.menuNotifier,
      builder: (context, isMenuOpen, _) {
        return Stack(
          children: [
            // MAIN CONTENT (Slides with Drawer)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOutCubic,
              left: isMenuOpen ? 300 : 0,
              right: 0,
              top: 0,
              bottom: 0,
              child: child,
            ),
            
            // DRAWER (Always on top or side)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOutCubic,
              left: isMenuOpen ? 0 : -300,
              top: 0,
              bottom: 0,
              width: 300,
              child: const PremiumDrawer(),
            ),
          ],
        );
      },
    );
  }
}
