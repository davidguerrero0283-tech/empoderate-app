import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../ui/theme/empoderate_theme.dart';
import '../components/premium_scaffold.dart';
import '../services/gemini_service.dart';
import '../services/market_study_service.dart';

class MarketStudyScreen extends StatefulWidget {
  final String rubroId;
  final String rubroName;

  const MarketStudyScreen({
    Key? key,
    required this.rubroId,
    required this.rubroName,
  }) : super(key: key);

  @override
  State<MarketStudyScreen> createState() => _MarketStudyScreenState();
}

class _MarketStudyScreenState extends State<MarketStudyScreen> with SingleTickerProviderStateMixin {
  final MarketStudyService _service = MarketStudyService();
  final GeminiService _gemini = GeminiService();
  
  MarketStudy? _study;
  bool _isLoading = true;
  String? _error;
  late AnimationController _pulseController;

  String? _location;
  final TextEditingController _locationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    // Instead of auto-loading, we wait for user input (Location)
    // But if we want auto-load for quick look, we can checking arguments?
    // Let's default to showing the Setup/Location screen first for "Location Intelligence".
    setState(() {
      _isLoading = false;
      _study = null; 
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _generateStudy() async {
    // FocusScope handled below
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await _gemini.init();
      
      if (!_gemini.isConfigured) {
        setState(() {
          _isLoading = false;
          _error = 'api_key_required';
        });
        return;
      }

      final study = await _service.generateStudy(
        widget.rubroId,
        widget.rubroName,
        location: _locationController.text.trim(),
        forceRefresh: true, // Always fresh when user clicks generate
      );
      
      setState(() {
        _study = study;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      title: 'Estudio de Mercado',
      subtitle: widget.rubroName,
      showBackButton: true,
      useScroll: false,
      usePadding: false,
      actions: [
        if (_study != null)
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.cyanAccent),
            tooltip: 'Nuevo Análisis',
            onPressed: () {
              setState(() {
                _study = null; // Go back to setup
              });
            },
          ),
      ],
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_error == 'api_key_required') {
      return _buildApiKeySetup();
    }

    if (_error != null) {
      return _buildErrorState();
    }

    if (_study == null) {
      return _buildSetupForm();
    }

    return _buildStudyContent();
  }
  
  Widget _buildSetupForm() {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.cyanAccent.withOpacity(0.1), Colors.purple.withOpacity(0.1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.cyanAccent.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.location_on, color: Colors.cyanAccent, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Personaliza tu Estudio',
                    style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Para resultados más precisos, dinos dónde planeas ubicar tu negocio.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 32),
                  
                  TextField(
                    controller: _locationController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Ubicación / Barrio (Opcional)',
                      labelStyle: TextStyle(color: Colors.white60),
                      hintText: 'Ej. Tocumen, Brisas del Golf, David...',
                      hintStyle: TextStyle(color: Colors.white24),
                      prefixIcon: Icon(Icons.map, color: Colors.cyanAccent),
                      filled: true,
                      fillColor: Colors.black26,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white10)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.cyanAccent)),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _generateStudy,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.cyanAccent,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 4,
                        shadowColor: Colors.cyanAccent.withOpacity(0.4),
                      ),
                      child: Text(
                        'GENERAR ANÁLISIS IA',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1),
                      ),
                    ),
                  ),
                ],
              ),
            ),
             const SizedBox(height: 32),
             Row(
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                 Icon(Icons.auto_awesome, color: Colors.purpleAccent, size: 16),
                 const SizedBox(width: 8),
                 Text('Potenciado por Gemini AI', style: GoogleFonts.outfit(color: Colors.white38, fontSize: 12)),
               ],
             )
          ],
        ),
      );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.cyanAccent.withOpacity(0.3 + _pulseController.value * 0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black,
                      border: Border.all(color: Colors.cyanAccent, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.cyanAccent.withOpacity(0.5),
                          blurRadius: 20 + _pulseController.value * 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.psychology, color: Colors.cyanAccent, size: 40),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 32),
          Text(
            'Analizando el mercado...',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Gemini AI está procesando tu estudio',
            style: GoogleFonts.outfit(color: Colors.white54, fontSize: 14),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: 200,
            child: LinearProgressIndicator(
              backgroundColor: Colors.white10,
              color: Colors.cyanAccent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApiKeySetup() {
    final controller = TextEditingController();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Colors.purple.shade900, Colors.cyan.shade900],
              ),
              border: Border.all(color: Colors.cyanAccent.withOpacity(0.5), width: 2),
            ),
            child: const Icon(Icons.key, color: Colors.cyanAccent, size: 48),
          ),
          const SizedBox(height: 32),
          Text(
            'Configura Gemini AI',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Para usar el Estudio de Mercado Inteligente,\nnecesitas una API Key de Google AI (es gratis)',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(color: Colors.white60, fontSize: 14),
          ),
          const SizedBox(height: 32),
          
          // Steps
          _buildSetupStep(
            '1',
            'Visita Google AI Studio',
            'aistudio.google.com',
            Icons.open_in_new,
          ),
          const SizedBox(height: 12),
          _buildSetupStep(
            '2',
            'Crea una API Key',
            'Es gratis y toma 2 minutos',
            Icons.vpn_key,
          ),
          const SizedBox(height: 12),
          _buildSetupStep(
            '3',
            'Pega tu API Key aquí',
            'La guardamos de forma segura',
            Icons.lock,
          ),
          
          const SizedBox(height: 32),
          
          // API Key Input
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.cyanAccent.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                TextField(
                  controller: controller,
                  style: GoogleFonts.outfit(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Tu API Key de Gemini',
                    labelStyle: TextStyle(color: Colors.white54),
                    hintText: 'AIza...',
                    hintStyle: TextStyle(color: Colors.white24),
                    prefixIcon: Icon(Icons.key, color: Colors.cyanAccent),
                    filled: true,
                    fillColor: Colors.black26,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.cyanAccent),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (controller.text.trim().isNotEmpty) {
                        await _gemini.setApiKey(controller.text.trim());
                        _generateStudy();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyanAccent,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'GUARDAR Y CONTINUAR',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          TextButton.icon(
            onPressed: () {
              // Open URL to Google AI Studio
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Visita: aistudio.google.com para obtener tu API Key gratis'),
                  duration: Duration(seconds: 5),
                ),
              );
            },
            icon: const Icon(Icons.help_outline, color: Colors.white38),
            label: Text(
              '¿Necesitas ayuda?',
              style: GoogleFonts.outfit(color: Colors.white38),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSetupStep(String number, String title, String subtitle, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.cyanAccent.withOpacity(0.2),
            ),
            child: Center(
              child: Text(
                number,
                style: GoogleFonts.outfit(
                  color: Colors.cyanAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w500)),
                Text(subtitle, style: GoogleFonts.outfit(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
          Icon(icon, color: Colors.white38, size: 20),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red.withOpacity(0.1),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: const Icon(Icons.error_outline, color: Colors.redAccent, size: 40),
            ),
            const SizedBox(height: 24),
            Text(
              'Error al generar estudio',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _error ?? 'Error desconocido',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(color: Colors.white54, fontSize: 14),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _generateStudy(),
              icon: const Icon(Icons.refresh),
              label: const Text('REINTENTAR'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyanAccent,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudyContent() {
    final study = _study!;
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm', 'es');
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.cyanAccent.withOpacity(0.15),
                  Colors.purple.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.cyanAccent.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.analytics, color: Colors.cyanAccent, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Estudio Generado por IA',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Actualizado: ${dateFormat.format(study.generatedAt)}',
                        style: GoogleFonts.outfit(color: Colors.white54, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 14),
                      const SizedBox(width: 4),
                      Text('Gemini', style: GoogleFonts.outfit(color: Colors.green, fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Study Sections
          _buildStudySection(
            '📊',
            'Análisis de Competencia',
            study.competitionAnalysis,
            Colors.blue,
          ),
          
          _buildStudySection(
            '🎯',
            'Tu Cliente Ideal',
            study.targetAudience,
            Colors.purple,
          ),
          
          _buildStudySection(
            '💡',
            'Oportunidades de Mercado',
            study.opportunities,
            Colors.green,
          ),
          
          _buildStudySection(
            '⚠️',
            'Riesgos y Amenazas',
            study.risks,
            Colors.orange,
          ),
          
          _buildStudySection(
            '💰',
            'Estrategia de Precios',
            study.pricingStrategy,
            Colors.amber,
          ),
          
          _buildStudySection(
            '✅',
            'Recomendaciones Estratégicas',
            study.recommendations,
            Colors.cyanAccent,
          ),
          
          const SizedBox(height: 24),
          
          // Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(
                      text: '''
ESTUDIO DE MERCADO: ${study.rubroName}
Generado: ${dateFormat.format(study.generatedAt)}

📊 ANÁLISIS DE COMPETENCIA
${study.competitionAnalysis}

🎯 CLIENTE IDEAL
${study.targetAudience}

💡 OPORTUNIDADES
${study.opportunities}

⚠️ RIESGOS
${study.risks}

💰 ESTRATEGIA DE PRECIOS
${study.pricingStrategy}

✅ RECOMENDACIONES
${study.recommendations}
''',
                    ));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('✓ Estudio copiado al portapapeles')),
                    );
                  },
                  icon: const Icon(Icons.copy),
                  label: const Text('COPIAR'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    side: BorderSide(color: Colors.white24),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _generateStudy(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('REGENERAR'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyanAccent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 40),

          // Navigate to Other Rubros
          GestureDetector(
            onTap: () => context.push('/mi_negocio_rubro'),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.store, color: Colors.white70),
                  const SizedBox(width: 12),
                  Text(
                    'Escoger otro Rubro',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.arrow_forward, color: Colors.white54, size: 18),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildStudySection(String emoji, String title, String content, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: true,
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          leading: Text(emoji, style: const TextStyle(fontSize: 24)),
          title: Text(
            title,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          iconColor: color,
          collapsedIconColor: color.withOpacity(0.5),
          children: [
            Text(
              content,
              style: GoogleFonts.outfit(
                color: Colors.white70,
                fontSize: 14,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
