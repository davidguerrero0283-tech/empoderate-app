import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../ui/theme/empoderate_theme.dart';

class RubroSelectorQuestionnaire extends StatefulWidget {
  const RubroSelectorQuestionnaire({Key? key}) : super(key: key);

  @override
  State<RubroSelectorQuestionnaire> createState() => _RubroSelectorQuestionnaireState();
}

class _RubroSelectorQuestionnaireState extends State<RubroSelectorQuestionnaire> {
  int _currentStep = 0;
  final Map<String, dynamic> _answers = {};

  final List<QuestionStep> _steps = [
    // 1. INTERESES
    QuestionStep(
      id: 'interest',
      title: '¿Qué te apasiona más?',
      description: 'Elige el área donde te sientes más cómodo.',
      options: [
        Option(label: 'Cocinar y servir comida', value: 'food', icon: Icons.restaurant),
        Option(label: 'Belleza y cuidado personal', value: 'beauty', icon: Icons.brush),
        Option(label: 'Vender productos (Retail)', value: 'retail', icon: Icons.store),
        Option(label: 'Servicios Profesionales', value: 'services', icon: Icons.work),
        Option(label: 'Tecnología y Digital', value: 'digital', icon: Icons.computer),
        Option(label: 'Manualidades / Hecho en casa', value: 'handmade', icon: Icons.home),
      ],
    ),
    // 2. PRESUPUESTO
    QuestionStep(
      id: 'budget',
      title: '¿Cuál es tu presupuesto inicial?',
      description: 'Sé realista con lo que puedes invertir hoy.',
      options: [
        Option(label: 'Bajo (\$100 - \$1,000)', value: 'low', subtitle: 'Empezar pequeño'),
        Option(label: 'Medio (\$1,000 - \$10,000)', value: 'medium', subtitle: 'Local pequeño o equipos'),
        Option(label: 'Alto (+\$10,000)', value: 'high', subtitle: 'Local completo y personal'),
      ],
    ),
    // 3. TIEMPO
    QuestionStep(
      id: 'time',
      title: '¿Cuánto tiempo tienes disponible?',
      description: '¿Será tu actividad principal o un ingreso extra?',
      options: [
        Option(label: 'Tiempo Completo (Full-time)', value: 'full', subtitle: 'Dedicaré todo mi día'),
        Option(label: 'Medio Tiempo / Fines de Semana', value: 'part', subtitle: 'Tengo otro trabajo/estudios'),
      ],
    ),
    // 4. UBICACIÓN
    QuestionStep(
      id: 'location',
      title: '¿Dónde planeas operar?',
      description: 'El lugar define tus costos y permisos.',
      options: [
        Option(label: 'Desde Casa (Home Office)', value: 'home', icon: Icons.home),
        Option(label: 'Local Comercial Físico', value: 'store', icon: Icons.storefront),
        Option(label: 'Móvil / A domicilio', value: 'mobile', icon: Icons.local_shipping),
        Option(label: '100% Online', value: 'online', icon: Icons.public),
      ],
    ),
  ];

  void _selectOption(String value) {
    setState(() {
      _answers[_steps[_currentStep].id] = value;
      if (_currentStep < _steps.length - 1) {
        _currentStep++;
      } else {
        _showResults();
      }
    });
  }

