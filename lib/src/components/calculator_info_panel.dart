import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:url_launcher/url_launcher.dart';

// --- CONFIGURATION CLASS ---
class CalculatorInfoConfig {
  final String topTitle;
  final List<String> topBullets;
  final List<String> howToSteps;
  final List<String> exampleLines;
  final List<String> interpretation;
  final List<String> commonErrors;
  final String? externalLinkLabel;
  final String? externalLinkUrl;

  const CalculatorInfoConfig({
    required this.topTitle,
    required this.topBullets,
    required this.howToSteps,
    required this.exampleLines,
    required this.interpretation,
    required this.commonErrors,
    this.externalLinkLabel,
    this.externalLinkUrl,
  });

}

// --- CONTENT MAP ---
final Map<String, CalculatorInfoConfig> calculatorConfigs = {
  'fixed_costs': const CalculatorInfoConfig(
    topTitle: '¿Qué hace esta calculadora?',
    topBullets: [
      'Calcula cuánto te cuesta mantener tu negocio abierto cada mes.',
      'Te ayuda a definir metas de venta y controlar gastos que no dependen de vender más.',
    ],
    howToSteps: [
      '1) Agrega tus gastos fijos: alquiler, internet, seguros, suscripciones, cuotas, etc.',
      '2) Elige la frecuencia (mensual, anual…) y la calculadora lo convierte a “mensual equivalente”.',
      '3) Mira tu total mensual y decide: reducir gastos o aumentar ventas para cubrirlos.',
    ],
    exampleLines: [
      'Alquiler: B/. 600/mes',
      'Internet: B/. 45/mes',
      'Seguro: B/. 360/año (= B/. 30/mes)',
      'Suscripciones: B/. 25/mes',
      'Total fijo mensual estimado: B/. 700',
    ],
    interpretation: [
      'Si tu costo fijo mensual es alto, necesitas vender más solo para “no perder”.',
      'Úsalo para decidir si puedes sostenerte en meses lentos.',
    ],
    commonErrors: [
      'Confundir costos fijos con variables (ingredientes/insumos son variables).',
      'Olvidar prorratear gastos anuales.',
      'No incluir suscripciones pequeñas (se suman).',
    ],
  ),
  'margin': const CalculatorInfoConfig(
    topTitle: '¿Qué hace esta calculadora?',
    topBullets: [
      'Te dice cuánto ganas por venta y qué tan rentable es tu precio.',
      'Sirve para ajustar precios, costos y promociones sin vender a pérdida.',
    ],
    howToSteps: [
      '1) Escribe tu precio de venta.',
      '2) Escribe tu costo variable (ingredientes, empaque, comisión).',
      '3) Revisa ganancia por unidad y margen %.',
    ],
    exampleLines: [
      'Precio: B/. 10.00',
      'Costo variable: B/. 6.00',
      'Ganancia por unidad: B/. 4.00',
      'Margen sobre venta: 40%',
      '(Nota: Este margen NO incluye costos fijos)',
    ],
    interpretation: [
      'Si tu margen es bajo, subir ventas no siempre resuelve: podrías estar trabajando mucho para ganar poco.',
      'El margen sirve para alimentar el punto de equilibrio.',
    ],
    commonErrors: [
      'Mezclar costos fijos dentro del costo variable (son cosas distintas).',
      'Confundir “margen” con “markup”.',
      'Olvidar comisiones de delivery/pagos con tarjeta.',
    ],
  ),
  'break_even': const CalculatorInfoConfig(
    topTitle: '¿Qué hace esta calculadora?',
    topBullets: [
      'Te dice cuánto debes vender para cubrir tus costos fijos.',
      'Ideal para definir metas de ventas realistas.',
    ],
    howToSteps: [
      '1) Ingresa tus costos fijos mensuales (puedes traerlos desde Costos Fijos).',
      '2) Ingresa precio y costo variable por unidad (puedes traerlos desde Margen).',
      '3) La app calcula cuántas ventas necesitas para quedar en “0”.',
    ],
    exampleLines: [
      'Costos fijos: B/. 2,000/mes',
      'Precio: B/. 10',
      'Costo variable: B/. 6',
      'Contribución por unidad: B/. 4',
      'Punto de equilibrio: 500 unidades',
      '(Nota: Es una estimación simplificada)',
    ],
    interpretation: [
      'Si tu punto de equilibrio es muy alto, tienes 3 palancas: bajar fijos, subir precio, bajar costo variable.',
    ],
    commonErrors: [
      'Usar ganancia “neta” en vez de contribución (precio - variable).',
      'No revisar si el precio cambia por promociones.',
    ],
  ),

  'decimo': const CalculatorInfoConfig(
    topTitle: '¿Qué hace esta calculadora?',
    topBullets: [
      'Calcula el pago del Décimo Tercer Mes (bruto y neto).',
      'Corresponde a un salario mensual extra dividido en 3 partidas.',
    ],
    howToSteps: [
      '1) Suma los ingresos ordinarios y extra del cuatrimestre.',
      '2) Ingresa ese total en el campo indicado.',
      '3) Calcula para ver el descuento de Seguro Social y el neto a recibir.',
    ],
    exampleLines: [
      'Total Ganado (Ene-Abr): B/. 3,200',
      'Décimo Bruto: B/. 1,066.67',
      'Seguro Social (7.25%): B/. 77.33',
      'A Recibir: B/. 989.34',
    ],
    interpretation: [
      'El Décimo paga 7.25% de Seguro Social pero no paga Impuesto Sobre la Renta (a menos que exceda ciertos límites, casos especiales).',
    ],
    commonErrors: [
      'No incluir horas extras o comisiones en la base de cálculo.',
      'Calcular sobre salario neto en lugar de bruto.',
    ],
  ),
  'itbms': const CalculatorInfoConfig(
    topTitle: '¿Qué hace esta calculadora?',
    topBullets: [
      'Calcula el ITBMS de una venta y el total a cobrar.',
      'Útil para facturación y control de precios.',
    ],
    howToSteps: [
      '1) Ingresa el monto base (antes de impuesto).',
      '2) Selecciona la tasa (por defecto 7% y opciones adicionales si aplica).',
      '3) La app calcula ITBMS y total.',
    ],
    exampleLines: [
      'Base: B/. 100.00',
      'Tasa: 7%',
      'ITBMS: B/. 7.00',
      'Total: B/. 107.00',
    ],
    interpretation: [
      'El ITBMS se suma al precio base.',
      'Si tu producto/servicio tiene tasa distinta o exención, selecciona la opción correcta o valida con DGI.',
    ],
    commonErrors: [
      'Calcular ITBMS sobre el total (cuando ya incluye impuesto) sin usar modo “precio incluye ITBMS”.',
      'Usar 7% cuando aplica otra tasa o exención.',
    ],
    externalLinkLabel: 'Ver referencia oficial (DGI)',
    externalLinkUrl: 'https://dgi.mef.gob.pa/', // Fallback generic URL as specific page not provided
  ),
  'loan_payment': const CalculatorInfoConfig(
    topTitle: '¿Qué hace esta calculadora?',
    topBullets: [
      'Calcula cuota mensual estimada según monto, tasa y plazo.',
      'Útil para planificar flujo de caja antes de endeudarte.',
    ],
    howToSteps: [
      '1) Ingresa monto del préstamo.',
      '2) Ingresa tasa anual (%) y plazo (meses).',
      '3) Revisa cuota, intereses estimados y total a pagar.',
    ],
    exampleLines: [
      'Monto: B/. 5,000',
      'Tasa: 12% anual',
      'Plazo: 24 meses',
      'Cuota estimada: Resultado calculado',
    ],
    interpretation: [
      'La cuota es una estimación. Bancos pueden incluir seguros, comisiones y cargos.',
      'Úsalo para comparar escenarios: más plazo baja cuota pero sube intereses.',
    ],
    commonErrors: [
      'Confundir tasa anual con mensual.',
      'No considerar comisiones/seguros bancarios.',
    ],
  ),
  'liquidacion': const CalculatorInfoConfig(
    topTitle: '¿Qué hace esta calculadora?',
    topBullets: [
      'Estima prestaciones y liquidación laboral según datos ingresados.',
      'Útil para tener una referencia antes de formalizar el cálculo.',
    ],
    howToSteps: [
      '1) Ingresa salario, forma de pago y fechas de inicio/fin.',
      '2) Selecciona el tipo de terminación (renuncia, despido, etc.).',
      '3) Revisa el desglose (vacaciones, prima, indemnización si aplica).',
    ],
    exampleLines: [
      'Salario: B/. 800',
      'Entrada: 01/01/2023',
      'Salida: 31/12/2023',
      'Resultado: Desglose de derechos',
    ],
    interpretation: [
      'El resultado depende estrictamente del tipo de contrato y causal de salida.',
      'Para casos específicos, valida con RRHH/CPA y fuentes oficiales.',
    ],
    commonErrors: [
      'Usar fechas incorrectas o salario no promedio.',
      'Asumir que aplica a todo tipo de contrato (plazo fijo/obra puede cambiar).',
    ],
    externalLinkLabel: 'Ver calculadora oficial MITRADEL',
    externalLinkUrl: 'https://www.mitradel.gob.pa/calculo-de-prestaciones/',
  ),
  'planilla': const CalculatorInfoConfig(
    topTitle: '¿Qué hace esta calculadora?',
    topBullets: [
      'Calcula salario estimado y permite registrar trabajadores.',
      'Útil para controlar pagos de quincena y horas extra.',
    ],
    howToSteps: [
      '1) Crea/selecciona un trabajador guardado (configura si es por hora/mes).',
      '2) Ingresa variables del periodo (horas extra, bonos, descuentos).',
      '3) Calcula para ver el desglose neto y deducciones.',
    ],
    exampleLines: [
      'Trabajador: Juan',
      'Modo: Quincena',
      'Horas extra: 6',
      'Total estimado: Resultado con deducciones de ley',
    ],
    interpretation: [
      '“Último cálculo” muestra el resultado generado para ese trabajador.',
      'Genera un comprobante informativo para tu registro interno.',
    ],
    commonErrors: [
      'Confundir salario mensual con quincenal al ingresar datos.',
      'No separar datos fijos de variables del periodo.',
    ],
  ),
  'human_resources': const CalculatorInfoConfig(
    topTitle: '¿Qué puedes hacer en Recursos Humanos?',
    topBullets: [
      'Calcular planilla y generar comprobantes de pago.',
      'Estimar liquidaciones y guardar expedientes.',
      'Acceder a plantillas de contratos y documentos clave.',
    ],
    howToSteps: [
      '1) Selecciona la herramienta que necesitas (Planilla, Liquidación, etc.).',
      '2) Ingresa los datos del trabajador o selecciona uno guardado.',
      '3) Genera el cálculo, revisa el detalle y expórtalo a PDF o Bóveda.',
    ],
    exampleLines: [
      'Ejemplo: Tienes un nuevo empleado.',
      'Usa "Documentos" para el contrato.',
      'Luego usa "Planilla" cada quincena para sus pagos.',
    ],
    interpretation: [
      'Esta sección te ayuda a mantener el orden administrativo.',
      'Recuerda que los cálculos son informativos y no sustituyen a un contador/abogado.',
    ],
    commonErrors: [
      'No guardar los perfiles de empleados (te ahorra tiempo después).',
      'Confundir salario bruto con salario neto.',
    ],
  ),
  'boveda': const CalculatorInfoConfig(
    topTitle: '¿Qué es tu Bóveda Digital?',
    topBullets: [
      'Un espacio seguro para guardar documentos clave del negocio.',
      'Organiza facturas, contratos y reportes sin usar papel.',
    ],
    howToSteps: [
      '1) Escanea o sube tus archivos (PDF, Imágenes).',
      '2) Organízalos en carpetas automáticas (RRHH, Legal, Finanzas).',
      '3) Accede a ellos rápidamente cuando los necesites.',
    ],
    exampleLines: [
      'Guarda aquí los comprobantes de liquidación.',
      'Respalda el Aviso de Operaciones.',
      'Archiva facturas de proveedores importantes.',
    ],
    interpretation: [
      'Tener todo digitalizado te protege en caso de auditorías o pérdidas físicas.',
      'La Bóveda está sincronizada localmente en tu dispositivo.',
    ],
    commonErrors: [
      'Guardar documentos sin nombre claro (usa fechas y detalles).',
      'No hacer copias de seguridad externas periódicas.',
    ],
  ),
  'auditoria': const CalculatorInfoConfig(
    topTitle: '¿Para qué sirve la Auditoría?',
    topBullets: [
      'Evalúa el estado de salud de tu negocio en áreas clave.',
      'Identifica qué documentos o procesos te faltan.',
    ],
    howToSteps: [
      '1) Revisa la tabla de estado (Rojo = Crítico, Naranja = Pendiente).',
      '2) Usa "Actualizar" para marcar progresos manuales.',
      '3) Consulta las recomendaciones para saber cómo mejorar.',
    ],
    exampleLines: [
      'Marketing: Sin iniciar -> Necesitas crear redes sociales.',
      'Legal: En proceso -> Falta firmar el Aviso de Operaciones.',
      'Contabilidad: Al día -> Todo en orden.',
    ],
    interpretation: [
      'Un negocio saludable tiene la mayoría de indicadores en Verde.',
      'Lo que está en Rojo es tu prioridad para esta semana.',
    ],
    commonErrors: [
      'Ignorar las áreas administrativas por vender más.',
      'Marcar como "Completado" sin tener la evidencia (documentos) en la Bóveda.',
    ],
  ),
  'tramites': const CalculatorInfoConfig(
    topTitle: 'Guía de Trámites y Permisos',
    topBullets: [
      'Descubre qué necesitas para operar legalmente según tu rubro.',
      'Genera una lista de verificación paso a paso.',
    ],
    howToSteps: [
      '1) Selecciona tu categoría (Restaurante, Belleza, etc.).',
      '2) Revisa los requisitos generales y específicos.',
      '3) Usa el botón "Costos Estimados" para preparar tu presupuesto.',
    ],
    exampleLines: [
      'Restaurante: Necesita Permiso Sanitario y Bomberos.',
      'Online: Aviso de Operación "Comercio por Internet".',
    ],
    interpretation: [
      'Operar sin aviso de operación puede acarrear multas.',
      'Los costos son aproximados y varían según el municipio.',
    ],
    commonErrors: [
      'Alquilar un local sin verificar si tiene zonificación comercial.',
      'Iniciar operaciones sin el Aviso de Panamá Emprende.',
    ],
  ),
  'marketing': const CalculatorInfoConfig(
    topTitle: 'Estrategia de Crecimiento Digital',
    topBullets: [
      'Define quién es tu cliente ideal y dónde encontrarlo.',
      'Crea contenido estratégico (Educativo, Entretenimiento, Venta).',
    ],
    howToSteps: [
      '1) Define tu "Avatar" (Edad, Intereses, Dolores).',
      '2) Usa el Generador de Ideas para planear tu semana.',
      '3) Mide qué publicaciones traen más ventas, no solo likes.',
    ],
    exampleLines: [
      'Avatar: "Madres ocupadas que buscan comida saludable rápida".',
      'Contenido: "5 Tips para loncheras en 10 minutos".',
    ],
    interpretation: [
      'La constancia vence a la viralidad esporádica.',
      'Si no sabes a quién le vendes, le vendes a nadie.',
    ],
    commonErrors: [
      'Publicar solo ofertas de venta directa (aburre).',
      'No usar llamados a la acción (CTA) claros.',
    ],
  ),
  'default': const CalculatorInfoConfig(
    topTitle: '¿Qué hace esta herramienta?',
    topBullets: [
      'Calcula indicadores clave para ayudarte a tomar decisiones.',
      'Usa esta herramienta como referencia rápida.',
    ],
    howToSteps: [
      '1) Ingresa los datos solicitados en el formulario.',
      '2) Presiona “Calcular” para ver los resultados.',
      '3) Analiza los indicadores generados.',
    ],
    exampleLines: [
      'Ejemplo simplificado con valores estándar.',
    ],
    interpretation: [
      'Revisa si el resultado requiere acción inmediata en tu negocio.',
    ],
    commonErrors: [
      'Ingresar datos inconpletos o en unidades incorrectas.',
    ],
  ),
  'cash_flow': const CalculatorInfoConfig(
    topTitle: '¿Qué es el Flujo de Caja?',
    topBullets: [
      'Diferencia entre dinero que entra (venta cobrada) y dinero que sale.',
      'Crucial para saber si puedes pagar las cuentas HOY.',
    ],
    howToSteps: [
      '1) Ingresa tus Entradas Reales (Ventas en efectivo + Cobros).',
      '2) Resta tus Salidas (Gastos fijos + Variables).',
      '3) El resultado es tu disponibilidad inmediata.',
    ],
    exampleLines: [
      'Entradas: B/. 1,000',
      'Salidas: B/. 800',
      'Flujo neto: + B/. 200 (Tienes liquidez)',
    ],
    interpretation: [
      'Positivo: Tienes oxígeno.',
      'Negativo: Peligro, estás gastando más de lo que cobras (aunque vendas mucho a crédito).',
    ],
    commonErrors: [
      'Confundir ventas a crédito con dinero en mano.',
      'No incluir gastos pequeños diarios.',
    ],
  ),
  'break_even_acc': const CalculatorInfoConfig(
    topTitle: 'Punto de Equilibrio (Meta)',
    topBullets: [
      'Calcula cuánto tienes que vender obligatoriamente para no perder.',
      'Tu "Número de la Paz".',
    ],
    howToSteps: [
      '1) Ingresa tus Costos Fijos totales.',
      '2) Define el Precio y Costo Variable de tu producto estrella.',
      '3) Obtén la cantidad de unidades/servicios meta.',
    ],
    exampleLines: [
      'Fijos: B/. 1,500',
      'Margen por unidad: B/. 5',
      'Meta: 300 unidades al mes.',
    ],
    interpretation: [
      'Si la meta es inalcanzable, debes bajar costos fijos o subir margen.',
    ],
    commonErrors: [
      'Ser demasiado optimista con las ventas estimadas.',
    ],
  ),
  'tax_estimator': const CalculatorInfoConfig(
    topTitle: 'Estimador Fiscal Panamá',
    topBullets: [
      'Previsión de ITBMS y Renta para no gastarte el dinero del Estado.',
      'Calcula tu "Alcancía Fiscal".',
    ],
    howToSteps: [
      '1) Elige si eres Persona Natural o Jurídica.',
      '2) Ingresa tu facturación mensual.',
      '3) Separa el monto sugerido cada semana.',
    ],
    exampleLines: [
      'Venta: B/. 2,000',
      'ITBMS (7%): B/. 140',
      'ISR Est.: B/. 50',
      'Ahorrar: B/. 190 total.',
    ],
    interpretation: [
      'El ITBMS no es tuyo. Si lo gastas, tendrás problemas de liquidez al pagar a la DGI.',
    ],
    commonErrors: [
      'Pensar que todo el ingreso en el banco es disponible para gastar.',
    ],
  ),
  'budget': const CalculatorInfoConfig(
    topTitle: 'Regla 50/30/20',
    topBullets: [
      'Método clásico para distribuir tus finanzas personales o del negocio.',
      'Balance entre obligación y crecimiento.',
    ],
    howToSteps: [
      '1) Ingresa tu ingreso neto total.',
      '2) Ingresa tus gastos reales en Necesidades, Deseos y Ahorro.',
      '3) Compara tu realidad vs el ideal.',
    ],
    exampleLines: [
      'Ingreso: 1,000',
      'Necesidades (50%): 500',
      'Deseos (30%): 300',
      'Ahorro (20%): 200',
    ],
    interpretation: [
      'Si "Necesidades" supera el 50%, tu negocio está frágil ante crisis.',
    ],
    commonErrors: [
      'Clasificar gustos como necesidades.',
    ],
  ),
};

