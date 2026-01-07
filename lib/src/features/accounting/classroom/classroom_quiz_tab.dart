import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:proyecto_empoderate/src/components/neon_widgets.dart';

class ClassroomQuizTab extends StatefulWidget {
  const ClassroomQuizTab({Key? key}) : super(key: key);

  @override
  State<ClassroomQuizTab> createState() => _ClassroomQuizTabState();
}

class _ClassroomQuizTabState extends State<ClassroomQuizTab> {
  // --- STATE ---
  List<Map<String, dynamic>> _questions = [];
  int _currentIndex = 0;
  int _score = 0;
  bool _isFinished = false;
  bool _hasStarted = false;
  
  // Selection state for current question
  int? _selectedOptionIndex;
  bool _answered = false; // To show feedback immediately after selection? Or wait for next? 
  // Requirement says: "Deshabilitar Siguiente hasta que usuario seleccione respuesta"
  // Does not explicitly say to show immediate feedback, but usually better UX. 
  // Let's stick to simple: Select -> Enable Next -> Next -> (Maybe show feedback here? Or only at end?)
  // Prompt says: "Retroalimentación: Lista corta de preguntas falladas con explicación... (al final)"
  // So we don't necessarily need immediate feedback per question, but it's nice.
  // Let's just track answers for the final report.
  
  final Map<int, int> _userAnswers = {}; // Question Index -> Selected Option Index
  Map<String, dynamic>? _lastResult;

  @override
  void initState() {
    super.initState();
    _loadLastResult();
    _resetQuiz();
  }

  Future<void> _loadLastResult() async {
    final prefs = await SharedPreferences.getInstance();
    final score = prefs.getInt('aula_quiz_last_score');
    final total = prefs.getInt('aula_quiz_total');
    
    if (score != null && total != null) {
      setState(() {
        _lastResult = {
          'score': score,
          'total': total,
          'level': _calculateLevel(score, total),
        };
      });
    }
  }

