import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:proyecto_empoderate/src/components/premium_scaffold.dart';
import 'package:proyecto_empoderate/src/components/neon_widgets.dart';

class SocialMediaAutomationScreen extends StatefulWidget {
  const SocialMediaAutomationScreen({Key? key}) : super(key: key);

  @override
  State<SocialMediaAutomationScreen> createState() => _SocialMediaAutomationScreenState();
}

class _SocialMediaAutomationScreenState extends State<SocialMediaAutomationScreen> {
  final ScrollController _scrollController = ScrollController();
  
  // General Fields
  final _topicCtrl = TextEditingController();
  final _businessCtrl = TextEditingController();
  final _targetAudienceCtrl = TextEditingController();
  final _painPointCtrl = TextEditingController();
  final _ctaCtrl = TextEditingController();
  
  String _contentType = 'Promocional';
  String _tone = 'Profesional';
  List<String> _selectedPlatforms = ['Instagram'];
  
  // YouTube Specific
  final _youtubeTitle = TextEditingController();
  final _youtubeKeywords = TextEditingController();
  String _videoLength = '5-10 min';
  String _thumbnailStyle = 'Texto Grande + Cara';
  
  // Instagram Specific
  String _instagramPostType = 'Reel';
  String _captionLength = 'Medio (100-150 palabras)';
  final _instagramHashtagNiche = TextEditingController();
  
  // TikTok Specific
  String _tiktokHookType = 'Pregunta';
  final _tiktokTrendingSoundCtrl = TextEditingController();
  String _tiktokDuration = '15-30 seg';
  
  // Facebook Specific
  String _facebookCTAType = 'Llamar Ahora';
  final _facebookLocationCtrl = TextEditingController();
  String _facebookEventType = 'Promoción';
  
  bool _isGenerating = false;
  Map<String, Map<String, String>>? _generatedContent;

  @override
  void initState() {
    super.initState();
    _loadSavedBusiness();
  }

  Future<void> _loadSavedBusiness() async {
    final prefs = await SharedPreferences.getInstance();
    final savedBusiness = prefs.getString('marketing_automation_business');
    if (savedBusiness != null && mounted) {
      setState(() {
        _businessCtrl.text = savedBusiness;
      });
    }
  }

  Future<void> _saveBusiness() async {
    if (_businessCtrl.text.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('marketing_automation_business', _businessCtrl.text);
    }
  }

  final List<Map<String, dynamic>> _platforms = [
    {'name': 'Instagram', 'icon': Icons.camera_alt, 'color': Color(0xFFE4405F)},
    {'name': 'Facebook', 'icon': Icons.facebook, 'color': Color(0xFF1877F2)},
    {'name': 'TikTok', 'icon': Icons.music_note, 'color': Color(0xFF000000)},
    {'name': 'YouTube', 'icon': Icons.play_circle_outline, 'color': Color(0xFFFF0000)},
  ];