  void _showResults() {
    // Logic to calculate recommendation
    final interest = _answers['interest'];
    final budget = _answers['budget'];
    final location = _answers['location'];

    // Simple Recommendation Engine
    List<RecommendationResult> results = [];

    if (interest == 'food') {
      if (budget == 'low' && location == 'home') {
        results.add(RecommendationResult('Repostería Casera', 'home_baking', 'Empieza hoy mismo desde tu cocina.'));
        results.add(RecommendationResult('Catering', 'catering', 'Cocina bajo pedido, cero desperdicio.'));
      } else if (location == 'mobile') {
        results.add(RecommendationResult('Food Truck', 'food_truck', 'Gran tendencia, movilidad y menor renta.'));
      } else {
        results.add(RecommendationResult('Restaurante Pequeño', 'rest_small', 'Clásico y de alta demanda.'));
      }
    } else if (interest == 'beauty') {
      if (location == 'home' || location == 'mobile') {
        results.add(RecommendationResult('Maquillaje / Uñas a Domicilio', 'nails', 'Servicio personalizado, baja inversión.'));
      } else {
        results.add(RecommendationResult('Salón de Belleza', 'salon', 'Establecimiento físico para fidelizar clientes.'));
      }
    } else if (interest == 'digital') {
        results.add(RecommendationResult('Marketing Digital', 'marketing', 'Alta demanda, 100% remoto.'));
        results.add(RecommendationResult('E-commerce', 'ecommerce', 'Vende productos sin local físico.'));
    } else if (interest == 'handmade') {
        results.add(RecommendationResult('Artesanías / Manualidades', 'handmade', 'Convierte tu hobby en negocio.'));
    } else {
       // Fallback generic
       results.add(RecommendationResult('Explora todas las categorías', 'all', 'Revisa el catálogo completo para inspirarte.'));
    }
    
    // Ensure we always have data
    if(results.isEmpty) {
        results.add(RecommendationResult('Explora todas las categorías', 'all', 'Tu perfil es muy versátil.'));
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0F1520),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => _ResultsSheet(results: results),
    );
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_currentStep];

    return Scaffold(
      backgroundColor: const Color(0xFF0F1520),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text('Test de Compatibilidad', style: GoogleFonts.outfit(color: Colors.white, fontSize: 16)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Progress Bar
              LinearProgressIndicator(
                value: (_currentStep + 1) / _steps.length,
                backgroundColor: Colors.white10,
                color: EmpoderateTheme.cyanAccent,
                minHeight: 4,
                borderRadius: BorderRadius.circular(2),
              ),
              const SizedBox(height: 32),
              
              // Question
              Text(
                step.title,
                style: GoogleFonts.outfit(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                step.description,
                style: GoogleFonts.outfit(color: Colors.white60, fontSize: 16),
              ),
              const SizedBox(height: 48),

              // Options
              Expanded(
                child: ListView.separated(
                  itemCount: step.options.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final option = step.options[index];
                    return _OptionCard(
                      option: option,
                      onTap: () => _selectOption(option.value),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class QuestionStep {
  final String id;
  final String title;
  final String description;
  final List<Option> options;

  QuestionStep({required this.id, required this.title, required this.description, required this.options});
}

class Option {
  final String label;
  final String value;
  final String? subtitle;
  final IconData? icon;

  Option({required this.label, required this.value, this.subtitle, this.icon});
}

class RecommendationResult {
  final String name;
  final String rubroId;
  final String reason;

  RecommendationResult(this.name, this.rubroId, this.reason);
}

class _OptionCard extends StatelessWidget {
  final Option option;
  final VoidCallback onTap;

  const _OptionCard({Key? key, required this.option, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white24),
            borderRadius: BorderRadius.circular(12),
            color: Colors.white.withOpacity(0.05),
          ),
          child: Row(
            children: [
              if (option.icon != null) ...[
                Icon(option.icon, color: EmpoderateTheme.cyanAccent, size: 28),
                const SizedBox(width: 16),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(option.label, style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                    if (option.subtitle != null)
                      Text(option.subtitle!, style: GoogleFonts.outfit(color: Colors.white54, fontSize: 14)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultsSheet extends StatelessWidget {
  final List<RecommendationResult> results;

  const _ResultsSheet({Key? key, required this.results}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      height: MediaQuery.of(context).size.height * 0.7,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 24),
          Text('Tus Resultados', style: GoogleFonts.outfit(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          Text('Basado en tus respuestas, te recomendamos:', style: GoogleFonts.outfit(color: Colors.white60, fontSize: 16)),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.separated(
              itemCount: results.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final result = results[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: EmpoderateTheme.goldStrong.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: EmpoderateTheme.goldStrong.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(result.name, style: GoogleFonts.outfit(color: EmpoderateTheme.goldStrong, fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(result.reason, style: GoogleFonts.outfit(color: Colors.white70)),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: EmpoderateTheme.goldStrong,
                            foregroundColor: Colors.black,
                          ),
                          onPressed: () {
                             if(result.rubroId == 'all') {
                               context.go('/mi_negocio_rubro'); // Go back to directory
                             } else {
                               // Try to navigate to detail if possible, else directory
                               // Assuming we know category. For now, go to directory
                               context.go('/mi_negocio_rubro'); 
                             }
                             // Dismiss modals
                             Navigator.of(context).pop(); // bottomsheet
                             Navigator.of(context).pop(); // questionnaire
                          },
                          child: const Text('Ver Requisitos'),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
