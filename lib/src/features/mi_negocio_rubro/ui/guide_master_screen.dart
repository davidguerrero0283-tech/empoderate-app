import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../ui/theme/empoderate_theme.dart';
import '../../../components/premium_scaffold.dart';

class GuideMasterScreen extends StatefulWidget {
  const GuideMasterScreen({Key? key}) : super(key: key);

  @override
  State<GuideMasterScreen> createState() => _GuideMasterScreenState();
}

class _GuideMasterScreenState extends State<GuideMasterScreen> {
  // 11 Questions for Deep Diagnosis
  int? _sex; // 0: Male, 1: Female, 2: Other/Prefer not to say
  int? _a1; // Presupuesto
  int? _a2; // Tiempo
  int? _a3; // Riesgo
  int? _a4; // Personas vs Objetos
  int? _a5; // Superpoder
  int? _a6; // Local
  int? _a7; // Paciencia
  int? _a8; // Tech
  int? _a9; // Tipo Venta
  int? _a10; // Escala
  
  bool _showResults = false;
  Map<String, int> _scores = {};
  String _topRecommend = '';
  String _reasoning = '';

  // Categories keys
  static const String catFood = 'Comida';
  static const String catBeauty = 'Belleza';
  static const String catRetail = 'Tienda';
  static const String catDigital = 'Digital';
  static const String catEvents = 'Eventos';

  void _calculateResults() {
    // Validate all answered
    if (_sex == null || _a1 == null || _a2 == null || _a3 == null ||
        _a4 == null || _a5 == null || _a6 == null || 
        _a7 == null || _a8 == null || _a9 == null || _a10 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor responde todas las preguntas para un diagnóstico preciso.')),
      );
      return;
    }

    // Initialize scores
    Map<String, int> scores = {
      catFood: 0,
      catBeauty: 0,
      catRetail: 0,
      catDigital: 0,
      catEvents: 0,
    };

    // --- LOGIC ENGINE V2.1 (With Demographic Weighting) ---

    // Q0: Sexo
    // 0: Hombre -> Digital (Trend), Retail (Hardware/Tech), Food
    // 1: Mujer -> Beauty (Strong Trend), Events (Planning), Food (Catering/Traite)
    if (_sex == 0) {
      scores[catDigital] = (scores[catDigital] ?? 0) + 1;
      scores[catRetail] = (scores[catRetail] ?? 0) + 1;
    } else if (_sex == 1) {
      scores[catBeauty] = (scores[catBeauty] ?? 0) + 3; // Statistically dominant
      scores[catEvents] = (scores[catEvents] ?? 0) + 2;
      scores[catFood] = (scores[catFood] ?? 0) + 1;
    }
    
    // Q1: Presupuesto
    // 0: Bajo (<$500) -> Digital (Strong), Service (Beauty/Events partial)
    // 1: Medio ($500-$5k) -> Food (Ghost kitchen), Beauty (Home), Retail (Reselling)
    // 2: Alto (>$5k) -> Retail (Stock), Food (Local), Beauty (Spa)
    if (_a1 == 0) {
      scores[catDigital] = (scores[catDigital] ?? 0) + 4;
      scores[catEvents] = (scores[catEvents] ?? 0) + 2;
    } else if (_a1 == 1) {
      scores[catFood] = (scores[catFood] ?? 0) + 2;
      scores[catBeauty] = (scores[catBeauty] ?? 0) + 2;
      scores[catRetail] = (scores[catRetail] ?? 0) + 2;
    } else {
      scores[catRetail] = (scores[catRetail] ?? 0) + 3;
      scores[catFood] = (scores[catFood] ?? 0) + 3;
      scores[catBeauty] = (scores[catBeauty] ?? 0) + 2; // Equipment intensive
    }

    // Q2: Tiempo
    // 0: Fines de semana -> Events (Strong)
    // 1: Flexible/Noches -> Digital, Food (Dinner/Delivery)
    // 2: Full Time -> Retail, Beauty, Food
    if (_a2 == 0) {
      scores[catEvents] = (scores[catEvents] ?? 0) + 5;
    } else if (_a2 == 1) {
      scores[catDigital] = (scores[catDigital] ?? 0) + 3;
      scores[catFood] = (scores[catFood] ?? 0) + 1;
    } else {
      scores[catRetail] = (scores[catRetail] ?? 0) + 2;
      scores[catBeauty] = (scores[catBeauty] ?? 0) + 2;
    }

