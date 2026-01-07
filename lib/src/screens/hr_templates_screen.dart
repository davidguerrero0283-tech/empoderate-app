import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../components/premium_scaffold.dart';
import '../components/neon_widgets.dart';
import '../calculators/salario_models.dart';
import '../utils/carta_generator.dart';
import 'calculators/carta_preview_screen.dart';
import '../calculators/liquidacion_models.dart';
import 'package:proyecto_empoderate/src/widgets/feature_intro_screen.dart';
import '../services/worker_service.dart';

class HrTemplatesScreen extends StatefulWidget {
  final String? initialTemplateType;
  final WorkerProfile? worker;
  final String? workerId; // NEW: For deep link support

  const HrTemplatesScreen({
    Key? key,
    this.initialTemplateType,
    this.worker,
    this.workerId,
  }) : super(key: key);

  @override
  State<HrTemplatesScreen> createState() => _HrTemplatesScreenState();
}

class _HrTemplatesScreenState extends State<HrTemplatesScreen> {
  bool _showIntro = true;
  WorkerProfile? _loadedWorker; // NEW: Loaded worker from ID
  bool _isLoadingWorker = false;

  @override
  void initState() {
    super.initState();
    _loadedWorker = widget.worker;
    if (_loadedWorker == null && widget.workerId != null && widget.workerId!.isNotEmpty) {
      _loadWorkerById(widget.workerId!);
    }
  }
  
  /// NEW: Load worker by ID for deep link support
  Future<void> _loadWorkerById(String workerId) async {
    setState(() => _isLoadingWorker = true);
    try {
      final worker = await WorkerService().getWorkerById(workerId);
      if (worker != null && mounted) {
        setState(() => _loadedWorker = worker);
      }
    } finally {
      if (mounted) setState(() => _isLoadingWorker = false);
    }
  }
  
