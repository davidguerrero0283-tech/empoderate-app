import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../ui/theme/empoderate_theme.dart';
import '../../../components/premium_scaffold.dart';
import '../models/guide_question_model.dart';
import '../data/guide_master_questions.dart';
import '../logic/guide_master_scoring.dart';

class GuideMasterScreen extends StatefulWidget {
  const GuideMasterScreen({super.key});

  @override
  State<GuideMasterScreen> createState() => _GuideMasterScreenState();
}

class _GuideMasterScreenState extends State<GuideMasterScreen> {
  // State
  int _step = 0; // 0: Intro/Disclaimer, 1: Wizard, 2: Results
  bool _disclaimerAccepted = false;
  int _selectedLevel = 25; // 25, 50, 70
  
  // Wizard State
  List<GuideQuestion> _activeQuestions = [];
  int _currentIndex = 0;
  Map<int, dynamic> _answers = {}; // qId -> value
  
  // Results
  GuideScoringResult? _result;

  @override
  void initState() {
    super.initState();
    _checkDisclaimer();
  }

  Future<void> _checkDisclaimer() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _disclaimerAccepted = prefs.getBool('guide_master_disclaimer_accepted') ?? false;
      // If accepted, maybe we could restore progress? For now, just load state.
    });
  }

  // Intro State
  int _introTabIndex = 0;

  Future<void> _startWizard() async {
    if (!_disclaimerAccepted) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Debes aceptar el aviso legal para continuar.')));
       return;
    }
    
    try {
      // Save disclaimer acceptance
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('guide_master_disclaimer_accepted', true);
      await prefs.setString('guide_master_disclaimer_accepted_at', DateTime.now().toIso8601String());

      final questions = getQuestionsForLevel(_selectedLevel);
      if (questions.isEmpty) {
        throw Exception("No se pudieron cargar las preguntas para el nivel seleccionado.");
      }

      setState(() {
        _activeQuestions = questions;
        _currentIndex = 0;
        _answers.clear();
        _activeQuestions.shuffle();
        _step = 1;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error al iniciar el test: $e'),
        backgroundColor: Colors.red,
      ));
    }
  }

  // --- STEP 0: INTRO ---
  Widget _buildIntroScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildNeonHeader('GUÍA DE NEGOCIOS 2026'),
          const SizedBox(height: 24),
          
          // --- INFO TABS ---
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    _buildTabBtn(0, 'Ventajas', Icons.thumb_up),
                    _buildTabBtn(1, 'Checklist', Icons.checklist),
                    _buildTabBtn(2, 'Matriz', Icons.grid_view),
                  ],
                ),
                Container(height: 1, color: Colors.white10),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _buildIntroTabContent(),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 40),
          const Divider(color: Colors.white12),
          const SizedBox(height: 20),

          Text(
            'CONFIGURA TU DIAGNÓSTICO',
            style: GoogleFonts.outfit(color: EmpoderateTheme.gold, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1),
          ),
          const SizedBox(height: 16),
          
          _buildLevelOption(25, 'RÁPIDO (Esencial)', 'Test ágil de 5 mins. Cubre los 10 atributos clave para una recomendación sólida.'),
          _buildLevelOption(50, 'INTERMEDIO (Precisión)', 'Añade preguntas de desempate y estilo de vida. Ideal si tienes dudas específicas.'),
          _buildLevelOption(70, 'AVANZADO (Completo)', 'El análisis más profundo. Audita tu perfil psicológico, financiero y operativo al 100%.'),

          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Colors.amber),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'AVISO IMPORTANTE',
                        style: GoogleFonts.outfit(color: Colors.amber, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Esta guía ofrece una recomendación orientativa basada en tus respuestas. No constituye asesoría legal, contable ni financiera. Los resultados pueden variar según tu ubicación y presupuesto. Para decisiones finales, valida con fuentes oficiales.',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Checkbox(
                      value: _disclaimerAccepted,
                      activeColor: EmpoderateTheme.goldStrong,
                      onChanged: (val) => setState(() => _disclaimerAccepted = val ?? false),
                    ),
                    const Expanded(
                      child: Text(
                        'Entiendo y acepto que es una guía orientativa.',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _disclaimerAccepted ? EmpoderateTheme.goldStrong : Colors.grey.withOpacity(0.3),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _disclaimerAccepted ? _startWizard : null,
              child: const Text('COMENZAR TEST', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTabBtn(int index, String label, IconData icon) {
    bool isActive = _introTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _introTabIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: isActive ? EmpoderateTheme.goldStrong : Colors.transparent, width: 2)),
          ),
          child: Column(
            children: [
              Icon(icon, color: isActive ? EmpoderateTheme.goldStrong : Colors.white54, size: 20),
              const SizedBox(height: 4),
              Text(label, style: TextStyle(color: isActive ? Colors.white : Colors.white54, fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIntroTabContent() {
    if (_introTabIndex == 0) {
      return Column(
        key: const ValueKey('tab0'),
        children: [
          _buildInfoCard('Comida/Restaurantes', 'Alta demanda diaria, flujo de efectivo constante.', 'Alta competencia, perecederos (merma), horarios esclavizantes.', Icons.restaurant),
          const SizedBox(height: 12),
          _buildInfoCard('Tienda/Comercio', 'Fácil de escalar, menos dependencia de tu tiempo directo.', 'Inventario estancado, márgenes bajos si revendes.', Icons.store),
          const SizedBox(height: 12),
          _buildInfoCard('Servicios/Digital', 'Baja inversión inicial, altos márgenes, trabajo remoto.', 'Venta intangible más difícil, alta competencia global.', Icons.laptop_mac),
          const SizedBox(height: 12),
          _buildInfoCard('Belleza/Eventos', 'Clientes fieles, propinas/extras, satisfacción creativa.', 'Físicamente agotador, lidiar con clientes difíciles.', Icons.brush),
        ],
      );
    } 
    if (_introTabIndex == 1) {
      return Column(
        key: const ValueKey('tab1'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('10 DECISIONES CLAVE', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          ...[
            '¿Qué problema resuelves realmente?',
            '¿Quién es tu cliente ideal (Avatar)?',
            '¿Cuánto capital tienes vs. necesitas?',
            '¿Producto físico o Servicio intangible?',
            '¿Local físico, Digital o Híbrido?',
            '¿Solo o con socios?',
            '¿Nombre y marca disponible?',
            '¿Permisos legales requeridos?',
            '¿Estrategia de precios (Barato vs Premium)?',
            '¿Plan de salida si falla?',
          ].map((t) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(children: [Icon(Icons.check_box_outline_blank, color: EmpoderateTheme.gold, size: 16), SizedBox(width: 8), Expanded(child: Text(t, style: TextStyle(color: Colors.white70, fontSize: 13)))]),
          )),
        ],
      );
    }
    // Matrix
    return Column(
      key: const ValueKey('tab2'),
      children: [
        Text('MATRIZ: INVERSIÓN VS COMPLEJIDAD', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 16),
        Container(
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white24),
            borderRadius: BorderRadius.circular(8),
            gradient: LinearGradient(
              colors: [Colors.blue.withOpacity(0.1), Colors.red.withOpacity(0.1)],
              begin: Alignment.bottomLeft,
              end: Alignment.topRight
            )
          ),
          child: Stack(
            children: [
              // Axis Labels
              Positioned(bottom: 8, right: 8, child: Text("Alta Inversión", style: TextStyle(color: Colors.white30, fontSize: 10))),
              Positioned(top: 8, left: 8, child: Text("Alta Complejidad", style: TextStyle(color: Colors.white30, fontSize: 10))),
              
              // Quadrants
              Positioned(top: 30, right: 30, child: _buildMatrixLabel("Bienes Raíces\nFranquicias", Colors.redAccent)),
              Positioned(bottom: 30, left: 30, child: _buildMatrixLabel("Freelance\nDigital", Colors.greenAccent)),
              Positioned(top: 30, left: 30, child: _buildMatrixLabel("Restaurante\nFábrica", Colors.orangeAccent)),
              Positioned(bottom: 30, right: 30, child: _buildMatrixLabel("Dropshipping\nRevenda", Colors.blueAccent)),
              
              Center(child: Container(width: 1, height: 180, color: Colors.white10)),
              Center(child: Container(height: 1, width: 280, color: Colors.white10)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text('Eje X: Inversión  |  Eje Y: Complejidad Operativa', style: TextStyle(color: Colors.white38, fontSize: 11)),
      ],
    );
  }

  Widget _buildInfoCard(String title, String pro, String con, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(8)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: EmpoderateTheme.gold, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text('✅ $pro', style: const TextStyle(color: Colors.greenAccent, fontSize: 12)),
                const SizedBox(height: 2),
                Text('⚠️ $con', style: const TextStyle(color: Colors.orangeAccent, fontSize: 12)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMatrixLabel(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(4), border: Border.all(color: color.withOpacity(0.5))),
      child: Text(text, textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  void _submitAnswer(dynamic value) {
    if (_activeQuestions.isEmpty) return;
    
    final q = _activeQuestions[_currentIndex];
    setState(() {
      _answers[q.id] = value;
      
      if (_currentIndex < _activeQuestions.length - 1) {
        _currentIndex++;
      } else {
        _calculateAndShowResults();
      }
    });
  }
  
  void _calculateAndShowResults() {
    var results = GuideMasterScoring.calculate(_answers);
    setState(() {
      _result = results;
      _step = 2;
    });
  }
  
  void _resetWizard() {
    setState(() {
      _step = 0;
      _result = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      title: 'GUÍA MAESTRA PRO',
      isNeonTitle: true,
      showBackButton: true,
      useScroll: false, // Critical: We handle scroll internally per step (Wizard needs fixed height for Spacer)
      usePadding: false, // We handle padding internally
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_step == 0) return _buildIntroScreen();
    if (_step == 1) return _buildWizardScreen();
    if (_step == 2) return _buildResultsScreen();
    return const SizedBox.shrink();
  }


  
  Widget _buildLevelOption(int level, String title, String desc) {
    bool isSelected = _selectedLevel == level;
    return GestureDetector(
      onTap: () => setState(() => _selectedLevel = level),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? EmpoderateTheme.goldStrong.withOpacity(0.15) : Colors.white.withOpacity(0.05),
          border: Border.all(
            color: isSelected ? EmpoderateTheme.goldStrong : Colors.white10,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Radio(
              value: level, 
              groupValue: _selectedLevel, 
              activeColor: EmpoderateTheme.goldStrong,
              onChanged: (val) => setState(() => _selectedLevel = val as int),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(
                    color: isSelected ? EmpoderateTheme.goldStrong : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16
                  )),
                  const SizedBox(height: 4),
                  Text(desc, style: TextStyle(color: Colors.white60, fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- STEP 1: WIZARD ---
  Widget _buildWizardScreen() {
    if (_activeQuestions.isEmpty) return const Center(child: CircularProgressIndicator());
    final q = _activeQuestions[_currentIndex];
    double progress = (_currentIndex + 1) / _activeQuestions.length;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          LinearProgressIndicator(
            value: progress, 
            backgroundColor: Colors.white10, 
            color: EmpoderateTheme.goldStrong,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 12),
          Text(
            'Pregunta ${_currentIndex + 1} de ${_activeQuestions.length}',
            style: TextStyle(color: Colors.white54, fontSize: 13),
          ),
          
          const Spacer(),
          
          // Question Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: EmpoderateTheme.safeBoxDecoration(
              color: const Color(0xFF1A1F2C),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  q.text,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 32),
                
                if (q.type == GuideQuestionType.single)
                  ...q.options!.asMap().entries.map((entry) => 
                    _buildOptionButton(entry.key, entry.value)
                  ),
                  
                if (q.type == GuideQuestionType.scale)
                  _buildScaleSelector(),
              ],
            ),
          ),
          
          const Spacer(flex: 2),
        ],
      ),
    );
  }

  Widget _buildOptionButton(int index, String text) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: const BorderSide(color: Colors.white24),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          alignment: Alignment.centerLeft,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: () => _submitAnswer(index),
        child: Text(text, style: const TextStyle(fontSize: 16)),
      ),
    );
  }

  Widget _buildScaleSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(5, (i) {
        int val = i + 1;
        return GestureDetector(
          onTap: () => _submitAnswer(val),
          child: Container(
            width: 50,
            height: 50,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: EmpoderateTheme.goldStrong.withOpacity(0.5)),
            ),
            child: Text(
              '$val',
              style: GoogleFonts.outfit(
                color: EmpoderateTheme.goldStrong,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }),
    );
  }

  // --- STEP 2: RESULTS ---
  Widget _buildResultsScreen() {
    if (_result == null) return const SizedBox.shrink();

    // Get Recommendations
    final principalConcrete = GuideMasterScoring.getConcreteRubros(_result!.principal);
    final alt1Concrete = GuideMasterScoring.getConcreteRubros(_result!.alternates[0]);
    final alt2Concrete = GuideMasterScoring.getConcreteRubros(_result!.alternates.length > 1 ? _result!.alternates[1] : 'Unknown');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildNeonHeader('TU DIAGNÓSTICO PROFESIONAL'),
          const SizedBox(height: 24),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [EmpoderateTheme.goldStrong.withOpacity(0.2), const Color(0xFF0F1520)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: EmpoderateTheme.goldStrong.withOpacity(0.5)),
              boxShadow: [
                BoxShadow(color: EmpoderateTheme.goldStrong.withOpacity(0.1), blurRadius: 20)
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.emoji_objects, color: EmpoderateTheme.goldStrong, size: 28),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text('TU PERFIL INDICA:', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _result!.principal.toUpperCase(),
                  style: GoogleFonts.outfit(
                    color: Colors.white, 
                    fontWeight: FontWeight.w900, 
                    fontSize: 32,
                    letterSpacing: 1.5,
                     shadows: [
                       Shadow(color: EmpoderateTheme.goldStrong, blurRadius: 10),
                     ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Text(
                    'Nivel de Confianza: ${_result!.confidence.toUpperCase()}',
                    style: TextStyle(
                      color: _result!.confidence == 'Alta' ? Colors.greenAccent : Colors.amberAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 12
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // REASONING
                ..._result!.reasoning.map((r) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       const Icon(Icons.check_circle, color: Colors.greenAccent, size: 16),
                       const SizedBox(width: 8),
                       Expanded(child: Text(r, style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13))),
                    ],
                  ),
                )),
                
                const SizedBox(height: 24),
                
                // CONCRETE RECOMMENDATIONS
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('NEGOCIOS RECOMENDADOS (Principal):', style: TextStyle(color: EmpoderateTheme.gold, fontWeight: FontWeight.bold, fontSize: 12)),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: principalConcrete.values.take(3).map((name) => Chip(
                          label: Text(name),
                          backgroundColor: EmpoderateTheme.goldStrong.withOpacity(0.2),
                          labelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                          side: BorderSide(color: EmpoderateTheme.goldStrong.withOpacity(0.5)),
                        )).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          const Divider(color: Colors.white12),
          const SizedBox(height: 12),
          Text('Alternativas recomendadas:', style: TextStyle(color: Colors.white54, fontSize: 12)),
          const SizedBox(height: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAlternateRow(_result!.alternates[0], alt1Concrete.values.isNotEmpty ? alt1Concrete.values.first : ''),
              if (_result!.alternates.length > 1) ...[
                 const SizedBox(height: 8),
                 _buildAlternateRow(_result!.alternates[1], alt2Concrete.values.isNotEmpty ? alt2Concrete.values.first : ''),
              ]
            ],
          ),
          
          const SizedBox(height: 24),
          if (_result!.risks.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Icon(Icons.warning, color: Colors.redAccent, size: 20),
                    SizedBox(width: 8),
                    Text('RIESGOS IDENTIFICADOS', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold))
                  ]),
                  const SizedBox(height: 12),
                  ..._result!.risks.map((r) => Text('• $r', style: TextStyle(color: Colors.white70, height: 1.4))),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
          
          const SizedBox(height: 16),
          // DISCLAIMER MINI
          const Text(
            'Nota: Esta recomendación es orientativa. Tú decides el camino final.',
            style: TextStyle(color: Colors.white38, fontSize: 11, fontStyle: FontStyle.italic),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: EmpoderateTheme.goldStrong,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 18),
                elevation: 10,
                shadowColor: EmpoderateTheme.goldStrong.withOpacity(0.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                context.go('/mi_negocio_rubro');
              },
              child: const Text('ESCOJER RUBRO, TRÁMITES Y REQUISITOS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 0.5)),
            ),
          ),
          
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: _resetWizard,
              child: Text('Repetir Test', style: TextStyle(color: Colors.white54)),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
  
  Widget _buildAlternateRow(String category, String example) {
     return Row(
       children: [
         Container(
           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
           decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(4)),
           child: Text(category, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 12)),
         ),
         const SizedBox(width: 8),
         Expanded(child: Text('Ej: $example', style: const TextStyle(color: Colors.white54, fontSize: 12, fontStyle: FontStyle.italic))),
       ],
     );
  }

  Widget _buildNeonHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: GoogleFonts.outfit(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 20,
        shadows: [Shadow(color: EmpoderateTheme.goldStrong, blurRadius: 10)]
      ),
    );
  }
}