    // Q3: Tolerancia al Riesgo
    // 0: Conservador (Lo seguro) -> Retail (Proven), Beauty (Always need)
    // 1: Moderado -> Food, Events
    // 2: Arriesgado (Innovar) -> Digital (Scalable but risky), Niche Food
    if (_a3 == 0) {
      scores[catBeauty] = (scores[catBeauty] ?? 0) + 3; // People always need haircuts
      scores[catRetail] = (scores[catRetail] ?? 0) + 2; // People always buy stuff
    } else if (_a3 == 2) {
      scores[catDigital] = (scores[catDigital] ?? 0) + 4;
      scores[catEvents] = (scores[catEvents] ?? 0) + 2; // Trends
    }

    // Q4: Personas vs Objetos/Sistemas
    // 0: Amo a la gente -> Beauty, Events, Food (Service)
    // 1: Prefiero no interactuar -> Digital, Retail (E-com)
    // 2: Balanceado -> Retail (Physical), Food
    if (_a4 == 0) {
      scores[catBeauty] = (scores[catBeauty] ?? 0) + 4;
      scores[catEvents] = (scores[catEvents] ?? 0) + 4;
      scores[catFood] = (scores[catFood] ?? 0) + 2;
    } else if (_a4 == 1) {
      scores[catDigital] = (scores[catDigital] ?? 0) + 4;
      scores[catRetail] = (scores[catRetail] ?? 0) + 2; // Stock management
    }

    // Q5: Superpoder (Skill)
    // 0: Manual/Artesanal -> Food, Beauty
    // 1: Lógica/Tech -> Digital
    // 2: Social/Ventas -> Events, Retail
    if (_a5 == 0) {
      scores[catFood] = (scores[catFood] ?? 0) + 5;
      scores[catBeauty] = (scores[catBeauty] ?? 0) + 4;
    } else if (_a5 == 1) {
      scores[catDigital] = (scores[catDigital] ?? 0) + 5;
    } else {
      scores[catEvents] = (scores[catEvents] ?? 0) + 3;
      scores[catRetail] = (scores[catRetail] ?? 0) + 4;
    }

    // Q6: Local Físico
    // 0: No (Online/Nómada) -> Digital, Events (Remote planning)
    // 1: En mi casa -> Food (Dark kitchen), Beauty (Home studio)
    // 2: Sí, quiero un local -> Retail, Food, Beauty
    if (_a6 == 0) {
      scores[catDigital] = (scores[catDigital] ?? 0) + 5;
      scores[catRetail] = (scores[catRetail] ?? 0) - 1; // Punish physical retail
    } else if (_a6 == 1) {
      scores[catFood] = (scores[catFood] ?? 0) + 3;
      scores[catBeauty] = (scores[catBeauty] ?? 0) + 3;
    } else {
      scores[catRetail] = (scores[catRetail] ?? 0) + 3;
      scores[catFood] = (scores[catFood] ?? 0) + 2;
    }

    // Q7: Retorno de Inversión (Paciencia)
    // 0: Dinero Rápido (Cashflow diario) -> Food, Beauty, Retail
    // 1: Construir a largo plazo (Asset) -> Digital, Brand Retail
    if (_a7 == 0) {
      scores[catFood] = (scores[catFood] ?? 0) + 3; // Eat everyday
      scores[catBeauty] = (scores[catBeauty] ?? 0) + 2; // Service paid immediately
    } else {
      scores[catDigital] = (scores[catDigital] ?? 0) + 3;
    }

    // Q8: Tecnología
    // 0: Soy un tronco / No me gusta -> Food, Beauty (Manual), Retail (Traditional)
    // 1: Me defiendo / Me gusta -> Digital
    if (_a8 == 0) {
      scores[catDigital] = (scores[catDigital] ?? 0) - 5; // Killer constraint
      scores[catFood] = (scores[catFood] ?? 0) + 1;
      scores[catBeauty] = (scores[catBeauty] ?? 0) + 1;
    } else {
      scores[catDigital] = (scores[catDigital] ?? 0) + 3;
    }

    // Q9: Venta
    // 0: Producto Físico -> Retail, Food
    // 1: Servicio Intangible -> Digital, Events, Beauty
    if (_a9 == 0) {
      scores[catRetail] = (scores[catRetail] ?? 0) + 4;
      scores[catFood] = (scores[catFood] ?? 0) + 2;
    } else {
      scores[catDigital] = (scores[catDigital] ?? 0) + 2;
      scores[catEvents] = (scores[catEvents] ?? 0) + 2;
      scores[catBeauty] = (scores[catBeauty] ?? 0) + 2;
    }