  Future<void> _saveResult() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('aula_quiz_last_score', _score);
    await prefs.setInt('aula_quiz_total', _questions.length);
    _loadLastResult(); // Refresh view
  }

  String _calculateLevel(int score, int total) {
    final pct = score / total;
    if (pct < 0.5) return 'Básico';
    if (pct < 0.8) return 'Intermedio';
    return 'Avanzado';
  }

  void _resetQuiz() {
    setState(() {
      _questions = List.from(_allQuestions)..shuffle(); // Shuffle questions
      _currentIndex = 0;
      _score = 0;
      _isFinished = false;
      _hasStarted = false;
      _selectedOptionIndex = null;
      _answered = false;
      _userAnswers.clear();
    });
  }

  void _startQuiz() {
    setState(() {
      _hasStarted = true;
    });
  }

  void _submitAnswer() {
    if (_selectedOptionIndex == null) return;

    final question = _questions[_currentIndex];
    final isCorrect = _selectedOptionIndex == question['correctIndex'];

    setState(() {
       _userAnswers[_currentIndex] = _selectedOptionIndex!;
      if (isCorrect) _score++;
      
      // Move to next or finish
      if (_currentIndex < _questions.length - 1) {
        _currentIndex++;
        _selectedOptionIndex = null;
      } else {
        _isFinished = true;
        _saveResult();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isFinished) {
      return _buildResultsView();
    }

    if (!_hasStarted) {
      return _buildWelcomeView();
    }

    return _buildQuestionView();
  }

  Widget _buildWelcomeView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.school, size: 60, color: kNeonGold),
          const SizedBox(height: 24),
          Text(
            'Prueba Final',
            style: GoogleFonts.outfit(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            '12 Preguntas para poner a prueba tu conocimiento.\nTemas: Presupuesto, Costos, Margen, KPIs y más.',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 32),
          if (_lastResult != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                children: [
                  Text('ÚLTIMO RESULTADO', style: GoogleFonts.outfit(color: kNeonBlue, fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(
                    '${_lastResult!['score']} / ${_lastResult!['total']}',
                    style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Nivel: ${_lastResult!['level']}',
                     style: GoogleFonts.outfit(color: Colors.white54, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
          
          NeonButton(
            text: 'COMENZAR QUIZ',
            onTap: _startQuiz,
            color: kNeonGold,
            icon: Icons.play_arrow,
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionView() {
    final question = _questions[_currentIndex];
    final progress = (_currentIndex + 1) / _questions.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white10,
            color: kNeonGold,
            minHeight: 6,
          ),
          const SizedBox(height: 12),
          Text(
            'Pregunta ${_currentIndex + 1} de ${_questions.length}',
            style: GoogleFonts.outfit(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 24),

          // Question Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E24), // Slightly lighter dark
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Topic Chip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: kNeonBlue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: kNeonBlue.withOpacity(0.3)),
                  ),
                  child: Text(
                    (question['topic'] as String).toUpperCase(),
                    style: GoogleFonts.outfit(color: kNeonBlue, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  question['question'],
                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 24),

                // Options
                ...List.generate((question['options'] as List).length, (index) {
                  final option = question['options'][index];
                  final isSelected = _selectedOptionIndex == index;
                  
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedOptionIndex = index;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: isSelected ? kNeonGold.withOpacity(0.2) : Colors.white.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? kNeonGold : Colors.white10,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                           Container(
                             width: 24, height: 24,
                             decoration: BoxDecoration(
                               shape: BoxShape.circle,
                               border: Border.all(color: isSelected ? kNeonGold : Colors.white24),
                               color: isSelected ? kNeonGold : null,
                             ),
                             child: isSelected ? const Icon(Icons.check, size: 16, color: Colors.black) : null,
                           ),
                           const SizedBox(width: 12),
                           Expanded(
                             child: Text(
                               option,
                               style: GoogleFonts.outfit(
                                 color: isSelected ? Colors.white : Colors.white70,
                                 fontSize: 15,
                                 fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                               ),
                             ),
                           ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Action Button
          SizedBox(
             width: double.infinity,
             child: NeonButton(
              text: _currentIndex == _questions.length - 1 ? 'FINALIZAR' : 'SIGUIENTE',
              onTap: _selectedOptionIndex != null ? _submitAnswer : () {}, // Pass empty function if disabled, standard pattern
              color: _selectedOptionIndex != null ? kNeonGold : Colors.grey.withOpacity(0.3),
            ),
          ),
          
        ],
      ),
    );
  }

  Widget _buildResultsView() {
    final pct = _score / _questions.length;
    final level = _calculateLevel(_score, _questions.length);
    Color levelColor = level == 'Avanzado' ? kNeonGreen : (level == 'Intermedio' ? Colors.yellowAccent : Colors.orangeAccent);

    // Identify wrong answers
    final wrongAnswers = <Map<String, dynamic>>[];
    _userAnswers.forEach((qIndex, aIndex) {
      final q = _questions[qIndex];
      if (aIndex != q['correctIndex']) {
        wrongAnswers.add(q);
      }
    });

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Text('RESULTADO FINAL', style: GoogleFonts.outfit(color: Colors.white54, fontSize: 13, letterSpacing: 2)),
          const SizedBox(height: 12),
          
          // Score Circle
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 120, height: 120,
                child: CircularProgressIndicator(
                  value: pct,
                  strokeWidth: 10,
                  backgroundColor: Colors.white10,
                  color: levelColor,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$_score/${_questions.length}',
                    style: GoogleFonts.outfit(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${(pct * 100).toInt()}%',
                    style: GoogleFonts.outfit(color: levelColor, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              )
            ],
          ),
          
          const SizedBox(height: 20),
          Text(
            'Nivel: $level',
            style: GoogleFonts.outfit(color: levelColor, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          
          const SizedBox(height: 40),
          
          // Feedback / Wrong Answers
          if (wrongAnswers.isNotEmpty) ...[
             Align(
               alignment: Alignment.centerLeft,
               child: Text(
                 'A REFORZAR:',
                 style: GoogleFonts.outfit(color: kNeonRed, fontSize: 14, fontWeight: FontWeight.bold),
               ),
             ),
             const SizedBox(height: 12),
             ...wrongAnswers.take(5).map((q) => Container(
               margin: const EdgeInsets.only(bottom: 12),
               padding: const EdgeInsets.all(12),
               decoration: BoxDecoration(
                 color: kNeonRed.withOpacity(0.05),
                 border: Border(left: BorderSide(color: kNeonRed, width: 3)),
                 borderRadius: BorderRadius.circular(4),
               ),
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Text(q['question'], style: GoogleFonts.outfit(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                   const SizedBox(height: 4),
                   Text(q['explanation'], style: GoogleFonts.outfit(color: Colors.white60, fontSize: 12)),
                 ],
               ),
             )).toList(),
             if (wrongAnswers.length > 5)
               Text('+ ${wrongAnswers.length - 5} más...', style: GoogleFonts.outfit(color: Colors.white30, fontSize: 12)),
          ] else ...[
             Container(
               padding: const EdgeInsets.all(16),
               decoration: BoxDecoration(color: kNeonGreen.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
               child: Row(
                 children: [
                   const Icon(Icons.check_circle, color: kNeonGreen),
                   const SizedBox(width: 12),
                    Expanded(child: Text('¡Excelente! No hay errores. Eres un experto.', style: GoogleFonts.outfit(color: Colors.white))),
                 ],
               ),
             )
          ],
          
          const SizedBox(height: 40),
          
          // Action Buttons
          NeonButton(
            text: 'REINTENTAR QUIZ',
            onTap: _resetQuiz,
            color: Colors.white24,
            textColor: Colors.white,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: NeonButton(
                  text: 'REPASAR GUÍAS',
                  onTap: () {
                    // Navigate to tab 0
                    DefaultTabController.of(context)?.animateTo(0);
                  },
                  color: kNeonBlue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                 child: NeonButton(
                  text: 'ABRIR LAB',
                  onTap: () {
                     // Navigate to tab 2 (Lab)
                     DefaultTabController.of(context)?.animateTo(2);
                  },
                  color: const Color(0xFFBA68C8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // --- DATA ---
  static const List<Map<String, dynamic>> _allQuestions = [
    {
      'id': 1,
      'topic': 'presupuesto',
      'question': '¿Qué significa una variación presupuestaria “desfavorable”?',
      'options': [
        'El real fue menor al presupuesto en ingresos',
        'El real fue mayor al presupuesto en gastos',
        'El real igual al presupuesto',
        'No se puede saber'
      ],
      'correctIndex': 1,
      'explanation': 'Es desfavorable cuando el resultado real empeora el objetivo (ej. más gastos o menos ingresos).',
    },
    {
      'id': 2,
      'topic': 'costos',
      'question': '¿Cuál es un costo fijo típico?',
      'options': [
        'Materia prima',
        'Comisión por venta',
        'Alquiler',
        'Flete por entrega'
      ],
      'correctIndex': 2,
      'explanation': 'Un costo fijo no cambia directamente con el volumen (ej. alquiler).',
    },
    {
      'id': 3,
      'topic': 'margen',
      'question': 'Si tus ventas suben pero tu margen baja, ¿qué es lo más probable?',
      'options': [
        'Bajó el costo variable %',
        'Subieron los costos variables o bajó el precio',
        'Bajaron los costos fijos',
        'Subió el punto de equilibrio'
      ],
      'correctIndex': 1,
      'explanation': 'Margen cae si sube el costo variable o se reduce precio/promedio.',
    },
    {
      'id': 4,
      'topic': 'punto_equilibrio',
      'question': '¿Qué te dice el punto de equilibrio?',
      'options': [
        'La ganancia máxima posible',
        'Las ventas necesarias para no perder ni ganar',
        'El total de impuestos del mes',
        'La cantidad de clientes potenciales'
      ],
      'correctIndex': 1,
      'explanation': 'Indica el nivel mínimo de ventas para cubrir costos.',
    },
    {
      'id': 5,
      'topic': 'flujo_caja',
      'question': 'Una empresa puede tener utilidad y aun así quedarse sin efectivo por:',
      'options': [
        'Cobros a crédito muy lentos',
        'Pagar menos gastos',
        'Vender más',
        'Bajar precios'
      ],
      'correctIndex': 0,
      'explanation': 'La utilidad no es igual al efectivo; la cobranza afecta caja.',
    },
    {
      'id': 6,
      'topic': 'kpis',
      'question': '¿Cuál KPI es más útil para medir eficiencia operativa?',
      'options': [
        'Rotación de inventario',
        'Cantidad de seguidores',
        'Color del logo',
        'Número de empleados'
      ],
      'correctIndex': 0,
      'explanation': 'Rotación indica qué tan eficiente se gestiona inventario.',
    },
    {
      'id': 7,
      'topic': 'niif_basico',
      'question': '¿Para qué sirven NIIF/NIIF PYMEs a nivel general?',
      'options': [
        'Para decorar reportes',
        'Para estandarizar y comparar estados financieros',
        'Para eliminar impuestos',
        'Para subir precios'
      ],
      'correctIndex': 1,
      'explanation': 'Buscan uniformidad y comparabilidad de reportes.',
    },
    {
      'id': 8,
      'topic': 'presupuesto',
      'question': '¿Qué hace un presupuesto flexible?',
      'options': [
        'Se mantiene igual aunque cambien las ventas',
        'Se ajusta al nivel real de actividad',
        'Solo aplica a bancos',
        'Sirve solo para impuestos'
      ],
      'correctIndex': 1,
      'explanation': 'Ajusta metas a la realidad del volumen/actividad.',
    },
    {
      'id': 9,
      'topic': 'costos',
      'question': 'En ABC (costeo basado en actividades), los costos se asignan:',
      'options': [
        'Solo por porcentaje fijo',
        'Según actividades y conductores de costo',
        'Solo por ventas',
        'Solo por impuestos'
      ],
      'correctIndex': 1,
      'explanation': 'ABC usa drivers para asignación más precisa.',
    },
    {
      'id': 10,
      'topic': 'margen',
      'question': 'Si aumentas precio y mantienes costos, ¿qué pasa con el margen?',
      'options': [
        'Baja',
        'Se mantiene',
        'Sube',
        'Desaparece'
      ],
      'correctIndex': 2,
      'explanation': 'Con costos constantes, precio mayor aumenta margen.',
    },
    {
      'id': 11,
      'topic': 'flujo_caja',
      'question': 'Verdadero o falso: “Más ventas siempre significa más efectivo”.',
      'options': [
        'VERDADERO',
        'FALSO'
      ],
      'correctIndex': 1,
      'explanation': 'FALSO. Si vendes a crédito, el efectivo puede no entrar aún.',
    },
    {
      'id': 12,
      'topic': 'punto_equilibrio',
      'question': 'Verdadero o falso: “Si suben los costos fijos, sube el punto de equilibrio”.',
      'options': [
        'VERDADERO',
        'FALSO'
      ],
      'correctIndex': 0,
      'explanation': 'VERDADERO. Necesitas más ventas para cubrir costos fijos mayores.',
    },
  ];
}
