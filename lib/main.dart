import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'src/navigation/app_routes.dart';
import 'src/navigation/app_router.dart';
import 'package:proyecto_empoderate/ui/theme/app_theme.dart';
import 'package:proyecto_empoderate/ui/components/footer/bottom_nav_bar.dart';
import 'src/navigation/main_shell.dart';
import 'src/navigation/app_shell.dart';
import 'src/services/theme_manager.dart';
import 'src/features/blog/blog_data_service.dart';
import 'src/features/analytics/analytics_service.dart';

// Sentry integration
import 'package:sentry_flutter/sentry_flutter.dart';
import 'core/config/env_config.dart';
import 'core/config/sentry_config.dart';
import 'services/app_logger.dart';

void main() async {
  // Inicializar Sentry ANTES de todo
  // Esto captura errores durante la inicialización
  await SentryConfig.init(
    appRunner: () => _runApp(),
  );
}

Future<void> _runApp() async {
  debugPrint("MAIN START: Initializing Binding");
  
  try {
    WidgetsFlutterBinding.ensureInitialized();
    debugPrint("MAIN: Binding initialized");
    
    // Configurar captura de errores de Flutter
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      AppLogger.captureException(
        details.exception,
        stackTrace: details.stack,
        hint: Hint.withMap({'message': 'FlutterError'}),
        extra: {
          'context': details.context?.toString(),
          'library': details.library,
        },
      );
    };
    
    // Capturar errores async no manejados
    PlatformDispatcher.instance.onError = (error, stack) {
      AppLogger.captureException(
        error,
        stackTrace: stack,
        hint: Hint.withMap({'message': 'Unhandled async error'}),
      );
      return true;
    };
    
    // Initialize environment
    const environment = String.fromEnvironment('ENV', defaultValue: 'dev');
    EnvConfig.init(
      environment == 'prod' ? Environment.prod :
      environment == 'staging' ? Environment.staging :
      Environment.dev
    );
    
    AppLogger.info('App starting', data: {
      'environment': EnvConfig.current.name,
      'version': EnvConfig.appVersion,
    });
    
    // Initialize persistence services
    debugPrint("MAIN: waiting BlogDataService...");
    await BlogDataService.instance.init();
    AppLogger.debug("BlogDataService initialized");

    debugPrint("MAIN: waiting AnalyticsService...");
    await AnalyticsService.instance.init();
    AppLogger.debug("AnalyticsService initialized");

    debugPrint("MAIN: waiting ThemeManager...");
    await ThemeManager.instance.init();
    AppLogger.debug("ThemeManager initialized");
    
    // Initialize Locale Data
    debugPrint("MAIN: Initializing Date Formatting...");
    await initializeDateFormatting('es', null);
    AppLogger.debug("Date Formatting initialized");
  
    debugPrint("MAIN: Calling runApp");
    runApp(const EmpodernateApp());
    
    AppLogger.info('App started successfully');
    
  } catch (e, stack) {
    debugPrint("MAIN ERROR: $e");
    debugPrint("STACK: $stack");
    
    AppLogger.captureException(
      e,
      stackTrace: stack,
      hint: Hint.withMap({'message': 'App initialization failed'}),
    );
    
    runApp(ErrorApp(error: e.toString()));
  }
}

class ErrorApp extends StatelessWidget {
  final String error;
  const ErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.red.shade50,
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 20),
                  const Text(
                    'Error de Inicialización',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    error,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class EmpodernateApp extends StatelessWidget {
  const EmpodernateApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Faster page transitions for responsiveness
    const pageTransitionsTheme = PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.macOS: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
      },
    );

    return AnimatedBuilder(
      animation: ThemeManager.instance,
      builder: (context, _) {
        return MaterialApp.router(
          title: 'PROYECTO EMPODÉRATE',
          debugShowCheckedModeBanner: false,
          routerConfig: AppRouter.router,
          theme: AppTheme.lightTheme.copyWith(pageTransitionsTheme: pageTransitionsTheme),
          darkTheme: AppTheme.darkTheme.copyWith(pageTransitionsTheme: pageTransitionsTheme),
          themeMode: ThemeManager.instance.themeMode,
          builder: (context, child) {
            // Wrap the entire Navigator in our persistent shell
            return AppShell(child: child!);
          },
        );
      },
    );
  }
}