    // Q10: Escala
    // 0: Lifestyle (Vivir bien, tranquilo) -> Beauty, Digital (Freelance)
    // 1: Imperio (Sucursales/Mundial) -> Retail, Digital (SaaS), Food (Franchise)
    if (_a10 == 0) {
      scores[catBeauty] = (scores[catBeauty] ?? 0) + 2;
      scores[catDigital] = (scores[catDigital] ?? 0) + 1; // Freelancing
    } else {
      scores[catRetail] = (scores[catRetail] ?? 0) + 3;
      scores[catDigital] = (scores[catDigital] ?? 0) + 3; // Software scales infinite
    }

    // Determine Winner
    var sortedEntries = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    String winner = sortedEntries.first.key;
    
    // Generate Rich Thinking Logic (Reasoning)
    String reason = '';
    if (winner == catDigital) {
      reason = 'Tu perfil es altamente compatible con el mundo DIGITAL. Valoras la flexibilidad, tienes afinidad tecnológica y prefieres modelos de baja inversión inicial/alto margen.';
    } else if (winner == catFood) {
      reason = 'La GASTRONOMÍA es tu fuerte. Buscas flujo de caja diario y estás dispuesto a trabajar duro para ver resultados inmediatos.';
    } else if (winner == catRetail) {
      reason = 'Tienes mentalidad de COMERCIANTE (Retail). Entiendes el valor de comprar y vender productos físicos.';
    } else if (winner == catBeauty) {
      reason = 'BELLEZA Y BIENESTAR es tu nicho ideal. Disfrutas el trato personal y buscas clientes fieles que regresen constantemente.';
    } else if (winner == catEvents) {
      reason = 'Naciste para los EVENTOS. Tu energía social y dinamismo encajan perfecto aquí.';
    }