// --- WIDGET ---
class CalculatorInfoPanel extends StatefulWidget {
  final String configId;

  const CalculatorInfoPanel({Key? key, required this.configId}) : super(key: key);

  @override
  State<CalculatorInfoPanel> createState() => _CalculatorInfoPanelState();
}

class _CalculatorInfoPanelState extends State<CalculatorInfoPanel> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final config = calculatorConfigs[widget.configId];
    if (config == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // A) TOP CARD
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF151C2B).withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      config.topTitle,
                      style: GoogleFonts.outfit(color: const Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _isExpanded = !_isExpanded),
                    style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0,0), tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Ver cómo usar', style: GoogleFonts.outfit(color: Colors.blueAccent, fontSize: 12, fontWeight: FontWeight.w600)),
                        Icon(_isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, size: 16, color: Colors.blueAccent),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...config.topBullets.map((b) => Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(color: Colors.white54, fontSize: 12)),
                    Expanded(child: Text(b, style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13, height: 1.2))),
                  ],
                ),
              )).toList(),
            ],
          ),
        ),

        // B) HOW TO CARD (ACCORDION)
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 300),
          firstChild: const SizedBox.shrink(),
          secondChild: _buildExpandedContent(config),
          crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
        ),
      ],
    );
  }

  Widget _buildExpandedContent(CalculatorInfoConfig config) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1520),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blueAccent.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection('Cómo se usa (3 pasos)', config.howToSteps, Colors.white),
          const SizedBox(height: 16),
          _buildSection('Ejemplo rápido', config.exampleLines, const Color(0xFFD4AF37)),
          const SizedBox(height: 16),
          _buildSection('Cómo interpretar', config.interpretation, Colors.tealAccent),
          const SizedBox(height: 16),
          _buildSection('Errores comunes', config.commonErrors, Colors.redAccent),
          if (config.externalLinkLabel != null && config.externalLinkUrl != null) ...[
             const SizedBox(height: 16),
             InkWell(
               onTap: () {
                 // Simple launch url logic or notify user since I can't import url_launcher easily without checking pubspec
                 // But wait, url_launcher IS in pubspec (seen in logs). 
                 // I will use a simple print or ensure I import url_launcher.
                 // Actually prompt says "abre navegador". I should check imports. 
                 // For now I'll assume url_launcher is available or use a callback? 
                 // To allow plug-and-play without adding imports here, I might just print.
                 // BUT strict requirement is "abre navegador".
                 // I will add 'import 'package:url_launcher/url_launcher.dart';' to top of file.
                 _launchUrl(config.externalLinkUrl!); 
               },
               child: Container(
                 padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                 decoration: BoxDecoration(
                   color: Colors.blueAccent.withOpacity(0.1),
                   borderRadius: BorderRadius.circular(8),
                   border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
                 ),
                 child: Row(
                   mainAxisSize: MainAxisSize.min,
                   children: [
                     const Icon(Icons.open_in_new, size: 16, color: Colors.blueAccent),
                     const SizedBox(width: 8),
                     Text(config.externalLinkLabel!, style: GoogleFonts.outfit(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 13)),
                   ],
                 ),
               ),
             ),
          ],
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 14, color: Colors.white38),
                const SizedBox(width: 8),
                Expanded(child: Text('Herramienta informativa. No reemplaza asesoría profesional.', style: GoogleFonts.outfit(color: Colors.white38, fontSize: 11, fontStyle: FontStyle.italic))),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<String> items, Color titleColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.outfit(color: titleColor, fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 6),
        ...items.map((i) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(i.startsWith('(') ? '' : '• ', style: GoogleFonts.outfit(color: Colors.white38, fontSize: 12)),
              Expanded(child: Text(i, style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13, height: 1.3))),
            ],
          ),
        )).toList(),
      ],
    );
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      debugPrint('Could not launch $uri');
    }
  }
}
