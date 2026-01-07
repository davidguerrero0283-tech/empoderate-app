# Sentry Integration - Error Tracking & Performance Monitoring

## 🎯 Qué es Sentry

Sentry es una plataforma de monitoreo de errores y performance que te permite:
- Ver errores en tiempo real
- Stack traces completos
- Información de usuario y contexto
- Performance monitoring de operaciones
- Releases y distribución de errores por versión

---

## 📦 Setup en Flutter

### 1. Agregar Dependencia

```yaml
# pubspec.yaml
dependencies:
  sentry_flutter: ^7.14.0  # o última versión
```

```bash
flutter pub get
```

### 2. Configurar Sentry DSN

1. Crear cuenta en [sentry.io](https://sentry.io)
2. Crear nuevo proyecto Flutter
3. Copiar el DSN
4. Agregar a `.env`:

```bash
SENTRY_DSN=https://your-key@your-org.ingest.sentry.io/your-project-id
```

---

## 🔧 Integración Implementada

### Archivos Creados

1. **`lib/core/config/sentry_config.dart`**
   - Inicialización de Sentry
   - Configuración por ambiente
   - User tracking (login/logout)
   - Breadcrumbs

2. **`lib/services/app_logger.dart`**
   - Servicio centralizado de logging
   - Integración con Sentry
   - Performance monitoring
   - Logs locales en desarrollo

3. **`lib/main.dart`** (modificado)
   - Sentry init en `main()`
   - Captura de errores Flutter y async
   - Environment setup

### Características

✅ **Captura automática de**:
- Errores de Flutter (`FlutterError.onError`)
- Errores async no manejados
- Excepciones manuales vía `AppLogger`

✅ **Tags automáticos**:
- `platform`: web
- `environment`: dev/staging/prod
- `uid`: cuando el usuario hace login
- `version`: 1.0.0

✅ **Breadcrumbs**:
- Navegación de rutas
- Eventos importantes de la app
- Logs de info/warning

✅ **Performance**:
- Transacciones para medir operaciones
- Sample rate configurable por ambiente

---

## 📖 Uso en el Código

### Logging Básico

```dart
import 'package:proyecto_empoderate/services/app_logger.dart';

// Info log
AppLogger.info('Usuario completó onboarding', data: {
  'step': 'final',
  'duration': '30s',
});

// Debug log (solo en dev)
AppLogger.debug('Cache hit', data: {'key': 'user_profile'});

// Warning
AppLogger.warning('API retrying', data: {'attempt': 2});

// Error
AppLogger.error(
  'Failed to load data',
  error: exception,
  stackTrace: stackTrace,
  data: {'endpoint': '/api/users'},
);
```

### Capturar Excepciones

```dart
try {
  await riskyOperation();
} catch (e, stack) {
  AppLogger.captureException(
    e,
    stackTrace: stack,
    hint: 'Failed during checkout',
    extra: {
      'userId': currentUser.uid,
      'amount': 50.00,
    },
  );
}
```

### Performance Monitoring

```dart
// Medir duración de operación
final data = await AppLogger.measureOperation(
  name: 'Load Dashboard',
  operation: 'http.request',
  task: () async {
    return await _repository.getDashboardData();
  },
  data: {'userId': uid},
);

// Manual transaction
final transaction = AppLogger.startTransaction(
  name: 'Payment Flow',
  operation: 'payment.process',
);

try {
  await processPayment();
  transaction.status = SpanStatus.ok();
} catch (e) {
  transaction.status = SpanStatus.internalError();
} finally {
  await transaction.finish();
}
```

### User Tracking (Login/Logout)

```dart
import 'package:proyecto_empoderate/core/config/sentry_config.dart';

// Cuando usuario hace login
SentryConfig.setUser(
  uid: user.uid,
  email: user.email,
  displayName: user.displayName,
);

// Cuando hace logout
SentryConfig.clearUser();
```

### Breadcrumbs Manuales

```dart
SentryConfig.addBreadcrumb(
  message: 'User clicked checkout button',
  category: 'ui.interaction',
  level: SentryLevel.info,
  data: {'plan': 'pro', 'amount': 50.00},
);
```

---

## 🌐 Ver Errores en Sentry Dashboard

### 1. Dashboard Principal

URL: `https://sentry.io/organizations/[YOUR_ORG]/issues/`

**Principales vistas**:
- **Issues**: Todos los errores agrupados
- **Performance**: Transacciones y operaciones lentas
- **Releases**: Errores por versión

### 2. Filtrar Errores

**Por ambiente**:
```
environment:prod
```

**Por usuario**:
```
user.id:USER_UID
```

**Por versión**:
```
release:empoderate@1.0.0
```

**Combinado**:
```
environment:prod user.id:abc123 is:unresolved
```

### 3. Ver Detalles de Error

Cada error muestra:
- Stack trace completo
- Breadcrumbs (eventos previos)
- User context (uid, email)
- Device info
- Tags y metadata

### 4. Performance Monitoring

**Performance > Transactions**:
- Ver operaciones más lentas
- P75, P95, P99 percentiles
- Breakdown por span

**Ejemplo**: Ver cuánto tardan los requests a Cloud Functions

---

## 📊 Configurar Alertas

### Email/Slack cuando hay errores

1. **Settings > Alerts > Create Alert**
2. **When**: `An event is seen`
3. **Filter**: `environment` = `prod`
4. **Then**: Send notification to `#alerts` (Slack)

### Alertas de Performance

1. **Performance > Create Alert**
2. **When**: Transaction duration > 2 seconds
3. **For**: `api/payments/create-checkout`

---

## 🚀 Releases

### Configurar Release

```bash
# Build con release específico
flutter build web --release \
  --dart-define=SENTRY_RELEASE=empoderate@1.0.1
```

### Ver Errores por Release

En Sentry Dashboard:
1. **Releases > empoderate@1.0.0**
2. Ver:
   - New issues introducidos
   - Regresiones
   - Crash rate
   - Adoptación de versión

### Source Maps (opcional para web)

Para ver código fuente legible en stack traces:

```bash
# Instalar Sentry CLI
npm install -g @sentry/cli

# Upload source maps
sentry-cli releases files empoderate@1.0.0 \
  upload-sourcemaps build/web/main.dart.js
```

---

## 🔍 Debugging en Sentry

### 1. Reproducir Error

Cada error tiene:
- **Breadcrumbs**: Qué hizo el usuario antes
- **User session replay** (si habilitado)
- **Context**: Estado de la app

### 2. Stack Trace

- Click en frame para ver código
- Ver variables locales
- Source maps para código legible

### 3. Similar Issues

Sentry agrupa errores similares automáticamente

### 4. Resolver Issue

- Mark as resolved
- Ignore (si es ruido)
- Assign to developer

---

## ⚙️ Configuración Avanzada

### Sample Rate (Performance)

```dart
// sentry_config.dart línea 30
options.tracesSampleRate = 0.2; // 20% de requests
```

**Recomendación**:
- Dev: 1.0 (100%)
- Staging: 0.5 (50%)
- Prod: 0.1-0.3 (10-30%)

### Filtrar Eventos Sensibles

```dart
options.beforeSend = (event, hint) {
  // No enviar errores de red conocidos
  if (event.message?.contains('SocketException') == true) {
    return null;
  }
  return event;
};
```

### Custom Context

```dart
SentryConfig.setContext('subscription', {
  'plan': 'pro',
  'status': 'active',
  'expiresAt': '2024-12-31',
});
```

---

## 📝 Best Practices

### ✅ DO

- Usar `AppLogger` en lugar de `print()`
- Agregar context relevante a errores
- Usar tags para filtrar (`plan`, `feature`)
- Monitorear performance de operaciones críticas
- Configurar alertas para errores nuevos en prod

### ❌ DON'T

- Enviar información sensible (contraseñas, tokens)
- Loggear todo en producción (sample rate alto)
- Ignorar errores sin investigar
- Hardcodear el DSN en código

---

## 🆘 Troubleshooting

### No aparecen errores en Sentry

1. Verificar DSN en `.env`
2. Verificar que `SENTRY_DSN` no esté vacío
3. Check network tab (debe ver POST a sentry.io)
4. Verificar `environment` correcto

### Demasiados errores

1. Ajustar `sampleRate`
2. Usar `beforeSend` para filtrar
3. Resolver issues críticos primero

### Performance lento

1. Reducir `tracesSampleRate`
2. No medir operaciones triviales
3. Usar transactions solo para flujos importantes

---

## 📈 Métricas Importantes

### Error Tracking
- **Crash-free rate**: >99.5%
- **Response time**: Resolver críticos < 24h
- **Error rate**: < 1% de sesiones

### Performance
- **P95 latency**: < 2s
- **Slow transactions**: < 5%
- **Throughput**: requests/min

---

**Documentación oficial**: https://docs.sentry.io/platforms/flutter/

