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

  Future<void> _startWizard() async {
    if (!_disclaimerAccepted) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Debes aceptar el aviso legal para continuar.')));
       return;
    }
    
    // Save disclaimer acceptance
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('guide_master_disclaimer_accepted', true);
    await prefs.setString('guide_master_disclaimer_accepted_at', DateTime.now().toIso8601String());

    setState(() {
      _activeQuestions = getQuestionsForLevel(_selectedLevel);
      _currentIndex = 0;
      _answers.clear();
      _activeQuestions.shuffle(); // Optional: shuffle if order doesn't matter, but prompt said "curated set". Let's keep order.
      // Actually prompt implies specific order might be good, but our getQuestions returns a list.
      // We'll keep the list order from the getter.
      _step = 1;
    });
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

  // --- STEP 0: INTRO ---
  Widget _buildIntroScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildNeonHeader('Elige tu nivel de profundidad'),
          const SizedBox(height: 20),
          
          _buildLevelOption(25, 'RÁPIDO (Esencial)', 'Test ágil de 5 mins. Cubre los 10 atributos clave para una recomendación sólida.'),
          _buildLevelOption(50, 'INTERMEDIO (Precisión)', 'Añade preguntas de desempate y estilo de vida. Ideal si tienes dudas específicas.'),
          _buildLevelOption(70, 'AVANZADO (Completo)', 'El análisis más profundo. Audita tu perfil psicológico, financiero y operativo al 100%.'),

          const SizedBox(height: 32),
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
