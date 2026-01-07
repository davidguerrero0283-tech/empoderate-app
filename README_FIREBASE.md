# Empodérate - Firebase Production Stack

## 🚀 Stack Implementado

### Frontend
- **Flutter Web** con Firebase Auth, Firestore
- **Sentry** para error tracking

### Backend
- **Firebase Cloud Functions** (TypeScript)
- **AI Proxy** (OpenAI)
- **Payment Integration** (2Checkout + PayPal)

---

## 📁 Estructura Creada

```
empoderate/
├── lib/
│   ├── core/
│   │   ├── config/
│   │   │   └── env_config.dart         ✅ Multi-environment
│   │   └── constants/
│   │       ├── api_endpoints.dart       ✅ API endpoints
│   │       └── app_constants.dart       ✅ App constants
│   └── services/
│       └── firebase/                    🔜 Auth & Firestore services
│
├── functions/                           ✅ Cloud Functions base
│   ├── src/
│   │   ├── index.ts                     ✅ Entry point
│   │   ├── api/
│   │   │   └── health.ts                ✅ Health endpoint
│   │   ├── security/
│   │   │   └── auth_middleware.ts       ✅ Auth middleware
│   │   ├── logging/
│   │   │   └── logger.ts                ✅ Logger service
│   │   ├── payments/
│   │   │   └── providers/
│   │   │       └── payment_provider.interface.ts  ✅
│   │   └── ai/                          🔜 AI proxy
│   ├── package.json                     ✅
│   └── tsconfig.json                    ✅
│
├── .env.example                         ✅ Variables template
├── firebase.json                        ✅ Firebase config
├── firestore.rules                      ✅ Security rules
└── firestore.indexes.json               ✅
```

---

## 🔧 Setup Inicial

### 1. Instalar Firebase CLI

```bash
npm install -g firebase-tools
firebase login
```

### 2. Configurar Proyecto Firebase

```bash
# Inicializar Firebase (ya configurado en firebase.json)
firebase init

# Seleccionar:
# - Firestore
# - Functions
# - Hosting

# Proyecto: crear o seleccionar existente
```

### 3. Configurar Variables de Entorno

```bash
# Copiar template
cp .env.example .env

# Editar .env con tus credenciales reales
# IMPORTANTE: NO commitear .env al repositorio
```

### 4. Instalar Dependencias Functions

```bash
cd functions
npm install
cd ..
```

---

## 🚀 Development

### Ejecutar Emuladores Locales

```bash
# Iniciar todos los emulators
firebase emulators:start

# URLs:
# - Functions: http://localhost:5001
# - Firestore UI: http://localhost:4000
# - Auth: localhost:9099
```

### Test Health Endpoint

```bash
curl http://localhost:5001/empoderate-dev/us-central1/api/health
```

---

## 📦 Deployment

### Build Flutter

```bash
flutter build web --release \
  --dart-define=ENV=prod \
  --dart-define=FIREBASE_API_KEY=$FIREBASE_API_KEY_PROD
```

### Deploy a Firebase

```bash
# Deploy todo
firebase deploy

# Deploy solo Functions
firebase deploy --only functions

# Deploy solo Hosting
firebase deploy --only hosting

# Deploy solo Firestore rules
firebase deploy --only firestore:rules
```

---

## 🔐 Seguridad

### Firestore Security Rules

✅ **Implementadas**:
- Users solo leen/escriben sus propios datos
- Subscriptions y Payments: solo lectura para owners
- AI Usage: solo lectura para owners
- Escritura solo vía Cloud Functions
- Admin access con custom claim

### Variables Sensibles

⚠️ **NUNCA** hardcodear:
- API keys (OpenAI, 2Checkout, PayPal)
- Secrets
- Firebase config

✅ **Usar**:
- Variables de entorno (.env)
- Firebase Config para Functions
- `dart-define` para Flutter

---

## 🔄 Próximos Pasos

### Fase 2: Payment Providers (Pendiente)

```bash
functions/src/payments/
├── providers/
│   ├── twocheckout_provider.ts   🔜 Implementar
│   └── paypal_provider.ts        🔜 Implementar
├── create_checkout.ts            🔜 Endpoint
└── webhook_handler.ts            🔜 Webhook
```

### Fase 3: AI Proxy (Pendiente)

```bash
functions/src/ai/
├── chat_proxy.ts                 🔜 OpenAI proxy
└── rate_limiter.ts               🔜 Rate limiting
```

### Fase 4: Flutter Services (Pendiente)

```bash
lib/services/
├── firebase/
│   ├── auth_service.dart         🔜 Firebase Auth
│   └── firestore_service.dart    🔜 Firestore
├── api_client.dart               🔜 HTTP client
├── analytics_service.dart        🔜 Sentry wrapper
└── payment_service.dart          🔜 Payment integration
```

---

## 📊 Monitoreo

### Firebase Console

1. **Functions**: https://console.firebase.google.com/project/YOUR_PROJECT/functions
2. **Firestore**: https://console.firebase.google.com/project/YOUR_PROJECT/firestore
3. **Auth**: https://console.firebase.google.com/project/YOUR_PROJECT/authentication

### Sentry (cuando esté configurado)

- Dashboard: https://sentry.io/organizations/YOUR_ORG/
- Errors y Performance tracking

---

## 🆘 Troubleshooting

### Functions no despliegan

```bash
# Ver logs
firebase functions:log

# Revisar build
cd functions
npm run build
```

### Firestore rules rechazando requests

```bash
# Test rules en emulator
# Firestore UI: http://localhost:4000
```

### CORS errors

- Configurar en `functions/src/index.ts`
- Agregar dominios permitidos

---

## 📝 Comandos Útiles

```bash
# Ver logs en tiempo real
firebase functions:log --only api

# Eliminar función
firebase functions:delete FUNCTION_NAME

# Listar proyectos
firebase projects:list

# Cambiar proyecto activo
firebase use PROJECT_ID
```

---

## 🎯 Estado Actual

✅ **Completado**:
- Estructura base de carpetas
- Configuración multi-environment
- Cloud Functions base con TypeScript
- Health endpoint
- Auth middleware
- Logger service
- Payment Provider interface
- Firestore security rules
- Firebase config

🔜 **Pendiente** (siguiente sesión):
- Implementación de payment providers (2Checkout, PayPal)
- AI proxy con rate limiting
- Flutter services (Auth, Firestore, API client)
- Sentry integration
- Testing completo
- Deployment a staging/prod

---

**Notas**:
- Todo el código incluye TODOs donde se requiere implementación
- Los placeholders en `.env.example` deben reemplazarse con credenciales reales
- El proyecto está listo para desarrollo local con emulators
- La arquitectura permite escalar agregando más endpoints fácilmente