    setState(() {
      _scores = scores;
      _topRecommend = winner;
      _reasoning = reason;
      _showResults = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      title: 'GUÍA MAESTRA: ELEGIR RUBRO',
      isNeonTitle: true,
      showBackButton: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('A) Diagnóstico Profundo', Icons.psychology),
            _buildDiagnosisCard(),
            
            const SizedBox(height: 32),
            if (_showResults) ...[
              _buildSectionHeader('B) Tu Resultado Personalizado', Icons.stars),
              _buildResults(),
              const SizedBox(height: 32),
            ],

            _buildSectionHeader('C) Ventajas y riesgos por rubro', Icons.analytics),
            _buildIndustryCards(),
            
            const SizedBox(height: 32),
            _buildSectionHeader('D) Checklist de Decisiones', Icons.checklist),
            _buildChecklist(),
            
            const SizedBox(height: 32),
            _buildSectionHeader('E) Matriz: Inversión vs Complejidad', Icons.grid_view),
            _buildMatrix(),
            
            const SizedBox(height: 48),
            _buildFinalButton(),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, color: EmpoderateTheme.goldStrong, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title.toUpperCase(),
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiagnosisCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: EmpoderateTheme.safeBoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Responde estas 10 preguntas clave para desbloquear tu perfil emprendedor.',
            style: TextStyle(color: Colors.white60, fontSize: 13, fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 24),
          
          _buildCategoryHeader('💰 1. Recursos'),
          _buildQuestion(0, 'Sexo', ['Masculino', 'Femenino', 'Prefiero no decir']), // Nuevo
          _buildQuestion(1, 'Presupuesto Inicial', ['Bajo (< \$500)', 'Medio (\$500 - \$5k)', 'Alto (> \$5k)']),
          _buildQuestion(2, 'Tiempo Disponible', ['Solo Fines de Semana', 'Flexible/Noches', 'Tiempo Completo']),
          _buildQuestion(6, 'Ubicación / Local', ['Nómada/Online', 'Desde casa', 'Local comercial']),

          const SizedBox(height: 16),
          _buildCategoryHeader('🧠 2. Personalidad y Habilidades'),
          _buildQuestion(3, 'Tolerancia al Riesgo', ['Conservador (Seguro)', 'Moderado', 'Arriesgado (Innovar)']),
          _buildQuestion(4, 'Interacción Humana', ['Amo tratar con gente', 'Prefiero no interactuar', 'Balanceado']),
          _buildQuestion(5, 'Tu Superpoder', ['Manual / Artesanal', 'Lógica / Tecnología', 'Ventas / Social']),
          _buildQuestion(8, 'Afinidad Tecnológica', ['Baja (No me gusta)', 'Alta (Me encanta)']),

          const SizedBox(height: 16),
          _buildCategoryHeader('🚀 3. Visión de Negocio'),
          _buildQuestion(7, 'Tipo de Retorno', ['Dinero Rápido (Diario)', 'Construir Patrimonio (Largo Plazo)']),
          _buildQuestion(9, '¿Qué prefieres vender?', ['Producto Físico', 'Servicio Intangible']),
          _buildQuestion(10, 'Escalabilidad', ['Estilo de Vida (Tranquilo)', 'Imperio (Crecer sin límite)']),
          
          const SizedBox(height: 32),
          if (!_showResults)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: EmpoderateTheme.goldStrong,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 6,
                  shadowColor: EmpoderateTheme.goldStrong.withOpacity(0.4),
                ),
                onPressed: _calculateResults,
                child: const Text('DETECTAR MI RUBRO IDEAL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            )
          else 
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.refresh), 
                style: OutlinedButton.styleFrom(
                  foregroundColor: EmpoderateTheme.goldStrong,
                  side: BorderSide(color: EmpoderateTheme.goldStrong),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                   setState(() {
                     _showResults = false;
                     _sex = null; // Clear gender
                     _a1 = null; _a2 = null; _a3 = null; _a4 = null; _a5 = null;
                     _a6 = null; _a7 = null; _a8 = null; _a9 = null; _a10 = null;
                   });
                },
                label: const Text('REINICIAR TEST'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.outfit(
          color: EmpoderateTheme.gold,
          fontWeight: FontWeight.bold,
          fontSize: 14,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildQuestion(int index, String question, List<String> options) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(options.length, (i) {
              bool selected = false;
              if (index == 0) selected = _sex == i; // NEW
              if (index == 1) selected = _a1 == i;
              if (index == 2) selected = _a2 == i;
              if (index == 3) selected = _a3 == i;
              if (index == 4) selected = _a4 == i;
              if (index == 5) selected = _a5 == i;
              if (index == 6) selected = _a6 == i;
              if (index == 7) selected = _a7 == i;
              if (index == 8) selected = _a8 == i;
              if (index == 9) selected = _a9 == i;
              if (index == 10) selected = _a10 == i;

              return ChoiceChip(
                label: Text(options[i]),
                selected: selected,
                onSelected: (val) {
                  setState(() {
                    if (index == 0) _sex = i; // NEW
                    if (index == 1) _a1 = i;
                    if (index == 2) _a2 = i;
                    if (index == 3) _a3 = i;
                    if (index == 4) _a4 = i;
                    if (index == 5) _a5 = i;
                    if (index == 6) _a6 = i;
                    if (index == 7) _a7 = i;
                    if (index == 8) _a8 = i;
                    if (index == 9) _a9 = i;
                    if (index == 10) _a10 = i;
                  });
                },
                backgroundColor: Colors.white.withOpacity(0.05),
                selectedColor: EmpoderateTheme.goldStrong,
                labelStyle: TextStyle(
                  color: selected ? Colors.black : Colors.white70,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: selected ? EmpoderateTheme.goldStrong : Colors.white12),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
                child: Text('TU RUBRO IDEAL ES:', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, letterSpacing: 1)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _topRecommend.toUpperCase(),
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
          Text(
            _reasoning,
            style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.5),
          ),
          const SizedBox(height: 20),
          const Divider(color: Colors.white12),
          const SizedBox(height: 12),
          Text('Tus otras compatibilidades:', style: TextStyle(color: Colors.white54, fontSize: 12)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _scores.entries.where((e) => e.key != _topRecommend).map((e) {
               // Normalize score for visualization roughly
               return Chip(
                 label: Text('${e.key}: ${e.value} pts'),
                 backgroundColor: Colors.white.withOpacity(0.05),
                 labelStyle: const TextStyle(color: Colors.white60, fontSize: 11),
               );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildIndustryCards() {
    return Column(
      children: [
        _buildIndustryItem(
          title: '💅 Belleza y Bienestar',
          desc: 'Barbería, Spa, Uñas, Maquillaje.',
          advantages: 'Alta recurrencia (clientes vuelven cada 15 días), márgenes altos en servicios, propinas.',
          risks: 'Depende mucho de mano de obra (empleados), tendencias cambian rápido, atención al cliente crítica.',
          isRecommended: _showResults && _topRecommend == catBeauty,
        ),
        _buildIndustryItem(
          title: '🍔 Gastronomía (Comida)',
          desc: 'Food Truck, Restaurante, Catering.',
          advantages: 'Flujo de caja diario (efectivo inmediato), demanda constante (todos comen 3 veces al día).',
          risks: 'Merma (comida se daña), horarios esclavizantes, regulaciones sanitarias estrictas, competencia feroz.',
          isRecommended: _showResults && _topRecommend == catFood,
        ),
        _buildIndustryItem(
          title: '💻 Servicios Digitales',
          desc: 'Marketing, Diseño, Programación.',
          advantages: 'Inversión inicial casi cero, mercado global, trabajo remoto, altísimos márgenes.',
          risks: 'Alta competencia global, difícil construir confianza inicial, ingreso variable al inicio.',
          isRecommended: _showResults && _topRecommend == catDigital,
        ),
        _buildIndustryItem(
          title: '🛍️ Tienda (Comercio)',
          desc: 'Ropa, Tecnología, Minimarket.',
          advantages: 'Modelo probado y fácil de entender. Escalable a sucursales.',
          risks: 'Capital atado en inventario, costos fijos altos (alquiler), riesgo de robos/pérdidas.',
          isRecommended: _showResults && _topRecommend == catRetail,
        ),
        _buildIndustryItem(
          title: '🎉 Eventos y Entretenimiento',
          desc: 'Organización, Decoración, DJ.',
          advantages: 'Se cobra por proyecto (ticket alto), creativo, networking constante.',
          risks: 'Estacionalidad (meses flojos), estrés alto en fechas clave, trabajo en fines de semana.',
          isRecommended: _showResults && _topRecommend == catEvents,
        ),
      ],
    );
  }

  Widget _buildIndustryItem({required String title, required String desc, required String advantages, required String risks, bool isRecommended = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isRecommended ? EmpoderateTheme.goldStrong.withOpacity(0.1) : Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isRecommended ? EmpoderateTheme.goldStrong : Colors.white10,
          width: isRecommended ? 1.5 : 1
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(
                color: isRecommended ? EmpoderateTheme.goldStrong : Colors.white, 
                fontWeight: FontWeight.bold, 
                fontSize: 17
              )),
              if (isRecommended)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: EmpoderateTheme.goldStrong, borderRadius: BorderRadius.circular(4)),
                  child: const Text('TU MEJOR OPCIÓN', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 10)),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(desc, style: const TextStyle(color: Colors.white54, fontSize: 13, fontStyle: FontStyle.italic)),
          const SizedBox(height: 12),
          _buildInfoRow('✅ VENTAJAS:', advantages),
          const SizedBox(height: 8),
          _buildInfoRow('⚠️ RIESGOS:', risks),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 85, child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))),
        Expanded(child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.3))),
      ],
    );
  }

  Widget _buildChecklist() {
    final decisions = [
      '¿Local físico o desde casa?',
      '¿Inventario (stock) o servicios (tiempo)?',
      '¿Ticket bajo (volumen) o alto (calidad)?',
      '¿Horarios de operación (diurno/nocturno)?',
      '¿Personal requerido desde el día 1?',
      '¿Nivel de riesgo aceptable?',
      '¿Pasión vs Rentabilidad?',
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: decisions.map((d) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.check_box_outline_blank, color: EmpoderateTheme.goldStrong.withOpacity(0.5), size: 20),
              const SizedBox(width: 12),
              Expanded(child: Text(d, style: const TextStyle(color: Colors.white70, fontSize: 14))),
            ],
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildMatrix() {
    return Table(
      border: TableBorder.all(color: Colors.white12),
      children: [
        TableRow(children: [
          _buildMatrixCell('BAJA INVERSIÓN\nBAJA COMPLEJIDAD', 'Freelance, Paseo perros, Tutorías', Colors.green),
          _buildMatrixCell('BAJA INVERSIÓN\nALTA COMPLEJIDAD', 'Programación, Consultoría experta', Colors.blue),
        ]),
        TableRow(children: [
          _buildMatrixCell('ALTA INVERSIÓN\nBAJA COMPLEJIDAD', 'Franquicias, Alquiler equipos', Colors.orange),
          _buildMatrixCell('ALTA INVERSIÓN\nALTA COMPLEJIDAD', 'Restaurantes, Hotelería, Fábricas', Colors.red),
        ]),
      ],
    );
  }

  Widget _buildMatrixCell(String title, String examples, Color color) {
    return Container(
      height: 110,
      padding: const EdgeInsets.all(10),
      color: color.withOpacity(0.05),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, textAlign: TextAlign.center, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 10)),
          const SizedBox(height: 6),
          Text(examples, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white54, fontSize: 9)),
        ],
      ),
    );
  }

  Widget _buildFinalButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: EmpoderateTheme.goldStrong,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 8,
          shadowColor: EmpoderateTheme.goldStrong.withOpacity(0.5),
        ),
        onPressed: () => context.go('/mi_negocio_rubro'),
        child: const Text(
          'EXPLORAR TODOS LOS RUBROS',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.1),
        ),
      ),
    );
  }
}