  // Helper to preserve scroll position during setState
  void _setStatePreservingScroll(VoidCallback fn) {
    final scrollPosition = _scrollController.hasClients ? _scrollController.offset : 0.0;
    setState(fn);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients && scrollPosition > 0) {
        _scrollController.jumpTo(scrollPosition);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      title: 'Automatización IA',
      isNeonTitle: true,
      showBackButton: true,
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.only(bottom: 80),
        physics: const ClampingScrollPhysics(), // Prevents bouncing
        child: Column(
          key: ValueKey(_selectedPlatforms.join(',')), // Preserve state
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            
            // Hero Section
            _buildHeroSection(),
            const SizedBox(height: 30),
            
            // Platform Selection (moved before form)
            _buildPlatformSelection(),
            const SizedBox(height: 30),
            
            // Configuration Form
            _buildConfigurationForm(),
            const SizedBox(height: 30),
            
            // Generate Button
            _buildGenerateButton(),
            const SizedBox(height: 30),
            
            // Results
            if (_isGenerating)
              _buildLoadingState()
            else if (_generatedContent != null)
              _buildResults(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFD500F9).withOpacity(0.2),
            const Color(0xFF651FFF).withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD500F9).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFD500F9).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.auto_awesome, color: Color(0xFFD500F9), size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Generador Multi-Plataforma',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Crea contenido profesional automáticamente - solo dinos el tema y nosotros hacemos el resto',
                      style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.tips_and_updates, color: Colors.amber, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Ahorra 5+ horas semanales. La IA adapta el mensaje a cada plataforma automáticamente.',
                    style: GoogleFonts.outfit(color: Colors.amber[100], fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfigurationForm() {
    return NeonCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const NeonSectionTitle(title: 'Información Básica', color: Color(0xFFD500F9)),
          const SizedBox(height: 8),
          Text(
            'La IA generará automáticamente títulos, descripciones, hashtags, y contenido optimizado para cada plataforma',
            style: GoogleFonts.outfit(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 16),
          
          NeonInput(
            label: 'Tu negocio/marca',
            controller: _businessCtrl,
            hint: 'Ej. Cafetería Artesanal, Tienda de Ropa, Consultoría...',
          ),
          const SizedBox(height: 16),

          NeonInput(
            label: '¿Qué quieres generar hoy?',
            controller: _topicCtrl,
            hint: 'Ej. Nueva promoción 2x1, Lanzamiento de producto, Tips...',
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: NeonDropdown<String>(
                  label: 'Tipo de Contenido',
                  value: _contentType,
                  items: const [
                    DropdownMenuItem(value: 'Promocional', child: Text('Promocional')),
                    DropdownMenuItem(value: 'Educativo', child: Text('Educativo')),
                    DropdownMenuItem(value: 'Entretenimiento', child: Text('Entretenimiento')),
                    DropdownMenuItem(value: 'Inspiracional', child: Text('Inspiracional')),
                  ],
                  onChanged: (v) => _setStatePreservingScroll(() => _contentType = v!),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: NeonDropdown<String>(
                  label: 'Tono',
                  value: _tone,
                  items: const [
                    DropdownMenuItem(value: 'Profesional', child: Text('Profesional')),
                    DropdownMenuItem(value: 'Casual', child: Text('Casual')),
                    DropdownMenuItem(value: 'Divertido', child: Text('Divertido')),
                    DropdownMenuItem(value: 'Urgente', child: Text('Urgente')),
                  ],
                  onChanged: (v) => _setStatePreservingScroll(() => _tone = v!),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlatformSelection() {
    return NeonCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const NeonSectionTitle(title: 'Selecciona Plataformas', color: Colors.cyanAccent),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _platforms.map((platform) {
              final isSelected = _selectedPlatforms.contains(platform['name']);
              return GestureDetector(
                onTap: () {
                  _setStatePreservingScroll(() {
                    if (isSelected) {
                      _selectedPlatforms.remove(platform['name']);
                    } else {
                      _selectedPlatforms.add(platform['name'] as String);
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? (platform['color'] as Color).withOpacity(0.2)
                        : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected 
                          ? (platform['color'] as Color)
                          : Colors.white24,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        platform['icon'] as IconData,
                        color: isSelected ? (platform['color'] as Color) : Colors.white54,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        platform['name'] as String,
                        style: GoogleFonts.outfit(
                          color: isSelected ? Colors.white : Colors.white54,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 8),
                        Icon(Icons.check_circle, color: platform['color'] as Color, size: 16),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildGenerateButton() {
    final canGenerate = _topicCtrl.text.isNotEmpty && 
                        _businessCtrl.text.isNotEmpty && 
                        _selectedPlatforms.isNotEmpty;
    
    return Opacity(
      opacity: canGenerate ? 1.0 : 0.5,
      child: NeonButton(
        text: 'Generar Contenido para ${_selectedPlatforms.length} Plataforma${_selectedPlatforms.length > 1 ? 's' : ''}',
        icon: Icons.auto_awesome,
        color: const Color(0xFFD500F9),
        onTap: () {
          if (canGenerate) {
            _generateContent();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Completa todos los campos y selecciona al menos una plataforma')),
            );
          }
        },
        primary: true,
      ),
    );
  }

  Widget _buildLoadingState() {
    return Column(
      children: [
        const CircularProgressIndicator(color: Color(0xFFD500F9)),
        const SizedBox(height: 16),
        Text(
          'Generando contenido optimizado para cada plataforma...',
          style: GoogleFonts.outfit(color: Colors.white54, fontSize: 14),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildResults() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const NeonSectionTitle(title: 'Contenido Generado', color: Colors.greenAccent),
        const SizedBox(height: 16),
        ..._generatedContent!.entries.map((entry) => _buildPlatformResult(entry.key, entry.value)).toList(),
      ],
    );
  }

  Widget _buildPlatformResult(String platform, Map<String, String> content) {
    final platformData = _platforms.firstWhere((p) => p['name'] == platform);
    final color = platformData['color'] as Color;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF151C2B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              border: Border(bottom: BorderSide(color: color.withOpacity(0.3))),
            ),
            child: Row(
              children: [
                Icon(platformData['icon'] as IconData, color: color, size: 24),
                const SizedBox(width: 12),
                Text(
                  platform,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.copy, color: Colors.white54, size: 20),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: content['caption']!));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Copiado para $platform')),
                    );
                  },
                ),
              ],
            ),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Caption / Texto:',
                  style: GoogleFonts.outfit(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  content['caption']!,
                  style: GoogleFonts.outfit(color: Colors.white, height: 1.5),
                ),
                const SizedBox(height: 16),
                
                Text(
                  'Hashtags:',
                  style: GoogleFonts.outfit(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  content['hashtags']!,
                  style: GoogleFonts.outfit(color: const Color(0xFFD500F9), fontSize: 13),
                ),
                const SizedBox(height: 16),
                
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.lightbulb, color: Colors.amber, size: 18),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          content['tip']!,
                          style: GoogleFonts.outfit(color: Colors.amber[100], fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _generateContent() async {
    setState(() => _isGenerating = true);
    await _saveBusiness(); // Save business name for next time
    FocusScope.of(context).unfocus();
    
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 2));
    
    final results = <String, Map<String, String>>{};
    
    for (final platform in _selectedPlatforms) {
      results[platform] = _generateForPlatform(platform);
    }
    
    setState(() {
      _generatedContent = results;
      _isGenerating = false;
    });
  }

  Map<String, String> _generateForPlatform(String platform) {
    final topic = _topicCtrl.text;
    final business = _businessCtrl.text;
    
    switch (platform) {
      case 'Instagram':
        return {
          'caption': '✨ ¡$topic! ✨\n\nEn $business creemos que mereces lo mejor. ${_contentType == 'Promocional' ? '¡Aprovecha esta oportunidad única!' : 'Queremos compartir esto contigo.'}\n\n${_tone == 'Urgente' ? '⏰ ¡Por tiempo limitado!' : '💫 Descubre más en nuestro perfil.'}\n\n👉 Desliza para ver más\n📍 Visítanos o escríbenos por DM',
          'hashtags': '#$business #${topic.replaceAll(' ', '')} #Panamá #Emprendimiento #PYME #NegociosLocales',
          'tip': 'Mejor hora para publicar: 11am-1pm o 7pm-9pm. Usa Stories para mayor alcance.',
        };
      case 'Facebook':
        return {
          'caption': '$topic - $business\n\n¿Sabías que...? [Agrega dato interesante relacionado]\n\n${_contentType == 'Educativo' ? 'Te compartimos esta información valiosa para que tomes la mejor decisión.' : 'Estamos emocionados de compartir esto contigo.'}\n\n${_tone == 'Urgente' ? '⚡ ¡Actúa ahora!' : '💼 Conoce más detalles aquí.'}\n\n📞 Contáctanos: [Tu teléfono]\n📍 Ubicación: [Tu dirección]',
          'hashtags': '#$business #${topic.replaceAll(' ', '')} #PanamáEmprende #NegociosPA',
          'tip': 'Mejor hora: 1pm-3pm. Agrega fotos de alta calidad y responde comentarios rápido.',
        };
      case 'TikTok':
        return {
          'caption': 'POV: Descubres $topic en $business 👀\n\n${_tone == 'Divertido' ? '😂 No te lo esperabas, ¿verdad?' : '✨ Esto cambia todo.'}\n\n#$business #${topic.replaceAll(' ', '')} #FYP #ParaTi #PanamaTikTok #Viral',
          'hashtags': '#FYP #ParaTi #Panama #Emprendedor #PYME #Viral #Trending',
          'tip': 'Hook en los primeros 3 segundos. Usa trending sounds. Publica 1-3 veces al día.',
        };
      case 'YouTube':
        return {
          'caption': '🎥 $topic | $business\n\nEn este video te mostramos [descripción breve]. ${_contentType == 'Educativo' ? 'Aprenderás paso a paso cómo...' : 'Descubre por qué esto es importante para ti.'}\n\n⏱️ Timestamps:\n0:00 Introducción\n0:30 [Punto clave 1]\n1:15 [Punto clave 2]\n2:00 Conclusión\n\n👍 Dale like si te gustó\n🔔 Suscríbete para más contenido\n💬 Comenta tus dudas abajo\n\n🔗 Links útiles:\n[Tu sitio web]\n[Tus redes sociales]',
          'hashtags': '#$business #${topic.replaceAll(' ', '')} #Panama #Tutorial #Emprendimiento',
          'tip': 'Título con palabras clave. Thumbnail llamativo. Primeros 15 segundos son críticos.',
        };
      default:
        return {'caption': '', 'hashtags': '', 'tip': ''};
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    
    // General
    _topicCtrl.dispose();
    _businessCtrl.dispose();
    _targetAudienceCtrl.dispose();
    _painPointCtrl.dispose();
    _ctaCtrl.dispose();
    
    // YouTube
    _youtubeTitle.dispose();
    _youtubeKeywords.dispose();
    
    // Instagram
    _instagramHashtagNiche.dispose();
    
    // TikTok
    _tiktokTrendingSoundCtrl.dispose();
    
    // Facebook
    _facebookLocationCtrl.dispose();
    
    super.dispose();
  }
}
