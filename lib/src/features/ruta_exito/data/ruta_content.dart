import 'package:flutter/material.dart';
import '../models/ruta_step.dart';

final List<RutaPhase> rutaPhases = [
  // FASE 1: LEGALIZAR
  RutaPhase(
    id: 1,
    title: 'Fase 1: Legalizar',
    subtitle: 'Formaliza tu negocio',
    color: 0xFFD4AF37, // Gold
    steps: [
      RutaStep(
        id: 1,
        title: 'Elegir tipo de negocio',
        description: 'Servicios, Comercio o Manufactura',
        content: '''Elegir tu tipo de negocio es la decisión más importante. En Panamá, existen tres grandes categorías: Servicios (consultoría, reparaciones, educación), Comercio (venta de productos propios o de terceros), y Manufactura (producción de bienes).

Para DECIDIR, pregúntate: ¿Qué problema resolverás? ¿A quién le venderás? ¿Tienes las habilidades necesarias? Un error común es intentar "vender de todo" sin un enfoque claro.

EJEMPLO: Si eres experto en marketing digital, tu negocio de servicios podría ser "Consultoría de Redes Sociales para PYMEs". Si te gusta la repostería, un negocio de manufactura sería "Pasteles Personalizados".

PRO TIP: Valida tu idea con 5 clientes potenciales ANTES de gastar dinero. Pregúntales si pagarían por tu solución.''',
      ),
      RutaStep(
        id: 2,
        title: 'Crear RUC',
        description: 'Registro tributario en DGI',
        content: '''El RUC (Registro Único de Contribuyente) es tu cédula tributaria. Sin él, no puedes facturar legalmente ni abrir cuentas bancarias comerciales.

PARA OBTENERLO: Ve a la DGI (Dirección General de Ingresos) con tu cédula, llena el formulario, y define si serás Persona Natural (tú como individuo) o Persona Jurídica (sociedad anónima). La mayoría de emprendedores inician como Persona Natural.

COSTO: Gratis. TIEMPO: 1-3 días hábiles.

ERROR COMÚN: No registrarte como contribuyente desde el inicio. Esto te impedirá deducir gastos del negocio y generar facturas válidas.

PRO TIP: Si facturas más de B/.36,000 anuales, el ITBMS (impuesto) será obligatorio. Consulta con un contador desd el día 1.''',
      ),
      RutaStep(
        id: 3,
        title: 'Aviso de Operación',
        description: 'Permiso comercial oficial',
        content: '''El Aviso de Operación es tu permiso legal para operar comercialmente en Panamá. Es OBLIGATORIO para cualquier negocio físico o digital que venda productos o servicios.

DÓNDE TRAMITARLO: En PanamaEmprende (Ministerio de Comercio) o en línea en su portal. Necesitas: RUC, cédula, descripción de actividad comercial, y ubicación del negocio.

COSTO: Varía según el tipo de actividad (B/.50-B/.200). TIEMPO: 5-10 días hábiles.

IMPORTANTE: Sin este aviso, no puedes obtener otros permisos (municipales, sanitarios) ni participar en licitaciones públicas.

ERROR COMÚN: Confundirlo con el "Aviso de Funcionamiento" municipal (ese es otro trámite local).

PRO TIP: Algunos rubros requieren permisos adicionales (alimentos = Minsa, bebidas = Aupsa). Investiga ANTES de abrir.''',
      ),
      RutaStep(
        id: 4,
        title: 'Permisos municipales',
        description: 'Registro en tu alcaldía',
        content: '''Cada municipio (alcaldía) en Panamá exige permisos locales para operar. Esto incluye: Aviso de Funcionamiento, Paz y Salvo Municipal, y pago del impuesto de Anuncio (si tienes rótulo).

PROCESO: Ve a tu alcaldía local con el Aviso de Operación nacional, RUC, y comprobante de domicilio del negocio. Te asignarán un inspector para verificar que cumples con normas de seguridad y zonificación.

COSTO: B/.25-B/.100 anuales dependiendo del municipio. TIEMPO: 7-15 días.

ERROR COMÚN: Operar sin estos permisos te expone a multas de hasta B/.500 y cierre temporal.

PRO TIP: Si trabajas desde casa, verifica que tu zona residencial permita actividades comerciales (zonificación). Algunos municipios lo prohíben.''',
      ),
      RutaStep(
        id: 5,
        title: 'Paz y Salvo',
        description: 'Certificado de solvencia',
        content: '''El "Paz y Salvo" es un certificado que prueba que NO tienes deudas con el Estado (municipio, DGI, CSS). Es requisito para: renovar licencias, participar en licitaciones, vender el negocio, o cerrar la empresa.

DÓNDE OBTENERLO: En la alcaldía (municipal) y en la DGI (nacional). Debes estar al día con TODOS tus pagos de impuestos.

COSTO: Gratis si estás solvente. Si tienes deudas, debes pagarlas primero.

IMPORTANTE: Solicítalo al menos 1 vez al año para verificar que no tengas deudas acumuladas por error del sistema.

ERROR COMÚN: Ignorar pequeñas deudas que crecen con intereses. Un atraso de B/.50 puede convertirse en B/.200 en 2 años.

PRO TIP: Usa recordatorios automáticos (calendario) para pagar impuestos antes de las fechas límite.''',
      ),
      RutaStep(
        id: 6,
        title: 'Registro DGI',
        description: 'Configura tus impuestos',
        content: '''El Registro en la DGI va más allá del RUC. Debes entender tus obligaciones fiscales: ITBMS (Impuesto de Transferencia de Bienes Muebles y Servicios), ISR (Impuesto sobre la Renta), y Aviso de Operación fiscal.

PROCESO: Después de obtener el RUC, declara tu actividad económica y decide tu régimen tributario. La DGI te asignará un código CIIU (clasificación industrial).

OBLIGACIONES COMUNES:
- Declaración mensual de ITBMS (si facturas +B/.36k/año)
- Declaración anual de Renta (ISR) en marzo
- Mantener facturas y comprobantes por 5 años

ERROR COMÚN: No emitir facturas autorizadas. Solo las facturas DGI son deducibles.

PRO TIP: Usa un software de facturación electrónica desde el día 1. La DGI está migrando todo a digital.''',
        toolRoute: '/accounting/tax_estimator',
        toolLabel: 'Calcular Impuestos',
      ),
      RutaStep(
        id: 7,
        title: 'Cuenta bancaria comercial',
        description: 'Separa finanzas del negocio',
        content: '''Separar las finanzas personales de las del negocio es CRÍTICO. Una cuenta bancaria comercial te permite: rastrear ingresos/gastos, solicitar créditos empresariales, y demostrar solvencia ante proveedores.

REQUISITOS: RUC, cédula, Aviso de Operación, paz y salvo municipal. Algunos bancos piden depósito inicial (B/.100-B/.500).

BANCOS EN PANAMÁ: Banco General, Banistmo, BAC, Caja de Ahorros. Compara comisiones de mantenimiento y límites de transacciones.

ERROR MORTAL: Mezclar gastos personales con los del negocio. Esto arruina tu contabilidad y dificulta detectar si estás perdiendo dinero.

PRO TIP: Configura transferencias automáticas para pagar impuestos (DGI, CSS) cada mes. Así nunca olvidarás una fecha límite.''',
        toolRoute: '/accounting/cash_flow',
        toolLabel: 'Ir a Flujo de Caja',
      ),
      RutaStep(
        id: 8,
        title: 'Caja de Seguro Social',
        description: 'Registro patronal (si tienes empleados)',
        content: '''La CSS (Caja de Seguro Social) es OBLIGATORIA si tienes empleados. Como patrono, debes inscribirte y pagar cuotas mensuales (seguro social + riesgo profesional).

PROCESO: Ve a la CSS con RUC, Aviso de Operación, y lista de empleados. Te asignarán un número patronal. Cuota: ~12.25% del salario bruto del empleado (tú pagas 12.25%, el empleado paga 9.75%).

IMPORTANTE: Incluye a TODOS tus empleados desde el día 1, incluso familiares. No hacerlo es ilegal y genera multas de hasta B/.5,000.

¿Y SI TRABAJAS SOLO? Puedes inscribirte como trabajador independiente (voluntario) para tener cobertura de salud.

ERROR COMÚN: Contratar "por fuera" sin CSS para ahorrar costos. Esto te expone a demandas laborales y multas gigantes.

PRO TIP: Usa una planilla digital para calcular cuotas automáticamente.''',
      ),
      RutaStep(
        id: 9,
        title: 'Herramientas financieras',
        description: 'Control de ingresos y gastos',
        content: '''El control financiero es la diferencia entre un negocio exitoso y uno quebrado. Necesitas saber: ¿Cuánto entra? ¿Cuánto sale? ¿Cuánto me queda?

HERRAMIENTAS RECOMENDADAS:
- BÁSICO: Excel con plantilla de ingresos/gastos
- INTERMEDIO: Google Sheets + formularios de entrada
- AVANZADO: Software contable (QuickBooks, Xero, Conta)

MÍNIMO NECESARIO: Registra DIARIAMENTE cada venta y cada gasto. Categoriza (Marketing, Inventario, Nómina, Servicios).

ERROR MORTAL: Llevar "todo en la cabeza". Después de 3 meses no recordarás dónde fue cada centavo.

PRO TIP: Dedica 15 minutos CADA DÍA (no una vez al mes) para actualizar tus números. La disciplina diaria es más fácil que recuperar 30 días de atraso.''',
        toolRoute: '/accounting/cash_flow',
        toolLabel: 'Ir a Flujo de Caja',
      ),
      RutaStep(
        id: 10,
        title: 'Checklist final',
        description: '¡Tu negocio es formal!',
        content: '''¡Felicidades! Si completaste los pasos anteriores, ya tienes:
✅ RUC activo
✅ Aviso de Operación vigente
✅ Permisos municipales al día
✅ Cuenta bancaria comercial
✅ (Si aplica) Registro en CSS
✅ Sistema de control financiero

SIGUIENTE PASO: ¡Es hora de operar! La Fase 2 te enseñará cómo conseguir clientes, vender, y crear una marca sólida.

IMPORTANTE: Mantén TODOS tus documentos organizados en una carpeta física y digital. Los necesitarás para renovaciones anuales.

PRO TIP: Programa recordatorios en tu calendario para renovar permisos y pagar impuestos. La organización desde el inicio te ahorrará dolores de cabeza.''',
      ),
    ],
  ),

  // FASE 2: OPERAR  
  RutaPhase(
    id: 2,
    title: 'Fase 2: Operar',
    subtitle: 'Consigue clientes y vende',
    color: 0xFF2196F3, // Blue
    steps: [
      RutaStep(
        id: 11,
        title: 'Identidad del negocio',
        description: 'Logo, colores y voz de marca',
        content: '''Tu identidad de marca es cómo te perciben los clientes. Incluye: nombre del negocio, logo, colores, fuentes, y voz (cómo te comunicas).

ELEMENTOS CLAVE:
- Nombre: Memorable, fácil de pronunciar, relevante
- Logo: Simple, reconocible, funciona en blanco y negro
- Colores: 2-3 colores principales (psicología del color importa)
- Voz: ¿Eres formal? ¿Amigable? ¿Humorístico?

ERROR COMÚN: Copiar la estética de la competencia. Sé ÚNICO.

HERRAMIENTAS: Canva (logos gratis), Coolors (paletas de colores), Google Fonts.

PRO TIP: Tu marca debe reflejar a tu cliente ideal, no tus gustos personales. Si vendes a abogados, no uses Comic Sans.''',
      ),
      RutaStep(
        id: 12,
        title: 'Redes sociales',
        description: 'Presencia digital activa',
        content: '''Si no estás en internet, no existes. Elige 1-2 redes sociales donde esté tu cliente ideal:
- Instagram/TikTok: B2C (ventas a personas), productos visuales
- LinkedIn: B2B (ventas a empresas), servicios profesionales
- Facebook: B2C general, audiencia 30+

PASO 1: Crea perfiles con nombre consistente (@TuMarca)
PASO 2: Bio clara: ¿Qué vendes? ¿A quién? ¿Dónde estás?
PASO 3: Publica 3-5 veces/semana con VALOR (no solo "compra compra")

ERROR COMÚN: Estar en TODAS las redes y no gestionar ninguna bien. Enfócate.

PRO TIP: Programa contenido con anticipación (Later, Buffer, Metricool). Ahorra 80% del tiempo.''',
        toolRoute: '/marketing/content',
        toolLabel: 'Generar Contenido',
      ),
      RutaStep(
        id: 13,
        title: 'Público objetivo',
        description: 'Define tu Buyer Persona',
        content: '''No puedes venderle a "todo el mundo". Define tu cliente ideal:

PERFIL DEMOGRÁFICO:
- Edad, género, ubicación
- Nivel de ingresos
- Ocupación, educación

PERFIL PSICOGRÁFICO:
- Dolores/problemas que tiene
- Deseos/aspiraciones
- Miedos/objeciones

EJEMPLO: "Mujeres 25-40, madres emprendedoras, ingresos B/.800-2,000, buscan equilibrio trabajo-familia, miedo a fracasar como empresaria."

ERROR COMÚN: Definir "todos" como tu audiencia. Eso diluye tu mensaje.

PRO TIP: Entrevista a 3-5 clientes actuales o potenciales. Pregúntales qué los mantiene despiertos por la noche.''',
      ),
      RutaStep(
        id: 14,
        title: 'Estrategia de contenido',
        description: 'Qué publicar y cuándo',
        content: '''La constancia es más importante que la perfección. Crea un calendario de contenido semanal:

REGLA 80/20:
- 80% Contenido de VALOR (tips, educación, entretenimiento)
- 20% Contenido COMERCIAL (ventas, promociones)

TIPOS DE CONTENIDO:
- Educativo: Tutoriales, consejos, datos
- Inspiracional: Historias, casos de éxito
- Entretenido: Memes, detrás de cámaras
- Comercial: Producto, precio, promoción

ERROR COMÚN: Solo publicar "COMPRA AHORA". Cansa a la audiencia.

PRO TIP: Reutiliza 1 idea en 5 formatos: 1 video → 5 posts → 10 stories → 1 blog → emails.''',
        toolRoute: '/marketing/content',
        toolLabel: 'Crear Calendario',
      ),
      RutaStep(
        id: 15,
        title: 'Primer cliente',
        description: 'Consigue tu primera venta real',
        content: '''La primera venta valida que alguien REALMENTE quiere tu producto/servicio. No regales, VENDE (aunque sea barato al inicio).

ESTRATEGIAS:
- Familia/amigos (pero COBRA, aunque sea precio especial)
- Redes sociales: Publica oferta de lanzamiento
- Boca a boca: Pide referidos
- Alianzas: Ofrece comisión a quien te refiera

CIERRE DE VENTA:
1. Identifica necesidad
2. Presenta solución
3. Maneja objeciones
4. Pide el pago

ERROR COMÚN: Dar todo gratis "para portafolio". Eso atrae clientes que NO valoran tu trabajo.

PRO TIP: Después de la venta, pide testimonio ESE MISMO DÍA (video o escrito). Úsalo en marketing.''',
      ),
      RutaStep(
        id: 16,
        title: 'Registrar ingresos',
        description: 'Anota cada centavo',
        content: '''Desde la primera venta, registra TODO. Usa una hoja de cálculo simple o app de contabilidad.

DATOS MÍNIMOS POR VENTA:
- Fecha
- Cliente (nombre/empresa)
- Producto/servicio vendido
- Monto (con/sin impuesto)
- Método de pago (efectivo, transferencia, tarjeta)
- Número de factura (si aplica)

CATEGORIZA GASTOS:
- Inventario/materia prima
- Marketing
- Operaciones (luz, internet, renta)
- Administrativos (contador, abogado)

ERROR COMÚN: "Lo registro después" → Nunca lo haces.

PRO TIP: Dedica 10 minutos CADA NOCHE a actualizar tus registros. No lo dejes para fin de mes.''',
        toolRoute: '/accounting/cash_flow',
        toolLabel: 'Registrar Movimiento',
      ),
      RutaStep(
        id: 17,
        title: 'Ajustar precios',
        description: 'Revisa tus márgenes',
        content: '''Precio = Costo + Margen de Ganancia + Impuestos. Si vendes muy barato, trabajas gratis.

FÓRMULA BÁSICA:
Precio de Venta = (Costo Total / (1 - % Margen)) + Impuestos

EJEMPLO:
- Costo: B/.50
- Margen deseado: 40% (0.40)
- Precio: B/.50 / (1 - 0.40) = B/.83.33 + ITBMS

FACTORES A CONSIDERAR:
- Precio de competencia
- Valor percibido
- Urgencia del cliente
- Tu posicionamiento (premium vs. económico)

ERROR COMÚN: Competir SOLO por precio. Eso te lleva a la quiebra.

PRO TIP: Aumenta precios 10-15% cada 6 meses. Los clientes que te valoran se quedan.''',
        toolRoute: '/margen_ganancia',
        toolLabel: 'Calcular Margen',
      ),
      RutaStep(
        id: 18,
        title: 'Sistema de ventas',
        description: 'Estandariza tu proceso',
        content: '''Un sistema de ventas es un proceso repetible para convertir prospectos en clientes.

PASOS TÍPICOS:
1. Prospección (encontrar leads)
2. Contacto inicial (mensaje, llamada)
3. Calificación (¿es mi cliente ideal?)
4. Presentación (mostrar solución)
5. Manejo de objeciones ("está caro", "lo pienso")
6. Cierre (firma/pago)
7. Entrega
8. Seguimiento (pedir referidos/recompra)

ERROR COMÚN: Proceso caótico que cambia cada vez. Eso NO escala.

PRO TIP: Crea un script/plantilla para cada paso. No robotices, ADAPTA, pero ten base.''',
      ),
      RutaStep(
        id: 19,
        title: 'Experiencia del cliente',
        description: 'Haz que vuelvan',
        content: '''Un cliente feliz trae 3 más. Uno enojado espanta a 10. La experiencia post-venta es TAN importante como la venta.

PILARES:
- Rapidez: Responde en <24 horas
- Claridad: Comunica tiempos y expectativas
- Empatía: Si hay error, reconócelo y arréglalo
- Sorpresas: Carta de agradecimiento, descuento futuro

MIDE SATISFACCIÓN:
Después de la entrega: "Del 1-10, ¿qué tal tu experiencia?"
- 9-10: Pide testimonio
- 7-8: Pregunta cómo mejorar
- 1-6: Llama YA y resuelve

ERROR COMÚN: Solo contactar al cliente para venderle.

PRO TIP: Envía mensaje de cumpleaños con descuento. Tasa de conversión: 3x normal.''',
      ),
      RutaStep(
        id: 20,
        title: 'Primer mes completado',
        description: '¡Sobreviviste!',
        content: '''¡Felicidades! Si llegaste aquí, ya:
✅ Tienes marca e identidad
✅ Presencia en redes
✅ Conoces a tu cliente ideal
✅ Lograste tus primeras vents
✅ Registras tus movimientos financieros
✅ Tienes sistema de ventas básico

REVISIÓN DEL MES:
- ¿Cuánto vendiste?
- ¿Cuánto gastaste?
- ¿Ganaste o perdiste dinero?
- ¿Qué funcionó? ¿Qué NO?

SIGUIENTE PASO: La Fase 3 es ESCALAR. Multiplicar ventas, contratar ayuda, automatizar procesos.

PRO TIP: NO saltes fases. Domina lo básico antes de crecer.''',
      ),
    ],
  ),

  // FASE 3: ESCALAR
  RutaPhase(
    id: 3,
    title: 'Fase 3: Escalar',
    subtitle: 'Crece de forma sostenible',
    color: 0xFF9C27B0, // Purple
    steps: [
      RutaStep(
        id: 21,
        title: 'Segundo producto',
        description: 'Diversifica tu oferta',
        content: '''Vender MÁS a los MISMOS clientes es más fácil que conseguir nuevos. Crea productos/servicios complementarios.

ESTRATEGIAS:
- Upsell: Versión premium del producto actual
- Cross-sell: Producto relacionado
- Downsell: Versión económica para los "está caro"

EJEMPLO:
- Vendes pasteles → Ofrece cupcakes (downsell), tortas bodas (upsell), catering completo (cross-sell)

ERROR COMÚN: Lanzar producto 2 sin validar con clientes actuales.

PRO TIP: Pregunta a tus mejores 10 clientes: "¿Qué otro problema puedo resolver para ti?"''',
      ),
      RutaStep(
        id: 22,
        title: 'Optimizar operaciones',
        description: 'Haz más con menos',
        content: '''Elimina desperdicios: tiempo, dinero, esfuerzo. La eficiencia aumenta ganancias SIN vender más.

ÁREAS CLAVE:
- Proveedores: Negocia descuentos por volumen
- Procesos: Automatiza tareas repetitivas
- Inventario: Evita sobrestock (dinero dormido)
- Tiempos: Reduce pasos innecesarios

MÉTODO LEAN:
1. Identifica cuello de botella (paso más lento)
2. Elimínalo o mejóralo
3. Repite

ERROR COMÚN: Añadir más personas sin arreglar proceso roto.

PRO TIP: Mapea tu proceso actual en papel. Verás dónde pierdes tiempo/dinero.''',
        toolRoute: '/punto_equilibrio',
        toolLabel: 'Punto de Equilibrio',
      ),
      RutaStep(
        id: 23,
        title: 'Flujo de caja',
        description: 'Gestiona tu efectivo',
        content: '''Puedes tener ventas altas y quebrar si no tienes CASH en el banco. El efectivo es oxígeno del negocio.

REGLAS DE ORO:
- Cobra ANTES, paga DESPUÉS (cuando sea posible)
- Mantén reserva de 3 meses de gastos operativos
- Proyecta flujo: ¿Cuánto entra/sale próximos 3 meses?

PROBLEMA COMÚN: Crecimiento rápido sin capital de trabajo → Quiebra.

SOLUCIÓN:
- Ofrece descuento por pago anticipado
- Retrasa pagos a proveedores (negocia plazos)
- Línea de crédito empresarial (SOLO emergencias)

ERROR MORTAL: Usar efectivo del negocio para gastos personales.

PRO TIP: Revisa flujo de caja CADA SEMANA, no una vez al mes.''',
        toolRoute: '/accounting/cash_flow',
        toolLabel: 'Ver Flujo de Caja',
      ),
      RutaStep(
        id: 24,
        title: 'Delegar',
        description: 'Libera tu tiempo',
        content: '''No puedes crecer si haces TODO. Delegar es clave para escalar, pero duele soltar control.

QUÉ DELEGAR PRIMERO:
1. Tareas operativas repetitivas (empaque, entregas)
2. Tareas que odias (contabilidad, RRSS si no te gusta)
3. Tareas donde NO eres experto

CÓMO DELEGAR:
- Define EXACTAMENTE qué quieres (manual paso a paso)
- Contrata persona/freelancer
- Supervisa al inicio, luego solo resultados

ERROR COMÚN: "Nadie lo hace tan bien como yo" → Nunca delegas.

PRO TIP: Calcula tu "valor por hora". Si ganas B/.50/hora vendiendo, NO pases 5 horas diseñando flyers. Paga B/.30 a diseñador.''',
      ),
      RutaStep(
        id: 25,
        title: 'Marketing avanzado',
        description: 'Publicidad pagada y funnels',
        content: '''Llegó el momento de INVERTIR en marketing, no solo publicar gratis.

OPCIONES:
- Facebook/Instagram Ads: B/.5-20/día, segmenta audiencia
- Google Ads: Pagan cuando buscan tu servicio
- Influencers: Micro-influencers (5k-50k seguidores) = mejor ROI

FUNNEL BÁSICO:
1. Anuncio → 2. Landing page → 3. Oferta → 4. Compra

MIDE TODO:
- CPC (costo por clic)
- CPL (costo por lead)
- CAC (costo adquisición cliente)
- ROI (retorno inversión)

ERROR COMÚN: "Los ads no funcionan" → Problema: No sabes medir.

PRO TIP: Invierte B/.10/día por 7 días. Analiza. Ajusta. Escala lo que funciona.''',
      ),
      RutaStep(
        id: 26,
        title: 'Retención',
        description: 'Fideliza clientes',
        content: '''Cuesta 5X más conseguir cliente nuevo que vender a uno existente. Enfócate en RETENER.

TÁCTICAS:
- Programa de lealtad (puntos, descuentos)
- Email marketing (tips + ofertas)
- Membresía/suscripción (ingresos recurrentes)
- VIP: Trato especial a mejores clientes

MÉTRICA CLAVE: LTV (Lifetime Value)
¿Cuánto gasta un cliente en su "vida"?
- Cliente compra 1 vez: LTV = B/.100
- Cliente compra 10 veces: LTV = B/.1,000

ERROR COMÚN: Perseguir clientes nuevos e ignorar actuales.

PRO TIP: Contacta a clientes inactivos >3 meses: "Te extrañamos, aquí tienes 15% descuento".''',
      ),
      RutaStep(
        id: 27,
        title: 'Multiplicar ventas',
        description: 'Aumenta ticket promedio',
        content: '''Más ventas = Más clientes O Mismo cliente gasta más. La segunda opción es más barata.

ESTRATEGIAS:
- Upsell: "¿Quieres la versión PRO por +B/.10?"
- Cross-sell: "Clientes que compraron X también llevan Y"
- Bundles: Paquetes 3x2 o combos
- Precios psicológicos: B/.99 vs. B/.100

EJEMPLO:
- Venta actual: 100 clientes x B/.50 = B/.5,000/mes
- Con upsell 20%: 100 clientes x B/.60 = B/.6,000/mes (+B/.1,000 SIN nuevos clientes)

ERROR COMÚN: No ofrecer. "Por pena" de ser insistente.

PRO TIP: La oferta SIEMPRE se hace DESPUÉS de la compra principal, no antes.''',
      ),
      RutaStep(
        id: 28,
        title: 'Alianzas estratégicas',
        description: 'Crece con partners',
        content: '''Juntos llegamos más lejos. Busca negocios complementarios (NO competencia) para colaborar.

TIPOS DE ALIANZAS:
- Referidos cruzados: Tú envías clientes a ellos, ellos a ti
- Co-marketing: Promoción conjunta (sorteo, evento)
- Bundle: Paquete combinado de servicios
- Distribución: Ellos venden tu producto por comisión

EJEMPLO:
- Vendes pasteles → Alianza con wedding planner → Ella refiere novias, tú pagas 10% comisión

FORMALIZA:
- Acuerdo escrito (quién, qué, cuánto)
- Define métricas (cuántas ventas, comisión)

ERROR COMÚN: Alianza sin compromiso claro → No funciona.

PRO TIP: Haz lista de 10 negocios donde está tu cliente. Propón alianza.''',
      ),
      RutaStep(
        id: 29,
        title: 'Automatizar',
        description: 'Usa tecnología',
        content: '''El negocio debe funcionar SIN que estés 24/7. La automatización te da libertad.

QUÉ AUTOMATIZAR:
- Ventas: Chatbot, carrito online, cobros recurrentes
- Marketing: Emails programados, publicaciones sociales
- Contabilidad: Sincronización banco-software
- Atención: FAQs, respuestas automáticas

HERRAMIENTAS:
- Zapier: Conecta apps (nuevo cliente → email bienvenida)
- Calendly: Agenda citas automáticamente
- Stripe/PayPal: Cobros automáticos

ERROR COMÚN: Automatizar proceso roto. Primero optimiza, LUEGO automatiza.

PRO TIP: Automatiza 1 tarea por mes. En 1 año, 12 procesos trabajan solos.''',
      ),
      RutaStep(
        id: 30,
        title: '¡Lo lograste!',
        description: 'Tu negocio es un activo',
        content: '''¡FELICIDADES! Completaste la Ruta del Éxito. Si aplicaste todo, ahora tienes:

✅ Negocio 100% legal
✅ Clientes recurrentes
✅ Sistema de ventas que funciona
✅ Equipo (o procesos) que te apoyan
✅ Marketing que genera resultados
✅ Finanzas bajo control
✅ Negocio que puede funcionar sin ti

AHORA ERES:
- Emprendedor → Empresario
- Trabajador → Dueño de activo
- Sobreviviente → Escalador

PRÓXIMOS PASOS:
- Expande a nuevas ciudades/países
- Crea franquicia o licencia tu modelo
- Vende tu negocio (exit strategy)
- Invierte ganancias en más negocios

¡El cielo es el límite! 🚀''',
      ),
    ],
  ),
];
