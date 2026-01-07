# Sentry Integration - Quick Start

## ✅ Instalación Completada

Se ha integrado Sentry en Empodérate con las siguientes características:

### Archivos Creados

1. **`lib/core/config/sentry_config.dart`**
   - Inicialización de Sentry por ambiente (dev/staging/prod)
   - User tracking (login/logout)
   - Breadcrumbs y contexto

2. **`lib/services/app_logger.dart`**
   - Logging centralizado
   - Integración con Sentry
   - Performance monitoring
   - Logs locales en desarrollo

3. **`lib/main.dart`** (modificado)
   - Sentry init wrapper
   - Captura de errores Flutter (`FlutterError.onError`)
   - Captura de errores async (`PlatformDispatcher.instance.onError`)

4. **`SENTRY_GUIDE.md`**
   - Documentación completa de uso
   - Ejemplos de código
   - Guía del dashboard

---

## 🚀 Setup Rápido

### 1. Instalar Dependencia

```bash
flutter pub get
```

### 2. Configurar DSN

1. Crear cuenta en [sentry.io](https://sentry.io)
2. Crear proyecto Flutter
3. Copiar DSN
4. Agregar a `.env`:

```bash
SENTRY_DSN=https://your-key@org.ingest.sentry.io/project-id
```

### 3. Ejecutar App

```bash
# Development
flutter run -d chrome --dart-define=ENV=dev

# Production
flutter build web --release \
  --dart-define=ENV=prod \
  --dart-define=SENTRY_DSN=$SENTRY_DSN
```

---

## 📖 Uso Básico

Para documentación completa, ver **`SENTRY_GUIDE.md`**

### Logging

```dart
import 'package:proyecto_empoderate/services/app_logger.dart';

AppLogger.info('User action', data: {'action': 'click'});
AppLogger.error('Failed', error: e, stackTrace: stack);
```

### Capturar Excepciones

```dart
try {
  await riskyOperation();
} catch (e, stack) {
  AppLogger.captureException(e, stackTrace: stack);
}
```

### User Tracking (en AuthService)

```dart
import 'package:proyecto_empoderate/core/config/sentry_config.dart';

// Login
SentryConfig.setUser(uid: user.uid, email: user.email);

// Logout
SentryConfig.clearUser();
```

### Performance

```dart
final data = await AppLogger.measureOperation(
  name: 'Load Data',
  operation: 'http.request',
  task: () async => await fetchData(),
);
```

---

## 🎯 Próximos Pasos

1. **Configurar Sentry DSN** en `.env`
2. **Integrar user tracking** en tu Auth service
3. **Ver errores** en Sentry dashboard
4. **Configurar alertas** para errores en producción
5. **Revisar** `SENTRY_GUIDE.md` para features avanzadas

---

**Nota**: En desarrollo, Sentry no enviará eventos si `SENTRY_DSN` está vacío. La app funcionará normalmente con logs en consola.

