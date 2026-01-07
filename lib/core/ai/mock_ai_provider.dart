import 'dart:math';
import 'package:proyecto_empoderate/core/ai/ai_provider.dart';
import 'package:proyecto_empoderate/features/ai_texts/domain/ai_text_request.dart';
import 'package:proyecto_empoderate/features/ai_texts/domain/ai_text_output.dart';
import 'package:proyecto_empoderate/features/ai_customers/domain/ai_customer_request.dart';
import 'package:proyecto_empoderate/features/ai_customers/domain/ai_customer_output.dart';
import 'package:proyecto_empoderate/features/ai_shared/domain/ai_shared_types.dart';
import 'package:proyecto_empoderate/features/ai_shared/domain/ai_generic_request.dart';
import 'package:proyecto_empoderate/features/ai_shared/domain/ai_generic_output.dart';

class MockAiProvider implements AiProvider {
  @override
  Future<AiTextOutput> generateAiText(AiTextRequest req) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // INFERENCE LOGIC (Magic Mode)
    final isMagicMode = req.prompt != null && req.prompt!.isNotEmpty;
    
    // Default values or inferred ones
    String businessType = req.businessType ?? (isMagicMode ? _inferBusiness(req.prompt!) : 'Tu Negocio');
    String audience = req.audience ?? 'tus clientes ideales';
    String goal = req.goal ?? 'conectar';
    String brand = req.brandName ?? businessType;
    String cta = req.callToAction ?? '¡Contáctanos hoy mismo!';
    List<String> keywords = req.keywords;

    // Logic to generate templates based on prompted goal/tone
    String short;
    String medium;
    String long;
    List<String> hashtags = ['#Empoderate', '#Negocios', '#${businessType.replaceAll(' ', '')}'];
    
    if (keywords.isNotEmpty) {
      hashtags.addAll(keywords.map((k) => '#${k.replaceAll(' ', '')}'));
    }

    // TONE MODIFIERS
    String intro = '';
    String style = '';
    if (req.tone == 'premium') {
      intro = 'Descubre la excelencia.';
      style = 'con elegancia';
    } else if (req.tone == 'cercano') {
      intro = '¡Hola! Esto es para ti.';
      style = 'como amigos';
    } else {
      intro = 'Atención a todos.';
      style = 'profesionalmente';
    }

    // TEMPLATE GENERATION
    if (isMagicMode) {
      // Magic responses based on the prompt "Idea"
      short = '✨ $intro ${req.prompt} 🚀. $cta';
      
      medium = '''
🎯 $intro

${req.prompt}

En $brand, hacemos esto realidad $style.
¿Listo para dar el siguiente paso?

👉 $cta
''';
      
      long = '''
🚀 transforma tu visión con $brand.

Has estado pensando en: "${req.prompt}". Y nosotros tenemos la solución perfecta.

Nuestro enfoque en $businessType está diseñado para $audience que buscan calidad y resultados.
No dejes pasar esta oportunidad de destacar.

✅ Servicio personalizado
✅ Resultados garantizados

$cta
''';
    } else {
      // Classic structured response
       short = '$intro En $brand sabemos que buscas $style. Aprovecha nuestra oferta. $cta';
    
    medium = '''
📍 $intro
En $brand, nos especializamos en $businessType para un público como tú: $audience. 

¿Por qué elegirnos?
✅ Experiencia y $style.
✅ Enfoque en $goal.

✨ Calidad que se nota en cada detalle.

🚀 $cta
''';

    long = '''
🌟 ¿Alguna vez has sentido que necesitas un aliado en $businessType?

En $brand entendemos profundamente a la audiencia de $audience. Nuestra misión es ayudarte a $goal transformando tu realidad.

$style, hemos diseñado una propuesta que no solo cumple, sino que supera expectativas.

Lo que ofrecemos no es solo un producto o servicio, es una experiencia completa diseñada para quienes no se conforman con lo estándar.

💡 Es momento de dar el siguiente paso.

👉 $cta
''';
    }

