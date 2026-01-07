import 'package:flutter/material.dart';
import 'src/navigation/app_routes.dart';
import 'package:proyecto_empoderate/ui/theme/app_theme.dart';
import 'package:proyecto_empoderate/ui/components/footer/bottom_nav_bar.dart';
import 'src/navigation/main_shell.dart';
import 'src/services/theme_manager.dart';

import 'src/features/blog/blog_data_service.dart';
import 'src/features/analytics/analytics_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize persistence services
  await BlogDataService.instance.init();
  await AnalyticsService.instance.init();
  await ThemeManager.instance.init();

  runApp(const EmpodernateApp());
}

class EmpodernateApp extends StatelessWidget {
  const EmpodernateApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ThemeManager.instance,
      builder: (context, _) {
        return MaterialApp(
          title: 'PROYECTO EMPODÉRATE',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeManager.instance.themeMode,
          initialRoute: AppRoutes.root,
          routes: AppRoutes.routes,
          onUnknownRoute: (settings) {
            return MaterialPageRoute(
              builder: (context) => Scaffold(
                body: Center(
                  child: Text(
                    'Ruta no encontrada: ${settings.name}',
                    style: const TextStyle(color: Colors.red, fontSize: 24),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
