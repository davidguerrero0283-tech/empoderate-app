import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:proyecto_empoderate/src/components/premium_scaffold.dart';
import 'package:proyecto_empoderate/src/components/neon_widgets.dart';
import 'package:proyecto_empoderate/src/features/marketing/marketing_service.dart';

class MarketingContentScreen extends StatefulWidget {
  const MarketingContentScreen({Key? key}) : super(key: key);

  @override
  State<MarketingContentScreen> createState() => _MarketingContentScreenState();
}

class _MarketingContentScreenState extends State<MarketingContentScreen> {
  final _topicCtrl = TextEditingController();
  
  // Advanced Inputs
  String _platform = 'Instagram';
  String _tone = 'Divertido';
  String _goal = 'Ventas';
  
  bool _isLoading = false;
  List<Map<String, dynamic>> _ideas = [];
  final _service = MarketingService();

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      title: 'Contenido IA Pro',
      isNeonTitle: true,
      showBackButton: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 80),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildAdvancedForm(),
            const SizedBox(height: 30),
            
            if (_isLoading)
               _buildLoading()
            else if (_ideas.isNotEmpty)
              _buildResults()
            else
              _buildPlaceholder(),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return Column(
      children: [
        const CircularProgressIndicator(color: Color(0xFFD500F9)),
        const SizedBox(height: 16),
        Text(
          'Analizando tendencias y estructurando guiones...',
          style: GoogleFonts.outfit(color: Colors.white54, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildAdvancedForm() {
    return NeonCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               const NeonSectionTitle(title: 'Configurador de Estrategia', color: Color(0xFFD500F9)),
               Container(
                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                 decoration: BoxDecoration(color: const Color(0xFFD500F9).withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                 child: const Text('PRO', style: TextStyle(color: Color(0xFFD500F9), fontWeight: FontWeight.bold, fontSize: 10)),
               )
            ],
          ),
          const SizedBox(height: 16),
          NeonInput(
            label: '¿Sobre qué quieres hablar?',
            controller: _topicCtrl,
            hint: 'Ej. Beneficios del Matcha, Seguro de Autos...',
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: NeonDropdown<String>(
                  label: 'Plataforma',
                  value: _platform,
                  items: const [
                    DropdownMenuItem(value: 'Instagram', child: Text('Instagram')),
                    DropdownMenuItem(value: 'TikTok', child: Text('TikTok')),
                    DropdownMenuItem(value: 'LinkedIn', child: Text('LinkedIn')),
                  ],
                  onChanged: (v) => setState(() => _platform = v!),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: NeonDropdown<String>(
                  label: 'Objetivo',
                  value: _goal,
                  items: const [
                    DropdownMenuItem(value: 'Ventas', child: Text('Ventas Directas')),
                    DropdownMenuItem(value: 'Viralidad', child: Text('Alcance / Viral')),
                    DropdownMenuItem(value: 'Comunidad', child: Text('Fidelización')),
                  ],
                  onChanged: (v) => setState(() => _goal = v!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          NeonDropdown<String>(
            label: 'Tono de Comunicación',
            value: _tone,
            items: const [
              DropdownMenuItem(value: 'Divertido', child: Text('Divertido / Casual')),
              DropdownMenuItem(value: 'Autoridad', child: Text('Autoridad / Serio')),
              DropdownMenuItem(value: 'Empático', child: Text('Empático / Cercano')),
            ],
            onChanged: (v) => setState(() => _tone = v!),
          ),
          
          const SizedBox(height: 24),
          NeonButton(
            text: "Generar Estrategia Completa",
            icon: Icons.auto_awesome,
            color: const Color(0xFFD500F9),
            onTap: _generate,
          )
        ],
      ),
    );
  }

  Future<void> _generate() async {
    if (_topicCtrl.text.isEmpty) return;
    
    setState(() => _isLoading = true);
    FocusScope.of(context).unfocus();

    final result = await _service.generateContentIdeas(
      topic: _topicCtrl.text, 
      platform: _platform,
      tone: _tone,
      goal: _goal,
    );
    
    if (mounted) {
      setState(() {
        _ideas = result;
        _isLoading = false;
      });
    }
  }

  Widget _buildResults() {
    return Column(
      children: [
        const NeonSectionTitle(title: 'Estrategias Generadas', color: Colors.cyanAccent),
        const SizedBox(height: 16),
        ..._ideas.map((idea) => _buildIdeaCard(idea)).toList(),
      ],
    );
  }

  Widget _buildIdeaCard(Map<String, dynamic> idea) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF151C2B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.02),
              border: const Border(bottom: BorderSide(color: Colors.white10)),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Icon(Icons.movie_filter, color: Colors.cyanAccent, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text(idea['title'], style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold))),
                _buildTag(idea['goal_match'], Colors.greenAccent),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Visual Hook Section
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.visibility, color: Colors.white54, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(idea['visual_hook'], style: GoogleFonts.outfit(color: Colors.white70, fontStyle: FontStyle.italic)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Script Section
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                         children: [
                           Text('GUION / CAPTION', style: GoogleFonts.outfit(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)),
                           GestureDetector(
                             onTap: () {
                               Clipboard.setData(ClipboardData(text: idea['script_body']));
                               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Guion copiado')));
                             },
                             child: const Icon(Icons.copy, color: Colors.white38, size: 16),
                           )
                         ],
                      ),
                      const SizedBox(height: 8),
                      Text(idea['script_body'], style: GoogleFonts.outfit(color: Colors.white, height: 1.5)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Footer: Hashtags & Pro Tip
                Row(
                  children: [
                    Expanded(
                      child: Text(idea['hashtags'], style: GoogleFonts.outfit(color: const Color(0xFFD500F9), fontSize: 13)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                     color: Colors.amber.withOpacity(0.1),
                     borderRadius: BorderRadius.circular(8),
                     border: Border.all(color: Colors.amber.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.lightbulb, color: Colors.amber, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(idea['pro_tip'], style: GoogleFonts.outfit(color: Colors.amber[100], fontSize: 12)),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(text, style: GoogleFonts.outfit(color: color, fontSize: 10)),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_awesome_mosaic, size: 64, color: Colors.white.withOpacity(0.1)),
            const SizedBox(height: 16),
            Text(
              'Configura los parámetros arriba para desbloquear estrategias completas.',
              style: GoogleFonts.outfit(color: Colors.white38),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