    return AiTextOutput(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      createdAt: DateTime.now(),
      request: req,
      shortVersion: short,
      mediumVersion: medium,
      longVersion: long,
      hashtags: hashtags.take(10).toList(),
      suggestedCta: cta,
    );
  }

  @override
  Future<AiCustomerOutput> generateAiCustomerStrategy(AiCustomerRequest req) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    final isMagicMode = req.prompt != null && req.prompt!.isNotEmpty;
    String business = req.businessType ?? (isMagicMode ? _inferBusiness(req.prompt!) : 'Emprendimiento');
    String segment = req.targetSegment ?? (isMagicMode ? _inferSegment(req.prompt!) : 'Público General');
    
    String persona;
    String strategy;
    String empathy;
    String action;

    if (isMagicMode) {
      persona = '''
👤 PERFIL: El Cliente de "${req.prompt}"
- Edad: 25-45 años.
- Intereses: Calidad, rapidez y soluciones prácticas.
- Dolor: Falta de tiempo y necesidad de confianza.
- Motivación: Sentirse empoderado y eficiente.
''';

      strategy = '''
📈 ESTRATEGIA: Conexión Inmediata
1. Personalización: Usa el nombre del cliente y menciona su interés en "${req.prompt}".
2. Valor: Envía un consejo útil relacionado con su necesidad antes de vender.
3. Fidelización: Ofrece un "Bonus de Bienvenida" por su primera interacción.
''';

      empathy = '''
🧠 MAPA DE EMPATÍA
- ¿Qué piensa?: "Necesito resolver esto de forma sencilla".
- ¿Qué ve?: Un mercado saturado de opciones genéricas.
- ¿Qué oye?: Recomendaciones de amigos sobre servicios personalizados.
- ¿Qué dice/hace?: Busca reseñas y compara valor sobre precio.
''';

      action = 'Enviar mensaje de bienvenida personalizado por WhatsApp.';
    } else {
      persona = '''
👤 PERFIL: $segment
- Niche: $business.
- Características: Buscadores de soluciones premium y atención al detalle.
- Expectativa: Un trato exclusivo y transparente.
''';

      strategy = '''
📈 ESTRATEGIA: Plan de Crecimiento
- Fase 1: Captación vía contenido educativo sobre $business.
- Fase 2: Nutrición con casos de éxito de otros $segment.
- Fase 3: Conversión con oferta irresistible por tiempo limitado.
''';

      empathy = '''
🧠 MAPA DE EMPATÍA ($segment)
- Deseo: Lograr sus metas en $business ahorrando recursos.
- Frustración: Mala comunicación previa con otros proveedores.
''';

      action = 'Lanzar campaña de retargeting enfocada en beneficios.';
    }

    return AiCustomerOutput(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      createdAt: DateTime.now(),
      request: req,
      buyerPersona: persona,
      strategy: strategy,
      empathyMap: empathy,
      suggestedAction: action,
    );
  }

  @override
  Future<AiGenericOutput> generateGeneric(AiGenericRequest req) async {
    await Future.delayed(const Duration(seconds: 2));

    String content = '';
    String extra = '';
    String action = '';
    List<AiAction> suggestedActions = [];

    switch (req.type) {
      case AiFeatureType.products:
        content = _generateProductContent(req);
        extra = '📊 TIP: Agrega fotos de alta calidad para maximizar conversiones.';
        action = 'Publicar en marketplace, redes sociales y catálogo web.';
        suggestedActions = [
          AiAction(
            label: 'Crear publicación',
            taskTitle: 'Publicar ${req.prompt} en Redes',
            taskDescription: 'Usar el texto generado para publicar el producto.',
          )
        ];
        break;

      case AiFeatureType.contracts:
        content = _generateContractContent(req);
        extra = '⚠️ IMPORTANTE: Esto es una guía. Consulta siempre a un experto legal en Panamá.';
        action = 'Revisar cláusulas específicas y firmar digitalmente.';
        suggestedActions = [
          AiAction(
            label: 'Agendar Revisión Legal',
            taskTitle: 'Revisar Contrato ${req.prompt}',
            taskDescription: 'Revisar borrador con abogado o contraparte.',
          )
        ];
        break;

      case AiFeatureType.processes:
        content = _generateProcessContent(req);
        extra = '🔄 MEJORA CONTINUA: Mide KPIs (tiempo, errores) para optimizar.';
        action = 'Imprimir y capacitar al equipo con este manual.';
        suggestedActions = [
          AiAction(
            label: 'Implementar Proceso',
            taskTitle: 'Implementar Flujo: ${req.prompt}',
            taskDescription: 'Capacitar equipo y activar procedimiento.',
          )
        ];
        break;

      case AiFeatureType.strategies:
        content = _generateStrategyContent(req);
        extra = '📊 KPI CLAVE: Tasa de conversión y ROI (5% y 300% respectivamente).';
        action = 'Agendar kickoff de estrategia con equipo esta semana.';
        suggestedActions = [
          AiAction(
            label: 'Agendar Inicio Estrategia',
            taskTitle: 'Lanzar Estrategia: ${req.prompt}',
            taskDescription: 'Iniciar ejecución según plan generado.',
          )
        ];
        break;
    }

    return AiGenericOutput(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      createdAt: DateTime.now(),
      request: req,
      content: content,
      extraInfo: extra,
      actionPlan: action,
      suggestedActions: suggestedActions,
    );
  }

  String _generateContractContent(AiGenericRequest req) {
    final p = req.prompt.toLowerCase();
    final now = DateTime.now();
    
    // Extract form data for contracts
    final fd = req.formData ?? {};
    final party1Name = fd['party1Name'] ?? '[NOMBRE COMPLETO / RAZÓN SOCIAL]';
    final party1Id = fd['party1Id'] ?? '[_________-____-______]';
    final party1Address = fd['party1Address'] ?? '[dirección completa]';
    final party2Name = fd['party2Name'] ?? '[NOMBRE COMPLETO]';
    final party2Id = fd['party2Id'] ?? '[_________-____-______]';
    final party2Address = fd['party2Address'] ?? '[dirección completa]';
    final amount = fd['amount'] ?? '[_______.00]';
    final startDate = fd['startDate'] ?? '[día/mes/año]';
    final endDate = fd['endDate'] ?? '[día/mes/año]';
    final propertyAddress = fd['propertyAddress'] ?? '[DIRECCIÓN EXACTA]';
    final position = fd['position'] ?? '[CARGO/PUESTO]';
    final services = fd['services'] ?? '[DESCRIPCIÓN DE SERVICIOS]';
    
    // TEMPLATE 1: ARRENDAMIENTO / ALQUILER - PROFESIONAL
    if (p.contains('arrendamiento') || p.contains('alquiler') || p.contains('renta') || p.contains('local')) {
      return '''
═══════════════════════════════════════════════════════════════════
                    CONTRATO DE ARRENDAMIENTO
                    República de Panamá
═══════════════════════════════════════════════════════════════════

En la ciudad de Panamá, República de Panamá, a los ${now.day} días del mes de ${_getMonthName(now.month)} del año ${now.year}, comparecen:

───────────────────────────────────────────────────────────────────
PRIMERA PARTE - EL ARRENDADOR:
───────────────────────────────────────────────────────────────────
$party1Name, de nacionalidad [___________], mayor de edad, [estado civil], portador(a) de la cédula de identidad personal / RUC No. $party1Id, con domicilio en $party1Address, quien comparece en su calidad de [PROPIETARIO / REPRESENTANTE LEGAL], debidamente facultado(a) mediante Escritura Pública No. [____] de [fecha] otorgada ante Notaría [___] del Circuito de Panamá.

───────────────────────────────────────────────────────────────────
SEGUNDA PARTE - EL ARRENDATARIO:
───────────────────────────────────────────────────────────────────
$party2Name, de nacionalidad [___________], mayor de edad, [estado civil], portador(a) de la cédula de identidad personal / RUC No. $party2Id, con domicilio en $party2Address.

Quienes convienen en celebrar el presente CONTRATO DE ARRENDAMIENTO, el cual se regirá por las siguientes estipulaciones:

═══════════════════════════════════════════════════════════════════
                         CLÁUSULAS
═══════════════════════════════════════════════════════════════════

PRIMERA – OBJETO DEL CONTRATO:
El ARRENDADOR da en arrendamiento al ARRENDATARIO, y éste toma en alquiler del ARRENDADOR, el bien inmueble ubicado en $propertyAddress, Finca [_______], inscrita en el Registro Público al Tomo [___], Folio [___], Asiento [___], de la Sección de la Propiedad.

SEGUNDA – DESTINACIÓN:
El inmueble objeto del presente contrato se destinará exclusivamente para uso [HABITACIONAL / COMERCIAL / MIXTO], quedando expresamente prohibido destinarlo a actividades distintas sin autorización previa y por escrito del ARRENDADOR. Queda prohibido subarrendar total o parcialmente el inmueble.

TERCERA – PLAZO:
El presente contrato tendrá una duración de [___] ([____]) meses, contados a partir del $startDate y finalizará el $endDate. El contrato se prorrogará automáticamente por períodos iguales a menos que cualquiera de las partes notifique por escrito su intención de no renovar con al menos TREINTA (30) días de anticipación a la fecha de vencimiento.

CUARTA – PRECIO Y FORMA DE PAGO:
El ARRENDATARIO pagará al ARRENDADOR una renta mensual de BALBOAS B/.$amount ([___________BALBOAS CON 00/100]), pagaderos entre el día PRIMERO (1) y QUINTO (5) día de cada mes, mediante [transferencia bancaria a la cuenta No. _____________ del Banco ____________ / cheque certificado / efectivo].

El canon de arrendamiento podrá ser incrementado anualmente en el porcentaje correspondiente al Índice de Precios al Consumidor (IPC) publicado por el Instituto Nacional de Estadística y Censo (INEC), o en un [___]%, lo que sea mayor.

QUINTA – DEPÓSITO DE GARANTÍA:
El ARRENDATARIO entrega al ARRENDADOR la suma de BALBOAS B/.$amount ([___________BALBOAS CON 00/100]), equivalente a [___] mes(es) de alquiler, en concepto de depósito de garantía. Esta suma se devolverá al finalizar el contrato, previo descuento de daños, deterioros o deudas pendientes. El depósito no devenga intereses y no podrá ser aplicado como pago de las últimas mensualidades.

SEXTA – SERVICIOS PÚBLICOS Y GASTOS:
Correrán por cuenta del ARRENDATARIO los gastos de:
a) Energía eléctrica, agua, aseo, teléfono e internet.
b) Tasas municipales y cuota de mantenimiento (si aplica).
c) Seguros del contenido del inmueble.

El ARRENDADOR será responsable del pago del Impuesto Inmobiliario y seguros de la estructura del edificio.

SÉPTIMA – MANTENIMIENTO Y REPARACIONES:
El ARRENDATARIO se obliga a:
a) Mantener el inmueble en buen estado de conservación, higiene y seguridad.
b) Realizar reparaciones menores y de mantenimiento ordinario (grifería, cerraduras, bombillas, etc.).
c) Notificar de inmediato al ARRENDADOR sobre daños estructurales o desperfectos mayores.

Las reparaciones mayores (estructura, instalaciones eléctricas principales, plomería mayor) correrán por cuenta del ARRENDADOR.

OCTAVA – OBLIGACIONES DEL ARRENDATARIO:
Además de las anteriores, el ARRENDATARIO se obliga a:
a) Usar el inmueble de forma prudente, diligente y conforme a su naturaleza.
b) No realizar modificaciones estructurales sin autorización escrita del ARRENDADOR.
c) Permitir inspecciones periódicas del ARRENDADOR, previa notificación de 24 horas.
d) No tener animales domésticos sin autorización previa y escrita.
e) Cumplir con las normas de convivencia y reglamento del edificio (si aplica).
f) Devolver el inmueble en las mismas condiciones en que lo recibió, salvo deterioro por uso normal.

NOVENA – OBLIGACIONES DEL ARRENDADOR:
El ARRENDADOR se obliga a:
a) Entregar el inmueble en condiciones de habitabilidad y seguridad.
b) Garantizar el uso pacífico del inmueble.
c) Realizar reparaciones mayores necesarias.
d) No perturbar el uso del inmueble salvo casos de fuerza mayor.

DÉCIMA – CESIÓN Y SUBARRIENDO:
El ARRENDATARIO no podrá ceder este contrato ni subarrendar total o parcialmente el inmueble sin consentimiento previo y por escrito del ARRENDADOR, so pena de resolución inmediata del contrato.

UNDÉCIMA – TERMINACIÓN ANTICIPADA:
Cualquiera de las partes podrá resolver anticipadamente este contrato mediante notificación escrita con SESENTA (60) días de anticipación. En caso de terminación anticipada por parte del ARRENDATARIO, éste perderá el depósito de garantía como indemnización. Si la terminación es por parte del ARRENDADOR sin justa causa, deberá devolver el depósito duplicado.

DUODÉCIMA – CAUSALES DE RESOLUCIÓN INMEDIATA:
Serán causales de resolución inmediata:
a) Mora en el pago de DOS (2) mensualidades consecutivas o tres alternas.
b) Destinación del inmueble a uso distinto al pactado.
c) Subarriendo sin autorización.
d) Daños graves al inmueble por negligencia del ARRENDATARIO.
e) Actividades ilícitas en el inmueble.

DÉCIMA TERCERA – ENTREGA DEL INMUEBLE:
El ARRENDADOR entrega el inmueble en las condiciones descritas en el Acta de Entrega anexa, la cual forma parte integral de este contrato. El ARRENDATARIO lo recibe a satisfacción y se compromete a devolverlo en iguales condiciones al finalizar el arrendamiento.

DÉCIMA CUARTA – NOTIFICACIONES:
Toda notificación entre las partes se realizará por escrito a las direcciones señaladas o mediante correo electrónico a: [correo_arrendador@_____.com] y [correo_arrendatario@_____.com].

DÉCIMA QUINTA – LEGISLACIÓN APLICABLE:
Este contrato se rige por la Ley 93 del 29 de diciembre de 1973 "Que regula los contratos de arrendamiento financiero", el Código Civil de la República de Panamá y demás leyes aplicables.

DÉCIMA SEXTA – JURISDICCIÓN Y COMPETENCIA:
Para dirimir cualquier controversia derivada de este contrato, las partes se someten a los Tribunales Ordinarios de la República de Panamá, renunciando expresamente a cualquier otro fuero.

───────────────────────────────────────────────────────────────────

En fe de lo cual, las partes firman el presente contrato en TRES (3) ejemplares de igual tenor y valor, en la ciudad y fecha arriba indicados.


_________________________                 _________________________
EL ARRENDADOR                             EL ARRENDATARIO
Nombre:                                   Nombre:
Cédula/RUC:                              Cédula:


                    TESTIGOS:

_________________________                 _________________________
TESTIGO 1                                 TESTIGO 2
Nombre:                                   Nombre:
Cédula:                                   Cédula:

═══════════════════════════════════════════════════════════════════
''';
    }

    // TEMPLATE 2: LABORAL - PROFESIONAL
    if (p.contains('trabajo') || p.contains('laboral') || p.contains('empleado') || p.contains('contratar')) {
      return '''
═══════════════════════════════════════════════════════════════════
             CONTRATO INDIVIDUAL DE TRABAJO POR TIEMPO DEFINIDO
                    República de Panamá
═══════════════════════════════════════════════════════════════════

En la Ciudad de Panamá, República de Panamá, a los ${now.day} días del mes de ${_getMonthName(now.month)} de ${now.year}, comparecen:

───────────────────────────────────────────────────────────────────
EMPLEADOR:
───────────────────────────────────────────────────────────────────
$party1Name, sociedad debidamente inscrita bajo el Registro Único de Contribuyente (RUC) No. $party1Id, con domicilio principal en $party1Address, representada en este acto por [NOMBRE DEL REPRESENTANTE LEGAL], mayor de edad, [nacionalidad], portador de la cédula No. [___________], en su calidad de [CARGO], debidamente facultado.

En adelante denominado "EL EMPLEADOR".

───────────────────────────────────────────────────────────────────
TRABAJADOR:
───────────────────────────────────────────────────────────────────
$party2Name, de nacionalidad [___________], mayor de edad, [estado civil], portador(a) de la cédula de identidad personal No. $party2Id, con domicilio en $party2Address, y número de teléfono [_________].

En adelante denominado "EL TRABAJADOR".

Quienes convienen en celebrar el presente CONTRATO INDIVIDUAL DE TRABAJO POR TIEMPO DEFINIDO, de conformidad con el Código de Trabajo de la República de Panamá, bajo las siguientes estipulaciones:

═══════════════════════════════════════════════════════════════════
                         CLÁUSULAS
═══════════════════════════════════════════════════════════════════

PRIMERA – OBJETO:
Por medio del presente contrato, EL EMPLEADOR contrata los servicios profesionales de EL TRABAJADOR, quien se desempeñará en el cargo de $position, en el área de [DEPARTAMENTO], reportando directamente a [SUPERVISOR INMEDIATO / CARGO].

SEGUNDA – FUNCIONES Y RESPONSABILIDADES:
EL TRABAJADOR se obliga a realizar las siguientes funciones principales:
a) [Función principal 1 específica del puesto]
b) [Función principal 2 específica del puesto]
c) [Función principal 3 específica del puesto]
d) Otras funciones afines o complementarias que le sean asignadas conforme a su cargo.

TERCERA – LUGAR DE TRABAJO:
El trabajo se ejecutará principalmente en [DIRECCIÓN DEL CENTRO DE TRABAJO], sin perjuicio de que EL EMPLEADOR pueda disponer cambios temporales de sede por necesidades operativas, previa notificación.

CUARTA – JORNADA DE TRABAJO:
La jornada ordinaria de trabajo será de [___] horas semanales, distribuidas de [Lunes a Viernes / Lunes a Sábado], en el horario de [__:__] a.m. a [__:__] p.m., con un período de almuerzo de UNA (1) hora de [__:__] a [__:__], conforme al artículo 31 del Código de Trabajo.

La jornada máxima legal es de CUARENTA Y OCHO (48) horas semanales. Cualquier hora laborada por encima de la jornada ordinaria se considerará tiempo extraordinario y será remunerada con el recargo del veinticinco por ciento (25%) adicional sobre el salario por hora ordinaria, conforme al artículo 38 del Código de Trabajo.

QUINTA – PLAZO DEL CONTRATO:
Este contrato tendrá una duración de [___] ([____]) meses, iniciando el día $startDate y finalizando el día $endDate. Este contrato podrá prorrogarse por acuerdo mutuo de las partes, conforme al artículo 74 del Código de Trabajo. La duración total del contrato y sus prórrogas no excederá de UN (1) año.

SEXTA – PERÍODO DE PRUEBA:
De conformidad con el artículo 78 del Código de Trabajo, los primeros TRES (3) meses de este contrato se consideran como período de prueba, durante el cual cualquiera de las partes podrá dar por terminada la relación laboral sin responsabilidad alguna y sin necesidad de preaviso.

SÉPTIMA – SALARIO:
EL EMPLEADOR pagará a EL TRABAJADOR un salario mensual de BALBOAS B/.$amount ([_______BALBOAS CON 00/100]), pagaderos en forma [QUINCENAL / MENSUAL] mediante [transferencia bancaria / cheque / efectivo] los días [15 y último de cada mes / último día del mes].

Este salario no incluye las prestaciones y bonificaciones establecidas por Ley, las cuales se pagarán en los términos y fechas legales.

OCTAVA – PRESTACIONES LABORALES:
EL TRABAJADOR tendrá derecho a las siguientes prestaciones conforme a la legislación laboral panameña:

a) DÉCIMO TERCER MES (Prima de Navidad): Equivalente a 1/12 del total devengado durante el año fiscal (artículo 224 C.T.), pagadero en tres parcialidades: 15 de abril, 15 de agosto y 15 de diciembre.

b) VACACIONES: TREINTA (30) días calendario después de ONCE (11) meses continuos de trabajo (artículo 62 C.T.), las cuales deberán tomarse dentro del año siguiente. Durante las vacaciones EL TRABAJADOR recibirá su salario regular más el bono vacacional correspondiente.

c) SEGURO SOCIAL: EL EMPLEADOR inscribirá a EL TRABAJADOR en la Caja de Seguro Social (CSS) y realizará las cotizaciones correspondientes conforme a la Ley.

d) RIESGOS PROFESIONALES: EL EMPLEADOR cotizará por concepto de Riesgos Profesionales conforme a la clase de riesgo de la empresa.

e) SEGURO EDUCATIVO: Cotización del 1.25% sobre el salario (0.75% empleador, 0.50% trabajador).

NOVENA – DEBERES DEL TRABAJADOR:
EL TRABAJADOR se obliga a:
a) Prestar sus servicios con diligencia, eficiencia y lealtad.
b) Cumplir estrictamente el horario de trabajo establecido.
c) Acatar las órdenes e instrucciones del EMPLEADOR.
d) Guardar reserva sobre información confidencial de la empresa.
e) Cuidar los equipos, herramientas y materiales asignados.
f) Observar el Reglamento Interno de Trabajo y normas de seguridad.
g) Someterse a exámenes médicos cuando lo requiera el EMPLEADOR.

DÉCIMA – PROHIBICIONES AL TRABAJADOR:
Le está prohibido a EL TRABAJADOR:
a) Revelar información confidencial o secretos industriales.
b) Realizar trabajos similares para empresas competidoras durante la vigencia del contrato.
c) Presentarse al trabajo bajo efectos de alcohol o sustancias.
d) Sustraer bienes o documentos de la empresa.
e) Realizar actos de violencia, acoso o discriminación.

UNDÉCIMA – OBLIGACIONES DEL EMPLEADOR:
EL EMPLEADOR se obliga a:
a) Pagar puntualmente el salario y prestaciones correspondientes.
b) Proveer las herramientas necesarias para el trabajo.
c) Garantizar condiciones de higiene y seguridad en el trabajo.
d) Respetar la dignidad del trabajador.
e) Otorgar las vacaciones correspondientes.

DUODÉCIMA – CAUSALES DE TERMINACIÓN:
Este contrato terminará por:
a) Vencimiento del plazo establecido.
b) Mutuo consentimiento de las partes.
c) Dimisión del trabajador con preaviso de QUINCE (15) días.
d) Despido justificado conforme al artículo 213 del Código de Trabajo.
e) Muerte o incapacidad permanente del trabajador.

DÉCIMA TERCERA – TERMINACIÓN JUSTIFICADA:
Constituyen causales de despido justificado sin responsabilidad para EL EMPLEADOR (artículo 213 C.T.):
a) Falta grave de probidad o conducta inmoral.
b) Violación grave de las obligaciones contractuales.
c) Actos de violencia, injurias o malos tratos.
d) Daño intencional a equipos o propiedades.
e) Falta injustificada por más de TRES (3) días consecutivos.
f) Desobediencia grave al empleador o sus representantes.

En caso de despido injustificado, EL TRABAJADOR tendrá derecho a indemnización conforme al artículo 225 del Código de Trabajo.

DÉCIMA CUARTA – CESANTÍA:
Al término de la relación laboral por cualquier causa, EL TRABAJADOR tendrá derecho a la prima de antigüedad (cesantía) equivalente a UNA (1) semana de salario por cada año de servicio, conforme al artículo 225 del Código de Trabajo. Esta prestación será calculada sobre el último salario devengado.

DÉCIMA QUINTA – PROPIEDAD INTELECTUAL:
Toda creación intelectual, invención, diseño o desarrollo realizado por EL TRABAJADOR en el ejercicio de sus funciones será propiedad exclusiva de EL EMPLEADOR, sin perjuicio de los derechos morales que correspondan al creador.

DÉCIMA SEXTA – CONFIDENCIALIDAD:
EL TRABAJADOR se obliga a guardar estricta confidencialidad sobre toda información técnica, comercial, financiera o estratégica de la empresa, aún después de terminada la relación laboral, so pena de responder por daños y perjuicios.

DÉCIMA SÉPTIMA – MODIFICACIONES:
Cualquier modificación a este contrato deberá constar por escrito y ser firmada por ambas partes.

DÉCIMA OCTAVA – LEGISLACIÓN APLICABLE:
Este contrato se rige por el Código de Trabajo de la República de Panamá (Ley 44 de 1995 y sus modificaciones) y demás leyes aplicables.

DÉCIMA NOVENA – DOMICILIO Y NOTIFICACIONES:
Las partes señalan como domicilio para efectos de notificaciones los indicados en la comparecencia. Cualquier cambio deberá notificarse por escrito.

───────────────────────────────────────────────────────────────────

Leído el presente contrato y enteradas ambas partes de su contenido, valor y efectos legales, lo firman en TRES (3) ejemplares de igual tenor y validez, en la ciudad y fecha indicadas.


_________________________                 _________________________
EL EMPLEADOR                              EL TRABAJADOR
Representante Legal                       Nombre:
Nombre:                                   Cédula:
Cargo:


                    MINISTERIO DE TRABAJO Y DESARROLLO LABORAL
              [Este contrato debe ser registrado conforme al Art. 79 C.T.]

═══════════════════════════════════════════════════════════════════
''';
    }

    // TEMPLATE 3: SERVICIOS PROFESIONALES - PROFESIONAL (DEFAULT)
    return '''
═══════════════════════════════════════════════════════════════════
          CONTRATO DE PRESTACIÓN DE SERVICIOS PROFESIONALES
                    (Naturaleza Civil/Mercantil)
                    República de Panamá
═══════════════════════════════════════════════════════════════════

En la Ciudad de Panamá, República de Panamá, a los ${now.day} días del mes de ${_getMonthName(now.month)} de ${now.year}, comparecen:

───────────────────────────────────────────────────────────────────
EL CONTRATANTE:
───────────────────────────────────────────────────────────────────
$party1Name, [persona jurídica inscrita con RUC / persona natural con cédula] No. $party1Id, con domicilio en $party1Address, representada por [NOMBRE], en calidad de [CARGO].

En adelante "EL CONTRATANTE".

───────────────────────────────────────────────────────────────────
EL CONTRATISTA:
───────────────────────────────────────────────────────────────────
$party2Name, [persona jurídica inscrita con RUC / persona natural con cédula / profesional independiente] No. $party2Id, con domicilio en $party2Address, especializado en [ÁREA DE EXPERTICIA].

En adelante "EL CONTRATISTA".

Quienes convienen en celebrar el presente CONTRATO DE PRESTACIÓN DE SERVICIOS PROFESIONALES, de naturaleza civil/mercantil, bajo las siguientes estipulaciones:

═══════════════════════════════════════════════════════════════════
                         CLÁUSULAS
═══════════════════════════════════════════════════════════════════

PRIMERA – OBJETO DEL CONTRATO:
EL CONTRATANTE contrata los servicios profesionales independientes de EL CONTRATISTA para:

$services

Específicamente:
a) [Deliverable / Entregable específico 1]
b) [Deliverable / Entregable específico 2]
c) [Deliverable / Entregable específico 3]

SEGUNDA – NATURALEZA DEL CONTRATO:
Las partes declaran expresamente que este contrato es de naturaleza CIVIL/MERCANTIL y NO genera relación laboral alguna entre ellas. EL CONTRATISTA actúa como profesional independiente, sin subordinación jurídica ni dependencia respecto a EL CONTRATANTE, conservando autonomía técnica y administrativa en la ejecución de los servicios.

En consecuencia, no existe obligación de pago de prestaciones laborales tales como décimo tercer mes, vacaciones, primas, indemnizaciones, ni afiliación a la Caja de Seguro Social por parte de EL CONTRATANTE.

TERCERA – PLAZO DE EJECUCIÓN:
El plazo para la prestación de los servicios será de [___] ([____]) [días/semanas/meses], contados a partir del $startDate y hasta el $endDate, pudiendo prorrogarse por acuerdo mutuo escrito.

Los entregables se realizarán según el siguiente cronograma:
- Fase 1: [Fecha] - [Descripción]
- Fase 2: [Fecha] - [Descripción]
- Fase Final: [Fecha] - [Entrega total]

CUARTA – HONORARIOS PROFESIONALES:
EL CONTRATANTE pagará a EL CONTRATISTA por los servicios objeto de este contrato la suma total de BALBOAS B/.$amount ([_______BALBOAS CON 00/100]), más el Impuesto de Transferencia de Bienes Muebles y Servicios (ITBMS) del SIETE POR CIENTO (7%), para un total de B/.[_______.00].

Forma de pago:
- [___]% (B/.[____]) como anticipo a la firma del contrato.
- [___]% (B/.[____]) al completar [hito/fase intermedia].
- [___]% (B/.[____]) contra entrega final y aceptación de todos los entregables.

Los pagos se realizarán mediante transferencia bancaria a la cuenta No. [_____________] del [BANCO _______], previa presentación de factura fiscal debidamente autorizada por la Dirección General de Ingresos (DGI).

QUINTA – OBLIGACIONES DEL CONTRATISTA:
EL CONTRATISTA se obliga a:
a) Ejecutar los servicios con diligencia, eficiencia y calidad profesional.
b) Cumplir con los plazos y entregas pactadas.
c) Proveer sus propias herramientas, equipos y recursos necesarios.
d) Mantener indemne a EL CONTRATANTE de cualquier reclamo laboral.
e) Guardar absoluta confidencialidad sobre información del proyecto.
f) Entregar los trabajos conforme a las especificaciones técnicas acordadas.
g) Realizar correcciones o ajustes razonables solicitados.
h) Emitir factura fiscal por sus honorarios conforme a las normas de la DGI.

SEXTA – OBLIGACIONES DEL CONTRATANTE:
EL CONTRATANTE se obliga a:
a) Pagar los honorarios en los términos pactados.
b) Proporcionar la información necesaria para la ejecución del servicio.
c) Revisar y aprobar los entregables en un plazo razonable.
d) Brindar acceso a instalaciones o sistemas cuando sea requerido.

SÉPTIMA – IMPUESTOS Y RETENCIONES:
EL CONTRATISTA es responsable del pago de todos los impuestos que graven sus ingresos profesionales, incluyendo el Impuesto sobre la Renta (si aplica) y el ITBMS.

EL CONTRATANTE, en su calidad de agente retenedor, practicará las retenciones que correspondan conforme a la legislación tributaria vigente (Art. 701 y ss. del Código Fiscal).

OCTAVA – PROPIEDAD INTELECTUAL:
Todos los trabajos, diseños, desarrollos, documentos y productos generados en ejecución de este contrato serán propiedad exclusiva de EL CONTRATANTE, quien podrá usarlos, modificarlos o comercializarlos sin limitación alguna.

EL CONTRATISTA cede a EL CONTRATANTE todos los derechos patrimoniales sobre su creación, conservando únicamente los derechos morales en los términos del artículo [___] de la Ley 15 de 1994 sobre Derecho de Autor.

No obstante, EL CONTRATISTA podrá incluir el proyecto en su portafolio profesional, previa autorización de EL CONTRATANTE.

NOVENA – CONFIDENCIALIDAD:
EL CONTRATISTA se obliga a:
a) Guardar estricta confidencialidad sobre toda información técnica, comercial, financiera o estratégica a la que tenga acceso durante la ejecución del contrato.
b) No divulgar, reproducir ni utilizar dicha información para fines distintos a los de este contrato.
c) Devolver o destruir toda información confidencial al término del contrato.

Esta obligación subsistirá por un período de [CINCO (5)] años después de finalizado el contrato.

DÉCIMA – INDEPENDENCIA Y NO EXCLUSIVIDAD:
EL CONTRATISTA mantendrá absoluta independencia en la ejecución de los servicios, definiendo libremente sus métodos, horarios y lugar de trabajo, siempre cumpliendo con los entregables pactados.

Este contrato es NO EXCLUSIVO, por lo que EL CONTRATISTA podrá prestar servicios a terceros, salvo que éstos representen competencia directa o conflicto de interés con EL CONTRATANTE.

UNDÉCIMA – CONTROL DE CALIDAD Y ACEPTACIÓN:
EL CONTRATANTE tendrá un plazo de [___] días hábiles para revisar cada entregable. Si encuentra deficiencias, las notificará por escrito y EL CONTRATISTA tendrá [___] días para realizar las correcciones necesarias, sin costo adicional.

Transcurrido el plazo sin objeciones, el entregable se dará por aceptado.

DUODÉCIMA – INCUMPLIMIENTO Y PENALIDADES:
En caso de retraso en la entrega sin causa justificada, se aplicará una penalidad de [___]% del valor total por cada [día/semana] de retraso, hasta un máximo del [__]%.

El incumplimiento grave de las obligaciones principales facultará a la parte afectada para resolver el contrato y exigir indemnización por daños y perjuicios.

DÉCIMA TERCERA – FUERZA MAYOR:
Las partes quedan excusadas del cumplimiento de sus obligaciones en caso de fuerza mayor o caso fortuito debidamente comprobados (desastres naturales, actos de autoridad, etc.). Se suspenderán los plazos durante el evento y se reanudarán una vez superado.

DÉCIMA CUARTA – TERMINACIÓN ANTICIPADA:
Cualquiera de las partes podrá terminar anticipadamente este contrato mediante notificación escrita con [___] días de anticipación. En caso de terminación:
- EL CONTRATANTE pagará por los trabajos ejecutados y aceptados hasta la fecha.
- EL CONTRATISTA entregará todos los avances y materiales elaborados.

DÉCIMA QUINTA – CESIÓN:
Ninguna de las partes podrá ceder este contrato ni los derechos y obligaciones derivados del mismo sin consentimiento previo y por escrito de la otra parte.

DÉCIMA SEXTA – MODIFICACIONES:
Cualquier modificación o adenda a este contrato deberá constar por escrito y ser firmada por ambas partes.

DÉCIMA SÉPTIMA – SEGUROS:
EL CONTRATISTA deberá mantener vigentes durante la ejecución del contrato:
a) Seguro de responsabilidad civil profesional.
b) Seguro de vida y accidentes personales.
c) [Otros seguros específicos según la naturaleza del servicio].

DÉCIMA OCTAVA – NOTIFICACIONES:
Toda comunicación entre las partes se realizará por escrito a las direcciones y correos electrónicos señalados:

CONTRATANTE: [direcc@empresa.com]
CONTRATISTA: [contratista@email.com]

DÉCIMA NOVENA – LEGISLACIÓN APLICABLE:
Este contrato se interpreta y rige conforme al Código Civil de la República de Panamá, Código de Comercio y demás leyes mercantiles aplicables.

VIGÉSIMA – RESOLUCIÓN DE CONTROVERSIAS:
Las partes se comprometen a resolver amigablemente cualquier diferencia. De no ser posible, se someten a la jurisdicción de los Tribunales Ordinarios de Panamá, renunciando a cualquier otro fuero.

───────────────────────────────────────────────────────────────────

En fe de lo cual, las partes firman el presente contrato en DOS (2) ejemplares de igual tenor y valor, en la ciudad y fecha arriba indicados.


_________________________                 _________________________
EL CONTRATANTE                            EL CONTRATISTA
Nombre:                                   Nombre:
Cargo:                                    Cédula/RUC:
RUC:


                    TESTIGOS:

_________________________                 _________________________
TESTIGO 1                                 TESTIGO 2
Nombre:                                   Nombre:
Cédula:                                   Cédula:

═══════════════════════════════════════════════════════════════════
''';
  }

  String _getMonthName(int month) {
    const months = ['enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio', 
                    'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'];
    return months[month - 1];
  }

  String _generateProductContent(AiGenericRequest req) {
    final businessName = req.context?.split('\n').firstWhere((l) => l.contains('Nombre'), orElse: () => '').replaceAll('- Nombre Comercial: ', '').trim() ?? '';
    final rubro = req.context?.split('\n').firstWhere((l) => l.contains('Rubro'), orElse: () => 'Negocio').replaceAll('- Rubro/Industria: ', '').trim() ?? 'Negocio';
    
    // Extract form data with fallbacks
    final fd = req.formData ?? {};
    final price = fd['price'] ?? '[_____.00]';
    final material = fd['material'] ?? '[Especificar materiales/componentes]';
    final dimensions = fd['dimensions'] ?? '[Medidas exactas si aplica]';
    final warranty = fd['warranty'] ?? '[__]';
    final deliveryTime = fd['deliveryTime'] ?? '[Inmediata / 2-5 días hábiles / Según coordinación]';
    final phone = fd['phone'] ?? '[+507 ____-____]';
    final email = fd['email'] ?? '[ventas@empresa.com]';
    final address = fd['address'] ?? '[Ubicación física en Panamá]';
    
    return '''
══════════════════════════════════════════════════════════════
               FICHA TÉCNICA PROFESIONAL DE PRODUCTO
                  ${businessName.isNotEmpty ? businessName : '[TU EMPRESA]'}
══════════════════════════════════════════════════════════════

📦 PRODUCTO/SERVICIO:
${req.prompt}

══════════════════════════════════════════════════════════════
                    DESCRIPCIÓN COMERCIAL
══════════════════════════════════════════════════════════════

${req.prompt} es la solución ideal para clientes que buscan calidad superior y resultados comprobados. Diseñado específicamente para el mercado panameño, este producto/servicio supera las expectativas gracias a su combinación única de innovación, durabilidad y precio competitivo.

Somos especialistas en ${rubro.isNotEmpty ? rubro : 'este sector'} con años de experiencia sirviendo a clientes satisfechos en toda la República de Panamá.

══════════════════════════════════════════════════════════════
                 CARACTERÍSTICAS TÉCNICAS
══════════════════════════════════════════════════════════════

✓ MATERIAL/COMPOSICIÓN: $material
✓ DIMENSIONES/TAMAÑO: $dimensions
✓ PESO/RENDIMIENTO: [Indicadores cuantificables]
✓ COLOR/PRESENTACIÓN: [Variantes disponibles]
✓ CONTENIDO/DURACIÓN: [Cantidad o período de servicio]
✓ ORIGEN/FABRICACIÓN: [Local/Importado - País de origen]

══════════════════════════════════════════════════════════════
                    BENEFICIOS CLAVE
══════════════════════════════════════════════════════════════

🌟 CALIDAD COMPROBADA
Materiales/procesos de primera categoría que garantizan resultados duraderos y satisfacción total.

⚡ RAPIDEZ Y EFICIENCIA
$deliveryTime. Resultados visibles desde el primer día.

💎 RELACIÓN PRECIO-VALOR
Inversión inteligente: pagas por calidad premium a precio justo, sin intermediarios.

🇵🇦 ADAPTADO A PANAMÁ
Diseñado considerando el clima, regulaciones y necesidades específicas del mercado panameño.

🛡️ GARANTÍA Y SOPORTE
Garantía de $warranty. Servicio post-venta y asistencia técnica incluida.

══════════════════════════════════════════════════════════════
                    USO RECOMENDADO
══════════════════════════════════════════════════════════════

IDEAL PARA:
• [Tipo de cliente o industria 1]
• [Tipo de cliente o industria 2]
• [Tipo de cliente o industria 3]

APLICACIONES:
• [Uso principal 1]
• [Uso principal 2]
• [Uso principal 3]

══════════════════════════════════════════════════════════════
                  INFORMACIÓN COMERCIAL
══════════════════════════════════════════════════════════════

💰 PRECIO: B/. $price Balboas
   (Precio sujeto a cambios. Incluye ITBMS del 7% si aplica)

📦 PRESENTACIÓN: [Unidad / Pack / Servicio individual]
🚚 ENTREGA: $deliveryTime
💳 FORMAS DE PAGO:
   • Efectivo
   • Transferencia bancaria (BAC, Banistmo, General, otros)
   • Yappy / Nequi
   • Tarjeta de crédito / débito
   • [Plan de financiamiento disponible]

══════════════════════════════════════════════════════════════
                 TESTIMONIOS Y CREDIBILIDAD
══════════════════════════════════════════════════════════════

⭐⭐⭐⭐⭐ "Excelente calidad y atención. Lo recomiendo 100%."
- Cliente Satisfecho, Ciudad de Panamá

⭐⭐⭐⭐⭐ "Mejor inversión que hice para mi negocio este año."
- Empresario Local, Chiriquí

══════════════════════════════════════════════════════════════
               GARANTÍA Y POLÍTICAS
══════════════════════════════════════════════════════════════

✅ GARANTÍA: $warranty contra defectos de fabricación
✅ DEVOLUCIÓN: Hasta 7 días si no cumple expectativas (condiciones aplican)
✅ MANTENIMIENTO: [Gratuito primer año / Plan opcional disponible]
✅ CUMPLIMIENTO LEGAL: Producto/Servicio cumple con normativas panameñas

══════════════════════════════════════════════════════════════
                   CONTACTO Y PEDIDOS
══════════════════════════════════════════════════════════════

📞 WhatsApp: $phone
📧 Email: $email
🌐 Web: [www.tuempresa.com]
📍 Dirección: $address
⏰ Horario: Lunes a Viernes 8:00 AM - 6:00 PM | Sábados 9:00 AM - 1:00 PM

══════════════════════════════════════════════════════════════
                    ¡ORDENA AHORA!
        Llama/Escríbenos y lleva tu ${req.prompt} HOY mismo
══════════════════════════════════════════════════════════════
''';
  }

  String _generateStrategyContent(AiGenericRequest req) {
    final businessName = req.context?.split('\n').firstWhere((l) => l.contains('Nombre'), orElse: () => '').replaceAll('- Nombre Comercial: ', '').trim() ?? '';
    final rubro = req.context?.split('\n').firstWhere((l) => l.contains('Rubro'), orElse: () => 'Tu Industria').replaceAll('- Rubro/Industria: ', '').trim() ?? 'Tu Industria';
    final ubicacion = req.context?.split('\n').firstWhere((l) => l.contains('Ubicación'), orElse: () => 'Panamá').replaceAll('- Ubicación: ', '').trim() ?? 'Panamá';
    
    // Extract form data for strategies
    final fd = req.formData ?? {};
    final budget = fd['budget'] ?? '[___,___]';
    final marketingBudget = fd['marketingBudget'] ?? '[___,___]';
    final techBudget = fd['techBudget'] ?? '[___,___]';
    final responsibleName = fd['responsibleName'] ?? '[Nombre del Responsable]';
    final responsibleTitle = fd['responsibleTitle'] ?? '[Gerente General / Director Comercial]';
    final targetCustomers = fd['targetCustomers'] ?? '[100]';
    final salesIncrease = fd['salesIncrease'] ?? '[30]';
    
    return '''
══════════════════════════════════════════════════════════════
                  PLAN ESTRATÉGICO DE NEGOCIO
              ${businessName.isNotEmpty ? businessName : '[TU EMPRESA]'}
                    $rubro - $ubicacion
══════════════════════════════════════════════════════════════

🎯 OBJETIVO ESTRATÉGICO:
${req.prompt}

Fecha de Elaboración: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}
Período de Ejecución: ${DateTime.now().year} - ${DateTime.now().year + 1}
Responsable: $responsibleName, $responsibleTitle

══════════════════════════════════════════════════════════════
              I. RESUMEN EJECUTIVO
══════════════════════════════════════════════════════════════

El logro del objetivo "${req.prompt}" tendrá impactos directos en la rentabilidad, posicionamiento y estabilidad financiera de la empresa. Se estima alcanzar:
- Incremento de ventas: +$salesIncrease%
- Nuevos clientes: $targetCustomers clientes
- ROI esperado: 300% (B/.3 por cada B/.1 invertido)
- Recuperación de inversión: 6-9 meses

VISIÓN GENERAL:
Posicionar nuestra empresa como referente en ${rubro} en la región de ${ubicacion}, incrementando la participación de mercado y la satisfacción del cliente mediante innovación constante y excelencia operativa.

INVERSIÓN ESTIMADA: B/. $budget Balboas
RETORNO ESPERADO (ROI): 300% en 12 meses
PLAZO DE IMPLEMENTACIÓN: 6-12 meses

══════════════════════════════════════════════════════════════
              II. ANÁLISIS SITUACIONAL (SWOT)
══════════════════════════════════════════════════════════════

┌─────────────────────────────────────────────────────────────┐
│  FORTALEZAS (Strengths)                                     │
├─────────────────────────────────────────────────────────────┤
│ ✓ Experiencia comprobada en ${rubro}                       │
│ ✓ Ubicación estratégica en ${ubicacion}                    │
│ ✓ Cartera de clientes leales y satisfechos                 │
│ ✓ Equipo comprometido y capacitado                         │
│ ✓ Diferenciación por calidad y servicio                    │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│  OPORTUNIDADES (Opportunities)                              │
├─────────────────────────────────────────────────────────────┤
│ ✓ Crecimiento del mercado panameño post-pandemia           │
│ ✓ Digitalización de negocios (e-commerce, redes sociales)  │
│ ✓ Demanda de productos/servicios locales de calidad        │
│ ✓ Alianzas estratégicas con proveedores y distribuidores   │
│ ✓ Programas gubernamentales de apoyo a MIPYMES             │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│  DEBILIDADES (Weaknesses)                                   │
├─────────────────────────────────────────────────────────────┤
│ ⚠ Presupuesto limitado para marketing masivo               │
│ ⚠ Dependencia de canales tradicionales de venta            │
│ ⚠ Falta de automatización en procesos clave                │
│ ⚠ Competencia con marcas internacionales establecidas      │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│  AMENAZAS (Threats)                                         │
├─────────────────────────────────────────────────────────────┤
│ ⚠ Inflación y aumento de costos operativos                 │
│ ⚠ Entrada de competidores con precios más bajos            │
│ ⚠ Cambios en regulaciones fiscales/laborales               │
│ ⚠ Crisis económicas globales que afecten consumo local     │
└─────────────────────────────────────────────────────────────┘

══════════════════════════════════════════════════════════════
        III. ESTRATEGIAS Y TÁCTICAS DE IMPLEMENTACIÓN
══════════════════════════════════════════════════════════════

───────────────────────────────────────────────────────────────
FASE 1: ATRACCIÓN (Mes 1-3)
Objetivo: Generar conocimiento de marca y captar prospectos
───────────────────────────────────────────────────────────────

📱 MARKETING DIGITAL:
   • Crear perfiles profesionales en Instagram, Facebook y TikTok
   • Publicar contenido educativo 3 veces por semana
   • Invertir B/. 300/mes en anuncios segmentados (Meta Ads)
   • Colaborar con influencers locales (micro-influencers)

🎯 SEO Y CONTENIDO:
   • Optimizar Google My Business con fotos y reseñas
   • Blog con artículos sobre ${rubro} (2 posts/mes)
   • Palabras clave locales: "${req.prompt} Panamá"

🤝 NETWORKING:
   • Asistir a 2 eventos de networking/ferias comerciales
   • Unirse a cámaras de comercio locales
   • Buscar alianzas con negocios complementarios

───────────────────────────────────────────────────────────────
FASE 2: CONEXIÓN (Mes 3-6)
Objetivo: Construir relación y generar confianza
───────────────────────────────────────────────────────────────

🎁 LEAD MAGNETS:
   • Ofrecer guía gratuita "Los 10 Secretos de [Tema]"
   • Descuento del 15% para primeros clientes
   • Asesoría inicial gratuita de 30 minutos

📧 EMAIL MARKETING:
   • Construir lista de correos (mínimo 500 contactos)
   • Enviar newsletter quincenal con valor agregado
   • Secuencia automatizada de bienvenida (3 emails)

💬 ATENCIÓN PERSONALIZADA:
   • Responder inquietudes en WhatsApp en menos de 2 horas
   • Llamadas de seguimiento a prospectos calificados
   • Demostración/prueba gratuita del producto/servicio

───────────────────────────────────────────────────────────────
FASE 3: CONVERSIÓN (Mes 6-9)
Objetivo: Transformar prospectos en clientes pagadores
───────────────────────────────────────────────────────────────

💰 OFERTAS IRRESISTIBLES:
   • Promoción limitada: "3x2" o "50% desc. segunda compra"
   • Garantía extendida de satisfacción (30 días)
   • Bonos adicionales por compra inmediata

✅ PRUEBA SOCIAL:
   • Publicar 20+ testimonios reales con foto/video
   • Casos de éxito documentados (antes/después)
   • Certificaciones y membresías profesionales

📊 RETARGETING:
   • Anuncios para visitantes web que no compraron
   • Remarketing en redes sociales
   • Recordatorios por correo/WhatsApp

───────────────────────────────────────────────────────────────
FASE 4: FIDELIZACIÓN Y REFERIDOS (Mes 9-12)
Objetivo: Retener clientes y generar ventas recurrentes
───────────────────────────────────────────────────────────────

🎖️ PROGRAMA DE LEALTAD:
   • Puntos por cada compra canjeables por descuentos
   • Acceso VIP a lanzamientos y promociones exclusivas
   • Cumpleaños del cliente = regalo especial

👥 SISTEMA DE REFERIDOS:
   • Cliente que refiere = 10% de descuento
   • Cliente nuevo referido = 10% de descuento
   • Premios especiales para "embajadores" (5+ referidos)

📞 FOLLOW-UP POST-VENTA:
   • Llamada de satisfacción 7 días después de compra
   • Encuesta NPS (Net Promoter Score)
   • Soporte técnico/consultoría continua

══════════════════════════════════════════════════════════════
              IV. PRESUPUESTO Y RECURSOS
══════════════════════════════════════════════════════════════

Presupuesto Total Estimado: B/. $budget

Desglose por Rubro:
1. Marketing y Publicidad: B/. $marketingBudget (40%)
2. Tecnología y Herramientas: B/. $techBudget (30%)
3. Capacitación y Talento Humano: B/. [___,___] (20%)
4. Contingencias e Imprevistos: B/. [___,___] (10%)

RECURSOS HUMANOS:
• Gerente de Marketing/Ventas: [Nombre - Dedicación parcial/total]
• Community Manager: [Interno/Freelance]
• Diseñador Gráfico: [Por proyecto]

══════════════════════════════════════════════════════════════
          V. INDICADORES CLAVE DE DESEMPEÑO (KPIs)
══════════════════════════════════════════════════════════════

📊 MÉTRICAS COMERCIALES:
   • Ventas Totales: Incremento del [30]% en 12 meses
   • Clientes Nuevos: [100] clientes nuevos/año
   • Ticket Promedio: Aumentar de B/. [___] a B/. [___]
   • Tasa de Conversión: Lograr el [5]% (de prospectos a ventas)

📱 MÉTRICAS DIGITALES:
   • Seguidores en Redes: Llegar a [5,000] followers
   • Alcance Mensual: [50,000] personas alcanzadas/mes
   • Engagement Rate: Mínimo [3]%
   • Visitas Web: [2,000] visitas mensuales

💰 MÉTRICAS FINANCIERAS:
   • ROI de Marketing: Mínimo [300]% (por cada B/.1 invertido = B/.4 retorno)
   • Costo de Adquisición Cliente (CAC): Máximo B/. [___]
   • Lifetime Value (LTV): Mínimo B/. [___]
   • Margen de Utilidad: Mantener/mejorar [__]%

══════════════════════════════════════════════════════════════
                VI. CRONOGRAMA DE EJECUCIÓN
══════════════════════════════════════════════════════════════

MES 1-2:  ✓ Crear perfiles digitales y contenido inicial
          ✓ Lanzar primera campaña publicitaria
          ✓ Diseñar lead magnets

MES 3-4:  ✓ Implementar email marketing
          ✓ Asistir a primer evento de networking
          ✓ Optimizar procesos de atención

MES 5-6:  ✓ Evaluar resultados Fase 1
          ✓ Lanzar promoción de conversión
          ✓ Recopilar primeros testimonios

MES 7-9:  ✓ Escalar anuncios exitosos
          ✓ Activar programa de referidos
          ✓ Ajustar estrategia según data

MES 10-12: ✓ Consolidar programa de lealtad
           ✓ Proyectar estrategia siguiente año
           ✓ Celebrar logros con equipo

══════════════════════════════════════════════════════════════
              VII. RIESGOS Y PLAN DE CONTINGENCIA
══════════════════════════════════════════════════════════════

RIESGO 1: Baja respuesta inicial en redes sociales
MITIGACIÓN: Invertir en microinfluencers y sorteos para viralizar
            contenido los primeros 60 días.

RIESGO 2: Presupuesto insuficiente
MITIGACIÓN: Priorizar tácticas orgánicas (SEO, contenido) y negociar
            pagos diferidos con proveedores.

RIESGO 3: Cambios en algoritmos de redes
MITIGACIÓN: Diversificar canales (no depender solo de una plataforma).

══════════════════════════════════════════════════════════════
                  VIII. CONCLUSIÓN
══════════════════════════════════════════════════════════════

Este plan estratégico proporciona una hoja de ruta clara y ejecutable para alcanzar "${req.prompt}". El éxito dependerá de la disciplina en la ejecución, el monitoreo constante de KPIs y la capacidad de adaptación a los cambios del mercado.

PRÓXIMOS PASOS INMEDIATOS:
1. Presentar plan al equipo y asignar responsabilidades
2. Aprobar presupuesto inicial (Semana 1)
3. Lanzar primeras acciones de Fase 1 (Mes 1)

REVISIONES PERIÓDICAS:
• Reunión semanal de seguimiento (Lunes 9:00 AM)
• Reporte mensual de KPIs
• Ajuste trimestral de estrategias

══════════════════════════════════════════════════════════════
              ¡MANOS A LA OBRA! 🚀
     El éxito está en la ejecución consistente del plan
══════════════════════════════════════════════════════════════

Elaborado por: ${businessName.isNotEmpty ? 'Equipo ' + businessName : 'Empodérate IA'}
Fecha: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}
''';
  }

  String _generateProcessContent(AiGenericRequest req) {
    final businessName = req.context?.split('\n').firstWhere((l) => l.contains('Nombre'), orElse: () => '').replaceAll('- Nombre Comercial: ', '').trim() ?? '';
    
    // Extract form data for processes
    final fd = req.formData ?? {};
    final responsibleName = fd['responsibleName'] ?? '[Nombre del Responsable]';
    final responsibleTitle = fd['responsibleTitle'] ?? '[Gerente/Supervisor del Área]';
    final approverName = fd['approverName'] ?? '[Gerente General]';
    final department = fd['department'] ?? '[Especificar]';
    final targetPersonnel = fd['targetPersonnel'] ?? '[Cajeros, Vendedores, Operarios, Técnicos, etc.]';
    final estimatedTime = fd['estimatedTime'] ?? '[___ minutos]';
    
    return '''
══════════════════════════════════════════════════════════════
         MANUAL DE PROCEDIMIENTOS OPERATIVOS ESTÁNDAR (SOP)
              ${businessName.isNotEmpty ? businessName : '[TU EMPRESA]'}
══════════════════════════════════════════════════════════════

📋 PROCEDIMIENTO: ${req.prompt}
📅 Fecha de Emisión: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}
📝 Versión: 1.0
✅ Estado: Vigente

──────────────────────────────────────────────────────────────
                 CONTROL DE DOCUMENTACIÓN
──────────────────────────────────────────────────────────────

Elaborado por:    $responsibleName
Cargo:            $responsibleTitle
Aprobado por:     $approverName
Fecha Aprobación: [__/__/____]
Próxima Revisión: [__/__/____] (Cada 6-12 meses)

Distribución:
☑ Gerencia General
☑ Jefe de Área responsable
☑ Personal operativo involucrado
☑ Recursos Humanos (archivo)

══════════════════════════════════════════════════════════════
              I. OBJETIVO DEL PROCEDIMIENTO
══════════════════════════════════════════════════════════════

Establecer los pasos estandarizados para ejecutar "${req.prompt}" de manera consistente, eficiente y conforme a los estándares de calidad de la empresa, garantizando la satisfacción del cliente y la optimización de recursos.

══════════════════════════════════════════════════════════════
                  II. ALCANCE
══════════════════════════════════════════════════════════════

APLICA A:
• Departamento/Área: $department
• Personal: $targetPersonnel
• Ubicación: [Todas las sucursales / Sede principal]

NO APLICA A:
• [Casos excepcionales o situaciones fuera de este procedimiento]

══════════════════════════════════════════════════════════════
              III. RESPONSABILIDADES
══════════════════════════════════════════════════════════════

┌────────────────────────┬────────────────────────────────────┐
│  CARGO                 │  RESPONSABILIDAD                   │
├────────────────────────┼────────────────────────────────────┤
│ $approverName          │ Aprobar y auditar cumplimiento     │
│ $responsibleTitle      │ Garantizar ejecución y capacitar   │
│ Empleado Operativo     │ Ejecutar procedimiento fielmente   │
│ Control de Calidad     │ Verificar y documentar resultados  │
└────────────────────────┴────────────────────────────────────┘

══════════════════════════════════════════════════════════════
        IV. DEFINICIONES Y TÉRMINOS CLAVE
══════════════════════════════════════════════════════════════

• SOP: Standard Operating Procedure (Procedimiento Operativo Estándar)
• KPI: Key Performance Indicator (Indicador Clave de Desempeño)
• QA: Quality Assurance (Aseguramiento de Calidad)
• [Término específico 1]: [Definición]
• [Término específico 2]: [Definición]

══════════════════════════════════════════════════════════════
          V. MATERIALES Y RECURSOS NECESARIOS
══════════════════════════════════════════════════════════════

EQUIPOS:
☑ [Computadora / Caja registradora / Herramienta específica]
☑ [Software o sistema requerido]
☑ [Equipos de protección personal si aplica]

DOCUMENTOS/FORMATOS:
☑ [Formato de registro/control]
☑ [Checklist de verificación]
☑ [Documento de respaldo/comprobante]

INSUMOS:
☑ [Material específico 1]
☑ [Material específico 2]

══════════════════════════════════════════════════════════════
        VI. DESCRIPCIÓN PASO A PASO DEL PROCEDIMIENTO
══════════════════════════════════════════════════════════════

┌─────────────────────────────────────────────────────────────┐
│ PASO 1: PREPARACIÓN INICIAL                                 │
├─────────────────────────────────────────────────────────────┤
│ Responsable: [Cargo]                                        │
│ Tiempo Estimado: [___ minutos]                              │
├─────────────────────────────────────────────────────────────┤
│ ACCIONES:                                                   │
│ 1.1. Verificar que todos los materiales estén disponibles  │
│ 1.2. Encender/preparar equipo necesario                     │
│ 1.3. Revisar que el área de trabajo esté limpia y ordenada │
│ 1.4. Consultar agenda/programación del día                 │
│                                                             │
│ ⚠ PRECAUCIÓN:                                                │
│ • No iniciar si falta algún material crítico                │
│ • Reportar de inmediato cualquier equipo dañado            │
│                                                             │
│ ✓ CRITERIO DE CALIDAD:                                      │
│ • Área de trabajo 100% organizada                          │
│ • Checklist de inicio completo                             │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ PASO 2: RECEPCIÓN / INICIO DEL SERVICIO                    │
├─────────────────────────────────────────────────────────────┤
│ Responsable: [Cargo]                                        │
│ Tiempo Estimado: [___ minutos]                              │
├─────────────────────────────────────────────────────────────┤
│ ACCIONES:                                                   │
│ 2.1. Recibir al cliente/solicitud con saludo cordial       │
│ 2.2. Identificar necesidad específica mediante preguntas   │
│ 2.3. Registrar datos en sistema (Nombre, Cédula, Detalle)  │
│ 2.4. Asignar número de turno/orden de trabajo              │
│ 2.5. Informar tiempo estimado de atención/entrega          │
│                                                             │
│ 💬 FRASE ESTÁNDAR:                                           │
│ "Buenos días, bienvenido a [EMPRESA]. ¿En qué podemos       │
│  ayudarle hoy?"                                             │
│                                                             │
│ ✓ CRITERIO DE CALIDAD:                                      │
│ • Cliente informado de tiempos                             │
│ • Datos completos en sistema                               │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ PASO 3: PROCESAMIENTO Y EJECUCIÓN                          │
├─────────────────────────────────────────────────────────────┤
│ Responsable: [Cargo]                                        │
│ Tiempo Estimado: [___ minutos]                              │
├─────────────────────────────────────────────────────────────┤
│ ACCIONES:                                                   │
│ 3.1. Revisar orden de trabajo y prioridad                  │
│ 3.2. Ejecutar tarea principal según especificaciones       │
│ 3.3. Aplicar estándares de calidad en cada sub-paso        │
│ 3.4. Documentar avances en sistema/formato                 │
│ 3.5. Solicitar supervisión si se detecta anomalía          │
│                                                             │
│ ⚠ PUNTOS CRÍTICOS:                                           │
│ • [Aspecto delicado que NO debe fallar]                    │
│ • [Medida de seguridad obligatoria]                        │
│ • [Verificación intermedia requerida]                      │
│                                                             │
│ ✓ CRITERIO DE CALIDAD:                                      │
│ • Trabajo completado sin errores                           │
│ • Tiempo dentro de estándar ([___] minutos)                │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ PASO 4: VERIFICACIÓN Y CONTROL DE CALIDAD                  │
├─────────────────────────────────────────────────────────────┤
│ Responsable: [Supervisor / QA]                             │
│ Tiempo Estimado: [___ minutos]                              │
├─────────────────────────────────────────────────────────────┤
│ ACCIONES:                                                   │
│ 4.1. Revisar que el producto/servicio cumpla especificaciones│
│ 4.2. Aplicar checklist de calidad (ver Anexo A)            │
│ 4.3. Aprobar trabajo o devolver para corrección            │
│ 4.4. Firmar/sellar formato de control de calidad           │
│                                                             │
│ 🔍 CHECKLIST DE VERIFICACIÓN:                               │
│ ☑ [Aspecto 1 cumple estándar]                               │
│ ☑ [Aspecto 2 cumple estándar]                               │
│ ☑ [Aspecto 3 cumple estándar]                               │
│ ☑ [Presentación final impecable]                            │
│                                                             │
│ ✓ CRITERIO DE CALIDAD:                                      │
│ • 100% de checklist aprobado                               │
│ • Cero defectos detectados                                 │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ PASO 5: ENTREGA Y CIERRE                                   │
├─────────────────────────────────────────────────────────────┤
│ Responsable: [Cargo]                                        │
│ Tiempo Estimado: [___ minutos]                              │
├─────────────────────────────────────────────────────────────┤
│ ACCIONES:                                                   │
│ 5.1. Llamar al cliente/notificar que el servicio está listo│
│ 5.2. Explicar el trabajo realizado y beneficios            │
│ 5.3. Solicitar conformidad y firma en comprobante          │
│ 5.4. Procesar pago si aplica y entregar factura            │
│ 5.5. Agradecer y ofrecer asistencia futura                 │
│ 5.6. Archivar documentación en expediente                  │
│                                                             │
│ 💬 FRASE DE CIERRE:                                          │
│ "Gracias por confiar en nosotros. Si tiene alguna duda,    │
│  no dude en contactarnos. ¡Que tenga un excelente día!"    │
│                                                             │
│ ✓ CRITERIO DE CALIDAD:                                      │
│ • Cliente satisfecho (NPS ≥ 8/10)                          │
│ • Documentación completa archivada                         │
└─────────────────────────────────────────────────────────────┘

══════════════════════════════════════════════════════════════
          VII. DIAGRAMA DE FLUJO DEL PROCESO
══════════════════════════════════════════════════════════════

        [INICIO]
           ↓
    ┌──────────────┐
    │ Preparación  │
    │   Inicial    │
    └──────┬───────┘
           ↓
    ┌──────────────┐
    │  Recepción   │
    │   Cliente    │
    └──────┬───────┘
           ↓
    ┌──────────────┐       ¿Anomalía?
    │  Ejecución   ├─────────→ [Supervisor]
    │    Tarea     │              ↓
    └──────┬───────┘          [Corregir]
           ↓                      ↓
    ┌──────────────┐              │
    │ Verificación │←─────────────┘
    │   Calidad    │
    └──────┬───────┘
           ↓
       ¿Aprobado?
      ↙         ↘
    SÍ          NO → [Rechazar/Rehacer]
     ↓
┌──────────────┐
│   Entrega    │
│    Final     │
└──────┬───────┘
       ↓
    [FIN]

══════════════════════════════════════════════════════════════
        VIII. INDICADORES DE DESEMPEÑO (KPIs)
══════════════════════════════════════════════════════════════

📊 EFICIENCIA:
   • Tiempo Promedio de Ejecución: ≤ [___] minutos
   • Productividad: Mínimo [___] procesos completados/día
   • Utilización de Recursos: ≥ [85]%

✅ CALIDAD:
   • Tasa de Defectos: ≤ [2]% (Meta: 0%)
   • Productos/Servicios Aprobados en Primera: ≥ [95]%
   • Re-trabajos: ≤ [5]%

👤 SATISFACCIÓN:
   • NPS (Net Promoter Score): ≥ [8]/10
   • Quejas Relacionadas: ≤ [1]/mes
   • Cumplimiento de Tiempo Prometido: ≥ [90]%

══════════════════════════════════════════════════════════════
          IX. MANEJO DE SITUACIONES ESPECIALES
══════════════════════════════════════════════════════════════

CASO 1: CLIENTE INSATISFECHO
→ Escuchar activamente sin interrumpir
→ Disculparse sinceramente
→ Ofrecer solución inmediata (reemplazo, descuento, etc.)
→ Escalar a supervisor si es necesario
→ Documentar en formato de incidencias

CASO 2: FALTA DE MATERIALES/INSUMOS
→ Informar al cliente del retraso estimado
→ Ofrecer alternativas (otro producto, fecha posterior)
→ Notificar a compras/logística de inmediato
→ Registrar en sistema para seguimiento

CASO 3: EQUIPO DAÑADO
→ NO intentar reparar sin autorización
→ Colocar señal "FUERA DE SERVICIO"
→ Llamar a mantenimiento/proveedor
→ Usar equipo de respaldo si está disponible
→ Reportar al supervisor con memo escrito

══════════════════════════════════════════════════════════════
            X. CAPACITACIÓN Y ENTRENAMIENTO
══════════════════════════════════════════════════════════════

INDUCCIÓN INICIAL:
□ Lectura completa de este SOP
□ Demostración práctica por supervisor (2 horas)
□ Práctica supervisada (mínimo 5 procesos)
□ Evaluación teórica (aprobación ≥ 80%)
□ Firma de confirmación de entendimiento

CAPACITACIÓN CONTINUA:
• Refrescamiento semestral obligatorio
• Reuniones semanales de mejora continua
• Actualizaciones cuando haya cambios en el procedimiento

══════════════════════════════════════════════════════════════
              XI. SEGURIDAD Y NORMATIVAS
══════════════════════════════════════════════════════════════

⚠ EQUIPO DE PROTECCIÓN PERSONAL (EPP):
   • [Guantes, mascarillas, lentes, etc. según aplique]

🔒 CUMPLIMIENTO LEGAL:
   • Ley [___] de la República de Panamá
   • Normas de sanidad/seguridad ocupacional
   • Protección de Datos (Ley 81/2019 si aplica)

══════════════════════════════════════════════════════════════
              XII. CONTROL DE CAMBIOS
══════════════════════════════════════════════════════════════

┌─────────┬────────────┬───────────────┬──────────────────────┐
│ Versión │   Fecha    │  Responsable  │  Descripción Cambio  │
├─────────┼────────────┼───────────────┼──────────────────────┤
│  1.0    │ [__/__/__] │ [Nombre]      │ Emisión inicial      │
│         │            │               │                      │
│         │            │               │                      │
└─────────┴────────────┴───────────────┴──────────────────────┘

══════════════════════════════════════════════════════════════
                     ANEXOS
══════════════════════════════════════════════════════════════

ANEXO A: Checklist de Verificación de Calidad
ANEXO B: Formato de Registro de Incidencias
ANEXO C: Diagrama detallado del flujo
ANEXO D: Contactos de emergencia y soporte

══════════════════════════════════════════════════════════════
                  FIRMA DE APROBACIÓN
══════════════════════════════════════════════════════════════

_____________________________          ____________________
Gerente General                        Fecha
[Nombre]


_____________________________          ____________________
Jefe de Área                           Fecha
[Nombre]

══════════════════════════════════════════════════════════════
    ESTE DOCUMENTO ES PROPIEDAD DE ${businessName.isNotEmpty ? businessName.toUpperCase() : '[TU EMPRESA]'}
         Prohibida su reproducción sin autorización
══════════════════════════════════════════════════════════════
''';
  }

  String _inferBusiness(String prompt) {
    if (prompt.toLowerCase().contains('zapatos') || prompt.toLowerCase().contains('ropa')) return 'Moda y Estilo';
    if (prompt.toLowerCase().contains('comida') || prompt.toLowerCase().contains('menu')) return 'Gastronomía';
    if (prompt.toLowerCase().contains('casa') || prompt.toLowerCase().contains('venta')) return 'Bienes Raíces';
    return 'Servicios Profesionales';
  }

  String _inferSegment(String prompt) {
    if (prompt.toLowerCase().contains('mujer') || prompt.toLowerCase().contains('emprendedora')) return 'Mujeres Emprendedoras';
    if (prompt.toLowerCase().contains('jóvenes') || prompt.toLowerCase().contains('estudiante')) return 'Jóvenes Estudiantes';
    return 'Público Objetivo';
  }
}
