# Guía de Despliegue - Empodérate (Hostinger + Firebase)

## 📋 Arquitectura Final

```
empoderate.com (Hostinger)
├── / (landing page/redirect)
└── /blog/ (artículos SEO)

app.empoderate.com (Firebase)
└── / (app Flutter Web)
```

**Importante**: Hostinger maneja TODO el dominio principal. Firebase SOLO maneja el subdominio `app.`.

---

## 🎯 Paso 1: Preparar el Dominio

### 1.1 Comprar el Dominio
1. Ir a [Namecheap](https://namecheap.com) o [GoDaddy](https://godaddy.com)
2. Buscar y comprar: `empoderate.com` (~$12/año)
3. Guardar credenciales de acceso

### 1.2 Apuntar Dominio a Hostinger
1. Ir a tu panel de Hostinger
2. **Hosting > Dominios > Agregar Dominio**
3. Ingresar: `empoderate.com`
4. Copiar los **Nameservers** que te da Hostinger (ejemplo):
   - `ns1.hostinger.com`
   - `ns2.hostinger.com`
5. Ir a tu registrador de dominio (Namecheap/GoDaddy)
6. **Domain Management > Nameservers > Custom**
7. Pegar los nameservers de Hostinger
8. **Guardar** (puede tardar hasta 24 horas)

---

## 📦 Paso 2: Subir Blog a Hostinger

### 2.1 Generar Archivos del Blog
```powershell
# En tu computadora, dentro del proyecto
dart run tools/generate_seo_blog_smart.dart
```

Esto crea archivos en: `web/blog/`

### 2.2 Subir a Hostinger vía FTP

**Opción A: FileZilla (Recomendado)**
1. Descargar [FileZilla](https://filezilla-project.org)
2. Conectar con credenciales de Hostinger:
   - **Host**: ftp.tudominio.com
   - **Usuario**: tu_usuario_ftp
   - **Contraseña**: tu_contraseña
   - **Puerto**: 21
3. En panel derecho, navegar a: `/public_html/`
4. Crear carpeta: `blog`
5. Arrastrar TODOS los archivos de `web/blog/` a `/public_html/blog/`
6. Subir `web/sitemap.xml` a `/public_html/blog/sitemap.xml`

**Opción B: cPanel File Manager**
1. Ir a Hostinger > cPanel > File Manager
2. Navegar a `/public_html/`
3. Crear carpeta `blog`
4. Upload todos los archivos HTML
5. Upload sitemap.xml

### 2.3 Verificar Blog
Abrir en navegador:
- ✅ `https://empoderate.com/blog/`
- ✅ `https://empoderate.com/blog/como-abrir-negocio-panama.html`

---

## 🚀 Paso 3: Desplegar App en Firebase

### 3.1 Build de la App Flutter
```powershell
# En tu proyecto
flutter build web --release --dart-define=ENV=prod
```

Esto genera archivos en: `build/web/`

### 3.2 Desplegar a Firebase
```powershell
# Primera vez: inicializar Firebase
firebase login
firebase init hosting
# Seleccionar: build/web como carpeta

# Desplegar
firebase deploy --only hosting
```

Firebase te dará una URL temporal:
`https://empoderate-prod.web.app`

---

## 🌐 Paso 4: Conectar Dominio Personalizado a Firebase

### 4.1 Agregar Dominio en Firebase Console

1. Ir a [Firebase Console](https://console.firebase.google.com)
2. Seleccionar proyecto: **empoderate-prod**
3. **Hosting** (menú izquierdo)
4. **Add custom domain**
5. Ingresar: `app.empoderate.com`
6. Click **Continue**

### 4.2 Verificar Propiedad (Paso 1 del wizard)

Firebase te mostrará un registro TXT:
```
Tipo: TXT
Nombre: app
Valor: firebase-verification=abc123xyz456...
```

**Configurar en tu Registrador**:
1. Ir a Namecheap/GoDaddy > DNS Management
2. Agregar nuevo record:
   - **Type**: TXT
   - **Host**: `app`
   - **Value**: (el código que te dio Firebase)
   - **TTL**: Automatic
3. **Save**
4. Volver a Firebase > Click **Verify**
   - Si dice "pending", esperar 5-10 minutos y reintentar

### 4.3 Configurar DNS Final (Paso 2 del wizard)

Una vez verificado, Firebase te mostrará records A:
```
Tipo: A
Nombre: app
Valor: 151.101.1.195

Tipo: A
Nombre: app
Valor: 151.101.65.195
```

**Configurar en tu Registrador**:
1. DNS Management
2. Agregar AMBOS records A:
   - **Type**: A
   - **Host**: `app`
   - **Value**: `151.101.1.195`
   - **TTL**: Automatic
   
   Y otro:
   - **Type**: A
   - **Host**: `app`
   - **Value**: `151.101.65.195`
   - **TTL**: Automatic
3. **Save**
4. Volver a Firebase > Click **Finish**

⏳ **Tiempo**: Propagación de DNS puede tardar 1-24 horas.

---

## 🔐 Paso 5: Configurar SSL

### 5.1 SSL en Hostinger (para empoderate.com)
1. Hostinger > SSL/TLS
2. **Install SSL** para `empoderate.com`
3. Seleccionar: **Free SSL (Let's Encrypt)**
4. Esperar 5 minutos

### 5.2 SSL en Firebase (automático)
Firebase activa SSL automáticamente para `app.empoderate.com`
Puede tardar hasta 24 horas.

---

## ⚙️ Paso 6: Configurar Firebase Auth

### 6.1 Authorized Domains
1. Firebase Console > Authentication
2. **Settings** tab
3. **Authorized domains**
4. Agregar:
   - `empoderate.com`
   - `app.empoderate.com`
5. **Save**

**¿Por qué?**: Para que Google Sign-In funcione en ambos dominios.

---

## 🔍 Paso 7: SEO - Registrar en Google

### 7.1 Google Search Console
1. Ir a [Google Search Console](https://search.google.com/search-console)
2. **Add property** > `https://empoderate.com`
3. Verificar propiedad (método DNS o HTML file)
4. Una vez verificado:
   - **Sitemaps** > Add new sitemap
   - URL: `https://empoderate.com/blog/sitemap.xml`
   - **Submit**

### 7.2 Google Analytics (Opcional)
1. Crear cuenta en [Google Analytics](https://analytics.google.com)
2. Agregar property para `empoderate.com`
3. Copiar tracking code
4. Agregar a archivos HTML del blog (en `<head>`)

---

## ✅ Paso 8: Checklist de Verificación

Verificar que TODO funcione:

### URLs Principales
- [ ] `https://empoderate.com` - ✅ Abre (Hostinger)
- [ ] `https://empoderate.com/blog` - ✅ Lista de artículos
- [ ] `https://empoderate.com/blog/como-abrir-negocio-panama.html` - ✅ Artículo individual
- [ ] `https://app.empoderate.com` - ✅ App Flutter (Firebase)

### SSL/HTTPS
- [ ] `https://empoderate.com` - 🔒 SSL activo
- [ ] `https://app.empoderate.com` - 🔒 SSL activo
- [ ] NO hay warnings de "Not Secure"

### Firebase Auth
- [ ] Login con Google funciona en `app.empoderate.com`
- [ ] No hay errores de "unauthorized domain"

### SEO
- [ ] `https://empoderate.com/blog/sitemap.xml` existe
- [ ] Sitemap registrado en Google Search Console
- [ ] Artículos aparecen en búsquedas (toma 1-2 semanas)

### Cross-Domain
- [ ] Links del blog → app funcionan
- [ ] Links del app → blog funcionan

---

## 🆘 Troubleshooting

### "DNS not propagated"
**Solución**: Esperar 24 horas. Verificar en [whatsmydns.net](https://whatsmydns.net)

### "SSL not active in Firebase"
**Solución**: Esperar hasta 24 horas. Firebase activa SSL automáticamente.

### "Blog no carga en Hostinger"
**Solución**: 
1. Verificar archivos en `/public_html/blog/`
2. Verificar permisos (755 para carpetas, 644 para archivos)

### "Firebase Auth error: unauthorized domain"
**Solución**: 
1. Firebase Console > Authentication > Settings
2. Agregar `empoderate.com` y `app.empoderate.com`

### "www no funciona"
**Solución en registrador DNS**:
- Agregar CNAME: `www` → `empoderate.com`

---

## 📝 Resumen Final

**Hostinger maneja**:
- ✅ `empoderate.com` (dominio raíz)
- ✅ `empoderate.com/blog/` (artículos SEO)
- ✅ SSL Let's Encrypt gratis

**Firebase maneja**:
- ✅ `app.empoderate.com` (app Flutter Web)
- ✅ SSL automático
- ✅ Cloud Functions para backend

**Resultado**:
- Blog optimizado para SEO en dominio principal
- App interactiva en subdominio
- Arquitectura profesional escalable

---

## 🚀 Próximos Pasos Opcionales

### Monetización del Blog
1. Aplicar a [Google AdSense](https://adsense.google.com)
2. Agregar código de ads a los HTMLs
3. Meta: 5,000 visitas/mes para aprobación

### Analytics
1. Configurar Google Analytics 4
2. Monitorear tráfico del blog
3. Identificar artículos más visitados

### Contenido
1. Crear 2-3 artículos nuevos por semana
2. Actualizar `initial_articles.dart`
3. Ejecutar `dart run tools/generate_seo_blog_smart.dart`
4. Subir nuevos HTMLs a Hostinger

---

**¿Necesitas ayuda?** Revisa la sección de Troubleshooting o contacta soporte de Hostinger/Firebase.

