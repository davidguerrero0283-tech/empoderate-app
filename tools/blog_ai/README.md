# Blog AI Generator - Empodérate

Generador de artículos de blog SEO-optimizados usando Gemini API.

## Requisitos

- Dart SDK instalado
- API Key de Gemini (obtener en [AI Studio](https://aistudio.google.com/apikey))

## Configuración

### 1. Obtener API Key

1. Ve a [AI Studio](https://aistudio.google.com/apikey)
2. Crea una nueva API key
3. Copia la key

### 2. Variables de Entorno (Opcionales)

El generador soporta configuración avanzada para evitar límites de cuota (error 429):

| Variable | Descripción | Valor por Defecto |
|----------|-------------|-------------------|
| `GEMINI_API_KEY` | **Requerida**. Tu API Key. | - |
| `GEMINI_MODEL` | Modelo inicial a utilizar. | `gemini-1.5-flash` |
| `GEMINI_MAX_OUTPUT_TOKENS` | Límite de tokens por respuesta. | `1800` |

**Ejemplo Windows PowerShell:**
```powershell
$env:GEMINI_API_KEY="tu-api-key-aqui"
$env:GEMINI_MODEL="gemini-1.5-flash"
$env:GEMINI_MAX_OUTPUT_TOKENS="1800"
```

### 3. Descubrimiento de Modelos (Opcional)

Puedes ver qué modelos reales tienes disponibles en tu proyecto:
```bash
dart run tools/blog_ai/list_models.dart
```

## Uso

### Generar Artículos

```bash
# Generar 1 artículo (el sistema elige el mejor modelo disponible)
dart run tools/blog_ai/generate_ai_articles.dart -- --count=1

# Forzar un modelo específico
$env:GEMINI_MODEL="gemini-1.5-flash"
dart run tools/blog_ai/generate_ai_articles.dart -- --count 1
```

## Manejo de Rate Limiting y 404

El generador incluye un sistema inteligente de auto-gestión:

1. **Auto-Discovery**: Al iniciar, el cliente consulta la lista de modelos disponibles para evitar errores `404 Not Found`.
2. **Auto-Selection**: Si no se especifica un modelo (o el especificado es inválido), se elige automáticamente el mejor disponible (`flash` > `pro`).
3. **Retry Delay Dinámico**: Si la API responde con un retraso sugerido, el script lo respeta.
4. **Model Fallback**: Si un modelo indica `limit: 0` (quota agotada), se cambia automáticamente al siguiente modelo funcional de la lista descubierta.
4. **Throttling**: Aplica una pausa aleatoria de 1.5s a 2.5s entre cada artículo para respetar los límites de RPM (Requests Per Minute).
5. **Fallback Template**: Solo si todos los reintentos fallan, se genera un borrador básico basado en una plantilla para no perder el progreso.

## Pipeline Automatizado (Local)

El script `pipeline.dart` permite ejecutar todo el flujo (Generar -> Aprobar -> Importar) con un solo comando.

### Uso del Pipeline

```bash
# Ejecución básica (Genera 1, aprueba e importa)
dart run tools/blog_ai/pipeline.dart -- --count=1

# Ejecución avanzada (Genera 3, sin auto-aprobar, sin build web)
dart run tools/blog_ai/pipeline.dart -- --count=3 --auto-approve=false --build-web=false

# Flujo completo con reconstrucción web
dart run tools/blog_ai/pipeline.dart -- --count=1 --auto-approve=true --build-web=true
```

### Argumentos de Pipeline

| Argumento | Descripción | Default |
|-----------|-------------|---------|
| `--count` | Cantidad de artículos a generar. | `1` |
| `--auto-approve` | Marca los nuevos drafts como `approved=true` automáticamente. | `true` |
| `--build-web` | Ejecuta `flutter build web` al finalizar (requiere entorno Flutter). | `false` |

---

## Estructura de Salida

Cada artículo genera dos archivos en `blog_drafts/`:
- `<slug>.md`: Contenido en Markdown con frontmatter.
- `<slug>.json`: Metadatos completos en JSON.
- `_index.json`: Índice global de todos los borradores generados.

## Guardrails Incluidos

- ✅ Disclaimer legal automático al final.
- ✅ No da consejos legales/contables como definitivos.
- ✅ Estructura SEO con H2, listas, FAQ.
- ✅ Reintento de parseo: Si la IA devuelve un JSON inválido, se reintenta una vez con instrucciones más estrictas.