  // Helper to get current worker (from props or loaded)
  WorkerProfile? get _currentWorker => _loadedWorker ?? widget.worker;

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      title: 'Plantillas de Documentos',
      subtitle: 'Modelos base para tu gestión de personal.',
      showBackButton: true,
      useScroll: false,
      usePadding: false,
      body: Stack(
        children: [
          // MAIN CONTENT - wrapped in Positioned.fill
          Positioned.fill(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Contexto de Trabajador (si existe)
                  if (_currentWorker != null) _buildSelectedWorkerHeader(),
      
                  const SizedBox(height: 12),
      
                  // 2. Secciones de Plantillas
                  _buildTemplateSection(
                    title: 'Contratación Estratégica',
                    icon: Icons.assignment_ind_outlined,
                    color: const Color(0xFF00E5FF),
                    templates: [
                      _TemplateData(
                        title: 'Contrato de Trabajo Individual',
                        description: 'Modelo estándar para Panamá (Art. 59 CT). Incluye cláusulas de jornada, salario y obligaciones.',
                        icon: Icons.description_outlined,
                        type: 'Contrato',
                        points: [
                          'Jornada laboral detallada',
                          'Desglose de remuneración',
                          'Cláusula de confidencialidad',
                          'Periodo de prueba'
                        ],
                      ),
                    ],
                  ),
      
                  const SizedBox(height: 24),
      
                  _buildTemplateSection(
                    title: 'Gestión y Constancias',
                    icon: Icons.history_edu_outlined,
                    color: const Color(0xFFFF4081),
                    templates: [
                      _TemplateData(
                        title: 'Carta de Trabajo (Constancia)',
                        description: 'Certificación oficial de tiempo de servicio y cargo. Ideal para trámites bancarios o personales.',
                        icon: Icons.verified_user_outlined,
                        type: 'Carta',
                        points: [
                          'Fecha de ingreso oficial',
                          'Cargo actual o último',
                          'Firma de gerencia',
                          'Hoja membretada simulada'
                        ],
                      ),
                    ],
                  ),
      
                  const SizedBox(height: 24),
      
                  _buildTemplateSection(
                    title: 'Disciplina y Normatividad',
                    icon: Icons.gavel_outlined,
                    color: const Color(0xFFFFAB40),
                    templates: [
                      _TemplateData(
                        title: 'Amonestación Escrita',
                        description: 'Documento formal para registrar incumplimientos. Base para expedientes disciplinarios.',
                        icon: Icons.warning_amber_rounded,
                        type: 'Amonestación',
                        points: [
                          'Descripción de la falta',
                          'Referencia al código laboral',
                          'Espacio para descargos',
                          'Acuse de recibo'
                        ],
                      ),
                    ],
                  ),
      
                  const SizedBox(height: 40),
      
                  // Info Legal
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.security, color: Colors.blueAccent, size: 32),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Aviso de Cumplimiento Legal',
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Estas plantillas son guías de referencia basadas en el Código de Trabajo de Panamá. Le recomendamos validar documentos críticos con un asesor legal especializado.',
                                style: GoogleFonts.outfit(color: Colors.white54, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
          
          // --- INTRO OVERLAY ---
          if (_showIntro)
            Positioned.fill(
              child: FeatureIntroScreen(
                key: const ValueKey('IntroOverlay'),
                title: 'GESTIÓN RRHH',
                subTitle: 'Genera contratos, amonestaciones y cartas de trabajo en segundos con base legal.',
                heroEmoji: '📝',
                primaryColor: const Color(0xFFFF4081), // Pinkish
                features: const [
                  IntroFeatureItem(Icons.history_edu, 'Contratos'),
                  IntroFeatureItem(Icons.warning_amber, 'Disciplina'),
                  IntroFeatureItem(Icons.verified, 'Constancias'),
                ],
                processSteps: const [
                  IntroStepItem('1. Elige', 'Selecciona el documento.'),
                  IntroStepItem('2. Personaliza', 'Ajusta los detalles.'),
                  IntroStepItem('3. Genera', 'Obtén tu documento listo.'),
                ],
                proTip: 'Un buen contrato evita el 90% de los conflictos laborales.',
                onDismiss: () => setState(() => _showIntro = false),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSelectedWorkerHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF00E5FF).withOpacity(0.2), Colors.black],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00E5FF).withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFF00E5FF),
            radius: 25,
            child: Text(
              _currentWorker!.name.substring(0, 1).toUpperCase(),
              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Colaborador Seleccionado',
                  style: GoogleFonts.outfit(color: const Color(0xFF00E5FF), fontSize: 12, fontWeight: FontWeight.bold),
                ),
                Text(
                  _currentWorker!.name,
                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  _currentWorker!.position,
                  style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white54),
            onPressed: () => Navigator.pop(context),
            tooltip: 'Cambiar colaborador',
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<_TemplateData> templates,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              title.toUpperCase(),
              style: GoogleFonts.outfit(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...templates.map((t) => _buildTemplateCard(t, color)).toList(),
      ],
    );
  }

  Widget _buildTemplateCard(_TemplateData template, Color sectionColor) {
    final bool isHighlighted = widget.initialTemplateType == template.type;
    final Color accentColor = isHighlighted ? const Color(0xFF00E5FF) : sectionColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF151921),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isHighlighted ? accentColor : Colors.white10,
          width: isHighlighted ? 2 : 1,
        ),
        boxShadow: isHighlighted ? [
          BoxShadow(
            color: accentColor.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ] : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header del Card
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(template.icon, color: accentColor, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        template.title,
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isHighlighted)
                        Text(
                          'DOCUMENTO PREPARADO',
                          style: GoogleFonts.outfit(
                            color: accentColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Descripción
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              template.description,
              style: GoogleFonts.outfit(color: Colors.white60, fontSize: 13),
            ),
          ),

          const SizedBox(height: 16),

          // Puntos clave
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Wrap(
              spacing: 12,
              runSpacing: 8,
              children: template.points.map((p) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_outline, color: accentColor, size: 14),
                  const SizedBox(width: 6),
                  Text(p, style: GoogleFonts.outfit(color: Colors.white70, fontSize: 11)),
                ],
              )).toList(),
            ),
          ),

          const SizedBox(height: 20),

          // Acciones
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (_currentWorker != null) {
                        _generateDocument(template.type, _currentWorker!);
                      } else {
                        _showWorkerSelectionDialog(context, template.type);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [accentColor, accentColor.withOpacity(0.7)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.auto_awesome, color: isHighlighted ? Colors.black : Colors.white, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              _currentWorker != null ? 'GENERAR AHORA' : 'PERSONALIZAR',
                              style: GoogleFonts.outfit(
                                color: isHighlighted ? Colors.black : Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () => _mockVaultAction(context, template.title),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: const Icon(Icons.bookmark_border, color: Colors.white70),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _generateDocument(String type, WorkerProfile worker) {
    String content = '';
    String title = '';
    
    switch (type) {
      case 'Contrato':
        content = CartaGenerator.generateContract(worker);
        title = 'VISTA PREVIA DE CONTRATO';
        break;
      case 'Carta':
        content = _generateConstancia(worker);
        title = 'CARTA DE TRABAJO';
        break;
      case 'Amonestación':
        content = CartaGenerator.generateWarning(worker);
        title = 'AMONESTACIÓN ESCRITA';
        break;
    }

    final dummyInput = LiquidacionInputModel(
      startDate: DateTime.now(),
      endDate: DateTime.now(),
    );
    final dummyResult = LiquidacionResultModel(
      salarioAdeudado: 0,
      vacacionesVencidas: 0,
      vacacionesProporcionales: 0,
      decimoProporcional: 0,
      primaAntiguedad: 0,
      indemnizacion: 0,
      preaviso: 0,
      subtotalDevengos: 0,
      css: 0,
      se: 0,
      isr: 0,
      totalDeducciones: 0,
      totalPagar: 0,
      yearsWorked: 0,
      monthsWorked: 0,
      daysWorked: 0,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CartaPreviewScreen(
          input: dummyInput, 
          result: dummyResult,
          customContent: content,
          customTitle: title,
          isCarta: true,
        ),
      ),
    );
  }

  String _generateConstancia(WorkerProfile w) {
    final fmt = DateTime.now();
    String startDateStr = w.startDate != null 
        ? '${w.startDate!.day}/${w.startDate!.month}/${w.startDate!.year}' 
        : '__________';

    return """
CIUDAD DE PANAMÁ, ${fmt.day} DE ${fmt.month} DE ${fmt.year}

A QUIEN CORRESPONDA:

POR MEDIO DE LA PRESENTE, HACEMOS CONSTAR QUE EL (LA) SR(A). ${w.name.toUpperCase()} LABORÓ (LABORA) EN NUESTRA EMPRESA DESDE EL DÍA $startDateStr.

DURANTE ESTE TIEMPO HA DESEMPEÑADO LAS SIGUIENTES FUNCIONES: ${w.position.toUpperCase()}.

SE EXTIENDE LA PRESENTE A SOLICITUD DE LA PARTE INTERESADA.


ATENTAMENTE,

LA GERENCIA
""";
  }

  void _showWorkerSelectionDialog(BuildContext context, String type) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Por favor, selecciona un colaborador desde el Directorio de Empleados'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _mockVaultAction(BuildContext context, String title) async {
     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Guardando plantilla en Bóveda...')));
    await Future.delayed(const Duration(seconds: 1));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Guardado correctamente ✅')));
  }
}

class _TemplateData {
  final String title;
  final String description;
  final IconData icon;
  final String type;
  final List<String> points;

  _TemplateData({
    required this.title,
    required this.description,
    required this.icon,
    required this.type,
    required this.points,
  });
}
