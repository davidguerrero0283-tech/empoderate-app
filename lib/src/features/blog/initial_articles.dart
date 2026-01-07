import '../../models/blog_article.dart';

final List<BlogArticle> initialBlogArticles = [
  // 1. Legal y Trámites
  BlogArticle(
    id: 'seed-001',
    title: 'Cómo abrir un negocio formal en Panamá paso a paso',
    subtitle: 'Guía definitiva del Aviso de Operación y trámites municipales',
    description: 'Pasos para abrir tu empresa en Panamá: Aviso de Operación, RUC, Municipio y bancos. Guía práctica y legal.',
    category: 'Legal & Trámites',
    date: DateTime.now().subtract(const Duration(days: 2)),
    imageUrl: 'https://images.unsplash.com/photo-1554224155-8d04cb21cd6c',
    content: '',
    contentRaw: '''
## Introducción
Iniciar un negocio en Panamá es una aventura emocionante, pero la burocracia puede parecer abrumadora al principio. Muchos emprendedores operan en la informalidad por miedo a los trámites, pero formalizarse te abre puertas a créditos bancarios, contratos con el Estado y mayor confianza de tus clientes.

En esta guía, te explicamos paso a paso cómo constituir tu empresa y sacar tu Aviso de Operación sin perder la cabeza en el intento.

## 1. Define tu Figura Legal
Lo primero es decidir si operarás como **Persona Natural** o **Persona Jurídica**.

### Persona Natural (tú mismo)
- **Ventajas:** Rápido, barato, sin gastos de abogados para constituir sociedad.
- **Desventajas:** Tu patrimonio personal responde por las deudas del negocio.
- **Ideal para:** Freelancers, pequeños comercios familiares.

### Persona Jurídica (Sociedad Anónima o S. de R.L.)
- **Ventajas:** Protege tu patrimonio personal. Da una imagen más corporativa.
- **Desventajas:** Requiere abogado, pago de Tasa Única anual (\$300).
- **Ideal para:** Startups, negocios con socios, empresas que buscarán inversión.

## 2. El Aviso de Operación
El Aviso de Operación es la licencia que te permite realizar actividades comerciales.
- **¿Dónde se hace?** En el portal [PanamaEmprende](https://www.panamaemprende.gob.pa).
- **Costo:** Desde \$15 para persona natural y \$55 para jurídica (pagos al Ministerio de Comercio).
- **Requisito:** Tener tu cédula o pasaporte vigente y los datos de la sociedad (si aplica).

## 3. Inscripción en el Municipio
Una vez tienes tu Aviso, debes inscribirte en el Municipio de tu distrito (ej. Panamá, San Miguelito).
- **Plazo:** Tienes pocos días después de sacar el Aviso para evitar multas.
- **Impuestos:** Pagarás impuestos municipales mensuales basados en tus ingresos declarados o una tabla fija.

## 4. La DGI y el RUC
Tu número de RUC (Registro Único de Contribuyente) es tu identificación fiscal.
- Si eres **natural**, es tu cédula con un DV (Dígito Verificador).
- Si eres **jurídico**, es el número de RUC de la sociedad con su DV.
- **Importante:** Debes registrarte en el sistema e-Tax 2.0 para declarar tus impuestos.

## 5. Cuenta Bancaria
No mezcles tus finanzas. Abre una cuenta comercial. Los bancos pedirán:
- Aviso de Operación.
- Pacto Social (si eres jurídico).
- Cédula de los firmantes.
- Proyecciones financieras (a veces).

## Tips Finales
- Guarda copia de todo.
- Contrata a un contador desde el día 1, aunque sea para una consulta inicial.
- No olvides pagar tu Tasa Única si tienes sociedad para mantenerla vigente.

¡Formalizarse es el primer paso para crecer en grande!
''',
    keywords: ['aviso de operación', 'panama emprende', 'ruc', 'legal', 'sociedad anónima'],
    status: 'published',
    isFeatured: true,
    metaTitle: 'Cómo abrir un negocio en Panamá: Guía 2024',
    metaDescription: 'Pasos para abrir tu empresa en Panamá: Aviso de Operación, RUC, Municipio y bancos. Guía práctica y legal.',
    relatedIds: [],
    tags: ['Trámites', 'Legal', 'Emprendimiento'],
    views: 120,
    likes: 15,
  ),

  // 2. Contabilidad & Finanzas
  BlogArticle(
    id: 'seed-002',
    title: 'Guía básica del ITBMS y impuestos para emprendedores',
    subtitle: 'Entiende qué debes pagar y evita multas con la DGI',
    description: 'Aprende cuándo cobrar ITBMS, cómo pagar la renta y evitar multas de la DGI en tu negocio.',
    category: 'Contabilidad & Finanzas',
    date: DateTime.now().subtract(const Duration(days: 5)),
    imageUrl: 'https://images.unsplash.com/photo-1554224155-8d04cb21cd6c',
    content: '',
    contentRaw: '''
## Introducción
El tema impositivo es quizás el que más miedo da a los nuevos empresarios. ¿Qué es el 7%? ¿Cuándo debo cobrarlo? ¿Qué es el CAIR?

No necesitas ser contador para entender lo básico. Aquí te explicamos los impuestos clave en Panamá.

## 1. ITBMS (Impuesto de Transferencia de Bienes Muebles y Servicios)
Es el impuesto al consumo, generalmente del 7% (10% en licores, 15% en tabaco).

### ¿Quiénes deben cobrarlo?
- Si tus ingresos brutos anuales superan los **\$36,000**, es OBLIGATORIO registrarte como contribuyente de ITBMS y cobrarlo.
- Si ganas menos de eso, no estás obligado a cobrarlo (y tampoco puedes deducir el que pagas en tus compras).

### ¿Cómo funciona?
1. Cobras el 7% a tus clientes (Débito Fiscal).
2. Pagas el 7% a tus proveedores (Crédito Fiscal).
3. Le pagas a la DGI la diferencia cada mes (Presentación mensual).

## 2. Impuesto Sobre la Renta (ISR)
Es el impuesto sobre tus ganancias netas (Ingresos - Gastos Deducibles).
- Se declara anualmente (antes del 15 de marzo, generalmente).
- **Persona Jurídica:** Paga 25% sobre la renta neta gravable. (O cálculo alterno CAIR si facturas más de \$1.5M).
- **Persona Natural:** Tiene tasas progresivas y una exención sobre los primeros \$11,000.

## 3. Impuesto Municipal
Se paga al municipio donde operas. Varía según tu actividad. Es un gasto deducible de tu ISR.

## 4. Seguro Educativo y CSS
Si tienes empleados (o te pones salario como dueño), debes pagar las cuotas obrero-patronales.

## Errores Comunes
- **Gastar el ITBMS:** El dinero del 7% NO es tuyo. Es del Estado. No lo uses para pagar luz o mercancía. Guárdalo aparte.
- **No pedir facturas:** Si no tienes factura fiscal con RUC a tu nombre, no puedes deducir ese gasto.
- **Presentar tarde:** Las multas por presentación tardía son evitables.

## Resumen
La clave es el orden. Usa un software contable o una hoja de cálculo y apóyate en nuestras herramientas de IA Contable para resolver dudas puntuales.
''',
    keywords: ['itbms', 'impuestos', 'dgi', 'renta', 'contabilidad'],
    status: 'published',
    isFeatured: true,
    metaTitle: 'Guía de ITBMS e Impuestos Panamá',
    metaDescription: 'Aprende cuándo cobrar ITBMS, cómo pagar la renta y evitar multas de la DGI en tu negocio.',
    relatedIds: [],
    tags: ['Finanzas', 'Impuestos', 'Contabilidad'],
    views: 95,
    likes: 12,
  ),

  // 3. Gestión Empresarial
  BlogArticle(
    id: 'seed-003',
    title: 'Cómo fijar precios correctamente para ganar dinero',
    subtitle: 'Deja de adivinar y empieza a calcular tus márgenes',
    description: 'Aprende la fórmula para fijar precios ganadores, diferenciar margen de mark-up y calcular tu punto de equilibrio.',
    category: 'Gestión Empresarial',
    date: DateTime.now().subtract(const Duration(days: 8)),
    imageUrl: 'https://images.unsplash.com/photo-1591696205602-2f950c417cb9',
    content: '',
    contentRaw: '''
## Introducción
¿Pones precios mirando a la competencia o multiplicando por 2? Es uno de los errores más graves. Si no conoces tus costos reales, puedes estar perdiendo dinero con cada venta.

## 1. La Diferencia entre Costo, Precio y Valor
- **Costo:** Lo que te cuesta producir el producto (materiales + mano de obra) o comprarlo.
- **Precio:** Lo que cobras al cliente.
- **Valor:** Lo que el cliente PERCIBE que vale tu producto (aquí entran la marca, el servicio, la urgencia).

## 2. Estructura de Costos
No olvides los **Costos Fijos** (luz, alquiler, internet, tu salario). Estos deben repartirse entre las unidades vendidas.

`Costo Total Unitario = Costo Variable Unitario + (Costos Fijos Totales / Unidades Estimadas)`

## 3. Margen de Ganancia vs. Mark-up
- **Mark-up:** Sobreprecio que añades al costo. Costo \$10 + 50% = Precio \$15.
- **Margen:** Porcentaje real de ganancia sobre el precio. En el ejemplo anterior, ganaste \$5 sobre \$15, tu margen es 33%, no 50%.

Fórmula recomendada para Precio:
`Precio = Costo / (1 - %Margen Deseado)`

Ejemplo: Quieres ganar 30% de margen sobre algo que cuesta \$70.
`70 / (1 - 0.30) = 70 / 0.70 = \$100`

## 4. Estrategias de Precios
- **Costo Plus:** Costo + margen fijo. Seguro pero básico.
- **Basado en Competencia:** Te alineas al mercado. Peligroso si tus costos son más altos.
- **Basado en Valor:** Cobras por el problema que resuelves. El más rentable, pero requiere marketing fuerte.

## 5. El Punto de Equilibrio
Es cuántas unidades debes vender para no perder ni ganar.
`PE = Costos Fijos Totales / (Precio Venta - Costo Variable Unitario)`

Conoce este número. Es tu primera meta del mes.

## Conclusión
Fijar precios es matemático y psicológico. Usa nuestra **Calculadora de Punto de Equilibrio** en la sección de Herramientas para ayudarte.
''',
    keywords: ['precios', 'costos', 'margen', 'ganancia', 'punto equilibrio'],
    status: 'published',
    isFeatured: true, // Key article
    metaTitle: 'Cómo fijar precios y márgenes correctos',
    metaDescription: 'Aprende la fórmula para fijar precios ganadores, diferenciar margen de mark-up y calcular tu punto de equilibrio.',
    relatedIds: [],
    tags: ['Estrategia', 'Ventas', 'Gestión'],
    views: 88,
    likes: 20,
  ),

  // 4. Recursos Humanos
  BlogArticle(
    id: 'seed-004',
    title: 'Cómo llevar tu primera planilla sin volverte loco',
    subtitle: 'CSS, Seguro Educativo y todo lo que debes descontar',
    description: 'Aprende a calcular salario neto, seguro social, educativo y décimo tercer mes para tus empleados.',
    category: 'Recursos Humanos',
    date: DateTime.now().subtract(const Duration(days: 10)),
    imageUrl: 'https://images.unsplash.com/photo-1521791136064-7986c2920216',
    content: '',
    contentRaw: '''
## Introducción
Contrataste a alguien. ¡Felicidades! Ahora eres responsable de retener y pagar sus prestaciones. En Panamá, la ley laboral protege mucho al trabajador, y los errores salen caros.

## Descuentos al Empleado (Deducciones)
Esto se le quita al trabajador de su salario bruto:
1. **Seguro Social (CSS):** 9.75%.
2. **Seguro Educativo (SE):** 1.25%.
3. **Impuesto Sobre la Renta (ISR):** Solo si gana más de \$11,000 al año (aprox \$846/mes netos gravables).

## Aportes del Patrono (Tus costos extra)
Esto lo pagas tú ADEMÁS del salario:
1. **Seguro Social Patronal:** 12.25%.
2. **Seguro Educativo Patronal:** 1.50%.
3. **Riesgos Profesionales:** Varía según la actividad (aprox 0.98% - 5.67%).

## Prestaciones y Provisiones
No te gastes todo el dinero. Debes "guardar" mensualmente para pagar:
- **Décimo Tercer Mes:** Un salario extra al año, pagado en 3 partes (abril, agosto, diciembre). Provisión mensual: 8.33%.
- **Vacaciones:** 30 días por año. Provisión mensual: 9.09%.
- **Prima de Antigüedad:** 1 semana de salario por año trabajado. Provisión: 1.92%.
- **Indemnización (por si acaso):** Provisión opcional pero recomendada.

## El SIPE
El Sistema de Ingresos y Prestaciones Económicas de la CSS es donde reportas tu planilla mensualmente. Debes inscribirte como patrono para obtener tu clave.

## Checklist Mensual
1. Calcular horas trabajadas y extras.
2. Aplicar deducciones.
3. Pagar salario neto (quincenal o mensual).
4. Subir planilla al SIPE.
5. Pagar al banco la planilla SIPE.

Tip: Usa nuestra **Calculadora de Salario Neto** para hacer estos cálculos en segundos.
''',
    keywords: ['planilla', 'css', 'sipe', 'salario', 'prestaciones'],
    status: 'published',
    isFeatured: false,
    metaTitle: 'Guía de Planilla y CSS en Panamá',
    metaDescription: 'Aprende a calcular salario neto, seguro social, educativo y décimo tercer mes para tus empleados.',
    relatedIds: [],
    tags: ['RRHH', 'Planilla', 'Ley Laboral'],
    views: 70,
    likes: 10,
  ),

  // 5. Finanzas
  BlogArticle(
    id: 'seed-005',
    title: '7 errores comunes al manejar el dinero de tu negocio',
    subtitle: 'Por qué quiebran las empresas rentables',
    description: 'Evita mezclar finanzas personales, dar crédito excesivo y otros errores que quiebran negocios.',
    category: 'Finanzas',
    date: DateTime.now().subtract(const Duration(days: 12)),
    imageUrl: 'https://images.unsplash.com/photo-1579621970563-ebec7560ff3e',
    content: '',
    contentRaw: '''
## Introducción
Hay negocios que venden mucho pero nunca tienen dinero en el banco. ¿Por qué? La mala administración financiera. Aquí los 7 pecados capitales.

## 1. Caja Chica Personal
Usar la cuenta del negocio para el súper, la gasolina del auto personal o la cena del sábado.
**Solución:** Ponte un sueldo fijo y vive de eso.

## 2. No conocer tu Margen Real
Creer que ganas dinero cuando en realidad, después de gastos operativos, pierdes.
**Solución:** Revisa tu estructura de costos trimestralmente.

## 3. Mal Manejo del Crédito
Dar mucho crédito a clientes (cobrar a 60 días) pero pagar a proveedores al contado (a 0 días). Te quedarás sin liquidez.
**Solución:** Negocia plazos con proveedores que calcen con tus cobros.

## 4. Inventario Estancado
Tener mercancía que no se vende es dinero parado acumulando polvo.
**Solución:** Remata lo viejo, libera cash.

## 5. Ignorar los Impuestos
Gastarse el ITBMS o no guardar para la Renta. Cuando llega marzo, toca pedir préstamo para pagar impuestos.
**Solución:** Cuenta de ahorro separada para impuestos.

## 6. Crecer muy rápido sin capital
Aceptar un pedido gigante sin tener dinero para producirlo puede quebrarte (morir de éxito).
**Solución:** Planifica tu flujo de caja antes de aceptar grandes contratos.

## 7. No tener Fondo de Emergencia
Cualquier imprevisto (pandemia, daño de equipo) te saca del juego.
**Solución:** Intenta guardar 3 meses de gastos fijos.

La disciplina financiera es más importante que las ventas explosivas.
''',
    keywords: ['errores financieros', 'flujo de caja', 'dinero', 'quiebra'],
    status: 'published',
    isFeatured: false,
    metaTitle: '7 Errores Financieros Comunes',
    metaDescription: 'Evita mezclar finanzas personales, dar crédito excesivo y otros errores que quiebran negocios.',
    relatedIds: [],
    tags: ['Finanzas', 'Consejos', 'Gestión'],
    views: 110,
    likes: 25,
  ),

  // 6. Marketing & Ventas
  BlogArticle(
    id: 'seed-006',
    title: 'Introducción al marketing digital para pequeños negocios',
    subtitle: 'Cómo vender online sin ser experto',
    description: 'Estrategias sencillas de marketing digital, redes sociales y embudos de venta para pequeños negocios.',
    category: 'Marketing & Ventas',
    date: DateTime.now().subtract(const Duration(days: 15)),
    imageUrl: 'https://images.unsplash.com/photo-1432888498266-38ffec3eaf0a',
    content: '',
    contentRaw: '''
## Introducción
El marketing digital no es solo "postear en Instagram". Es un sistema para atraer desconocidos y convertirlos en clientes.

## 1. Conoce a tu Cliente Ideal (Buyer Persona)
No puedes venderle a "todo el mundo". Define:
- ¿Qué edad tiene?
- ¿Qué le duele o preocupa?
- ¿Qué red social usa más?

## 2. El Embudo Básico (AIDA)
- **Atención:** Que te vean (Reels, Ads, SEO).
- **Interés:** Que les guste lo que ven (Contenido de valor, tips).
- **Deseo:** Que quieran tu solución (Testimonios, ofertas).
- **Acción:** Que compren (Botón de WhatsApp, Link de pago).

## 3. Redes Sociales
- **Instagram:** Visual, lifestyle, productos.
- **LinkedIn:** B2B, servicios profesionales.
- **TikTok:** Alcance viral rápido, público joven.
Elige 1 o 2 y sé constante. Mejor una bien hecha que 5 abandonadas.

## 4. Google My Business
Si tienes local físico, esto es OBLIGATORIO. Es gratis y hace que aparezcas en Google Maps cuando alguien busca tu servicio cerca.

## 5. La Base de Datos
Las redes sociales no son tuyas. Si Instagram cierra mañana, ¿pierdes tus clientes?
Intenta captar correos o teléfonos (con permiso) para hacer Email Marketing o listas de difusión de WhatsApp.

## 6. Publicidad Pagada (Ads)
El alcance orgánico es bajo. Invertir \$5 o \$10 en pauta bien segmentada puede traer retornos grandes. No uses el botón "Promocionar" a lo loco; aprende a usar el Administrador de Anuncios.

Empieza hoy. Tu cliente te está buscando en el celular.
''',
    keywords: ['marketing digital', 'redes sociales', 'ventas', 'instagram'],
    status: 'published',
    isFeatured: false,
    metaTitle: 'Marketing Digital Básico para Pymes',
    metaDescription: 'Estrategias sencillas de marketing digital, redes sociales y embudos de venta para pequeños negocios.',
    relatedIds: [],
    tags: ['Marketing', 'Digital', 'Ventas'],
    views: 150,
    likes: 40,
  ),

  // 7. Marketing & Ventas
  BlogArticle(
    id: 'seed-007',
    title: 'Cómo crear una marca profesional aunque estés empezando',
    subtitle: 'Branding es más que un logo bonito',
    description: 'Consejos de branding, identidad visual y coherencia para que tu negocio luzca profesional desde el día 1.',
    category: 'Marketing & Ventas',
    date: DateTime.now().subtract(const Duration(days: 18)),
    imageUrl: 'https://images.unsplash.com/photo-1542744173-8e7e53415bb0',
    content: '',
    contentRaw: '''
## Introducción
Tu marca es lo que dicen de ti cuando no estás en la sala. Es la personalidad de tu negocio. Una buena marca genera confianza, y la confianza genera ventas.

## 1. Identidad Visual
Evita usar ClipArt o logos generados por IA que se vean genéricos.
- **Logo:** Simple, legible en pequeño (foto de perfil) y en grande.
- **Paleta de Colores:** Escoge 2-3 colores y USALOS SIEMPRE. La consistencia crea recordación (ej. el rojo de Coca-Cola).
- **Tipografía:** No uses más de 2 fuentes. Una para títulos, una para texto.

## 2. Voz y Tono
¿Cómo habla tu marca?
- ¿Es seria y corporativa? (Abogados, Contadores)
- ¿Es divertida y juvenil? (Ropa, Comida rápida)
- ¿Es inspiradora y motivadora? (Gym, Coach)
Define tu voz y úsala en todos tus posts, correos y atención al cliente.

## 3. Coherencia en todos los puntos de contacto
Tu perfil de Instagram, tu tarjeta de presentación, tu factura y tu uniforme deben verse "de la misma familia". Si tu logo es azul y tu Instagram es rosado, confundes al cliente.

## 4. La Promesa de Marca
¿Qué garantizas? ¿Rapidez? ¿Calidad premium? ¿El precio más bajo?
Tu marca visual atrae, pero cumplir tu promesa es lo que fideliza.

## Herramientas Gratuitas
- **Canva:** Para diseño básico (usa plantillas, pero personalízalas con tus colores).
- **Coolors.co:** Para generar paletas de colores.
- **Unsplash/Pexels:** Fotos de stock de alta calidad gratis.

Invierte tiempo en tu marca. Es el activo más valioso a largo plazo.
''',
    keywords: ['branding', 'marca', 'logo', 'diseño'],
    status: 'published',
    isFeatured: false,
    metaTitle: 'Creación de Marca Profesional',
    metaDescription: 'Consejos de branding, identidad visual y coherencia para que tu negocio luzca profesional desde el día 1.',
    relatedIds: [],
    tags: ['Marketing', 'Branding', 'Diseño'],
    views: 85,
    likes: 18,
  ),

  // 8. Recursos Humanos
  BlogArticle(
    id: 'seed-008',
    title: 'Checklist básico antes de contratar a tu primer colaborador',
    subtitle: 'Evita demandas laborales blindando tu contratación',
    description: 'Pasos legales para contratar: contrato escrito, periodo de prueba, CSS y Mitradel.',
    category: 'Recursos Humanos',
    date: DateTime.now().subtract(const Duration(days: 20)),
    imageUrl: 'https://images.unsplash.com/photo-1551836022-d5d88e9218df',
    content: '',
    contentRaw: '''
## Introducción
Contratar es un gran paso, pero hacerlo "de boca" es un riesgo enorme. En Panamá, la relación laboral se presume aunque no haya papeles, y sin contrato escrito, las condiciones se presumen ciertas según lo que diga el trabajador.

## Checklist de Contratación

### 1. Definir el Perfil y Salario
- ¿Qué hará exactamente? Escribe las funciones.
- ¿Cuánto puedes pagar? Recuerda sumar el ~30-40% de carga prestacional al salario base.

### 2. El Contrato de Trabajo Escrito
Debe tener:
- Generales (nombre, cédula, dirección).
- Tipo de contrato: **Indefinido** (permanente) o **Definido** (por tiempo específico, solo válido en ciertos casos).
- Periodo de prueba: Máximo 3 meses (debe estar ESCRITO para ser válido).
- Salario, horario y lugar de trabajo.

### 3. Registro en el Ministerio de Trabajo (Mitradel)
El contrato debe sellarse en el Mitradel. Ahora se puede hacer digitalmente.

### 4. Afiliación a la CSS
Debes inscribir al empleado en la CSS (Aviso de Entrada) en los primeros días. Si no lo haces y se enferma o accidenta, la responsabilidad recae 100% en ti.

### 5. Expediente del Colaborador
Crea una carpeta (física o digital) con:
- Copia de cédula.
- Hoja de vida y referencias verificadas.
- Contrato sellado.
- Recibos de pago firmados (si pagas en cheque/efectivo).
- Amonestaciones o evaluaciones (documenta todo).

## Reglamento Interno
Si tienes más de 10 empleados (comercial) o 20 (industrial), es obligatorio tener un Reglamento Interno de Trabajo aprobado por Mitradel. Si tienes menos, igual es recomendable tener políticas claras.

Contrata lento, despide rápido (si es necesario y legal), pero siempre documenta todo.
''',
    keywords: ['contratación', 'contrato', 'mitradel', 'empleados', 'ley laboral'],
    status: 'published',
    isFeatured: false,
    metaTitle: 'Checklist para Contratar Personal',
    metaDescription: 'Pasos legales para contratar: contrato escrito, periodo de prueba, CSS y Mitradel.',
    relatedIds: [],
    tags: ['RRHH', 'Legal', 'Gestión'],
    views: 65,
    likes: 8,
  ),

  // 9. Gestión Empresarial
  BlogArticle(
    id: 'seed-009',
    title: 'Cómo organizar los papeles y documentos de tu negocio',
    subtitle: 'El orden administrativo te ahorra dinero y estrés',
    description: 'Cómo archivar documentos físicos y digitales. Estructura de carpetas y buenas prácticas de respaldo.',
    category: 'Gestión Empresarial',
    date: DateTime.now().subtract(const Duration(days: 25)),
    imageUrl: 'https://images.unsplash.com/photo-1544396821-4dd40b938ad3',
    content: '',
    contentRaw: '''
## Introducción
¿Dónde está la factura de la computadora que compraste hace 6 meses? ¿Y el pacto social? Si tardas más de 2 minutos en encontrar un documento clave, tienes un problema de organización.

## 1. La Bóveda Física
Ten archivadores (AZ) físicos para lo legal original:
- Pacto Soical, Aviso de Operación, RUC.
- Contratos firmados en original.
- Chequeras y documentos bancarios.

## 2. La Bóveda Digital (Cloud)
El papel se moja, se quema o se pierde. Digitaliza TODO.
- Usa Google Drive, Dropbox o nuestra **Bóveda Digital** en la app.
- Estructura de carpetas sugerida:
  - 01_Legal (Pacto, Aviso, Cédulas socios)
  - 02_Contabilidad (Facturas Compras, Ventas, Estados Financieros)
  - 03_RRHH (Expedientes empleados, Planillas)
  - 04_Bancos (Estados de cuenta)
  - 05_Operativo (Manuales, proveedores)

## 3. Rutina de Escaneo
No acumules papeles.
- **Facturas de gastos:** Escanéalas o tómales foto apenas las recibes (el papel térmico se borra).
- **Trámites:** Si entregas un papel, quédate con el recibido escaneado.

## 4. Facturación
Si usas facturador fiscal o electrónica, asegúrate de hacer los reportes Z y guardarlos. Si usas Factura Electrónica, descarga los XML y PDF mensualmente.

## 5. Backups
Tus datos son tu negocio. Haz backup de tu computadora y de tu nube regularmente.

El orden administrativo facilita la contabilidad, te protege en auditorías y agiliza la toma de decisiones.
''',
    keywords: ['organización', 'documentos', 'archivo', 'digitalización', 'bóveda'],
    status: 'published',
    isFeatured: false,
    metaTitle: 'Organización Documental para Negocios',
    metaDescription: 'Cómo archivar documentos físicos y digitales. Estructura de carpetas y buenas prácticas de respaldo.',
    relatedIds: [],
    tags: ['Gestión', 'Productividad', 'Tips'],
    views: 60,
    likes: 15,
  ),

  // 10. Finanzas
  BlogArticle(
    id: 'seed-010',
    title: 'Qué es el flujo de caja y por qué puede salvar tu negocio',
    subtitle: 'Cash is King: Aprende a gestionarlo',
    description: 'Entiende la diferencia entre utilidad y flujo de caja, y cómo gestionar la liquidez para no quedarte sin efectivo.',
    category: 'Finanzas',
    date: DateTime.now().subtract(const Duration(days: 28)),
    imageUrl: 'https://images.unsplash.com/photo-1628348068343-c6a848d2b6dd',
    content: '',
    contentRaw: '''
## Introducción
Un negocio puede ser "rentable" en papeles (facturó mucho) y quebrar mañana porque no tiene efectivo para pagar la nómina. Eso es un problema de flujo de caja.

## ¿Qué es el Flujo de Caja (Cash Flow)?
Es el registro de las **Entradas** (dinero que realmente entra) y **Salidas** (dinero que realmente sale) de efectivo en un periodo.

`Flujo Neto = Entradas - Salidas`

## Diferencia con el Estado de Resultados
- **Estado de Resultados:** Dice "Vendí \$1,000". (Aunque me los paguen en 90 días).
- **Flujo de Caja:** Dice "Entraron \$0 hoy". (Porque la venta fue a crédito).

## La Trampa del "Gap" Financiero
Si pagas a tus proveedores a 15 días, pero cobras a tus clientes a 30 días, tienes 15 días donde te falta dinero. Ese hueco debes cubrirlo con capital propio o financiamiento.

## Cómo Mejorar tu Flujo de Caja
1. **Cobra Rápido:** Incentiva el pago de contado (descuentos pronto pago). Pide anticipos del 50%.
2. **Paga Lento (Estratégicamente):** Negocia más días de crédito con proveedores sin dañar la relación.
3. **Controla Inventarios:** No compres de más.
4. **Reduce Gastos Fijos innecesarios:** Revisa suscripciones y gastos hormiga.

## Proyecta tu Flujo (Forecast)
No mires solo el hoy. Proyecta las próximas 4-12 semanas.
"En la semana 3 toca pagar alquiler y nómina, y según mis cobros estimados, me faltarán \$500".
Saberlo hoy te permite actuar (pedir crédito, acelerar cobros) antes de que llegue la crisis.

El efectivo es el oxígeno de tu negocio. Cuídalo.
''',
    keywords: ['flujo de caja', 'cash flow', 'liquidez', 'finanzas'],
    status: 'published',
    isFeatured: false,
    metaTitle: 'Guía de Flujo de Caja',
    metaDescription: 'Entiende la diferencia entre utilidad y flujo de caja, y cómo gestionar la liquidez para no quedarte sin efectivo.',
    relatedIds: [],
    tags: ['Finanzas', 'Tesorería', 'Gestión'],
    views: 130,
    likes: 35,
  ),
];
