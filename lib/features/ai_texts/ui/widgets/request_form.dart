import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../ui/theme/empoderate_theme.dart';
import '../../../../src/components/neon_widgets.dart';
import 'package:proyecto_empoderate/features/ai_texts/domain/ai_text_request.dart';

class AiRequestForm extends StatefulWidget {
  final Function(AiTextRequest) onGenerate;
  final bool isLoading;

  const AiRequestForm({
    Key? key,
    required this.onGenerate,
    required this.isLoading,
  }) : super(key: key);

  @override
  State<AiRequestForm> createState() => _AiRequestFormState();
}

class _AiRequestFormState extends State<AiRequestForm> {
  final _formKey = GlobalKey<FormState>();
  
  // MAGIC INPUT
  final TextEditingController _promptController = TextEditingController();

  // ADVANCED OPTIONS
  bool _showAdvanced = false;
  String _format = 'post_ig';
  final TextEditingController _businessTypeController = TextEditingController();
  final TextEditingController _audienceController = TextEditingController();
  String? _goal; // Optional in magic mode
  String _tone = 'profesional';
  final TextEditingController _keywordsController = TextEditingController();
  final TextEditingController _ctaController = TextEditingController();

  final List<Map<String, String>> _formats = [
    {'id': 'post_ig', 'label': 'Post Instagram'},
    {'id': 'caption', 'label': 'Caption / Pie de foto'},
    {'id': 'whatsapp_broadcast', 'label': 'Difusión WhatsApp'},
    {'id': 'reels_script', 'label': 'Guion de Reel'},
    {'id': 'blog_short', 'label': 'Blog Corto'},
    {'id': 'web_about', 'label': 'Web: Sobre Nosotros'},
  ];

  final List<Map<String, String>> _goals = [
    {'id': 'vender', 'label': 'Vender'},
    {'id': 'educar', 'label': 'Educar'},
    {'id': 'anunciar', 'label': 'Anunciar'},
    {'id': 'captar_leads', 'label': 'Captar Prospectos'},
  ];

  final List<Map<String, String>> _tones = [
    {'id': 'profesional', 'label': 'Profesional'},
    {'id': 'cercano', 'label': 'Cercano'},
    {'id': 'premium', 'label': 'Premium'},
    {'id': 'directo', 'label': 'Directo'},
  ];

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. MAGIC PROMPT AREA
          Text(
            'TU IDEA MÁGICA',
            style: GoogleFonts.outfit(color: EmpoderateTheme.gold, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _promptController,
            style: GoogleFonts.outfit(color: Colors.white, fontSize: 16),
            maxLines: 4,
            decoration: EmpoderateTheme.inputDecoration('Ej: Promoción de verano para zapatos deportivos con 20% de descuento...').copyWith(
              fillColor: EmpoderateTheme.deepBlue,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: EmpoderateTheme.gold.withOpacity(0.5)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: EmpoderateTheme.gold, width: 2),
              ),
            ),
            validator: (v) => (v == null || v.isEmpty) ? 'Escribe tu idea para comenzar' : null,
          ),
          
          const SizedBox(height: 24),

          // 2. TOGGLE ADVANCED
          GestureDetector(
            onTap: () => setState(() => _showAdvanced = !_showAdvanced),
            child: Row(
              children: [
                Icon(_showAdvanced ? Icons.keyboard_arrow_up : Icons.tune, color: Colors.white70, size: 20),
                const SizedBox(width: 8),
                Text(
                  _showAdvanced ? 'Ocultar opciones avanzadas' : 'Personalizar detalles (Opcional)',
                  style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),

          // 3. ADVANCED SECTION
          AnimatedCrossFade(
            firstChild: Container(),
            secondChild: _buildAdvancedOptions(),
            crossFadeState: _showAdvanced ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),

          const SizedBox(height: 32),
          
          // ACTION BUTTON
          SizedBox(
            width: double.infinity,
            height: 55,
            child: widget.isLoading 
              ? const Center(child: CircularProgressIndicator(color: EmpoderateTheme.gold))
              : ElevatedButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.auto_awesome),
                  style: EmpoderateTheme.primaryButtonStyle.copyWith(
                    shadowColor: MaterialStateProperty.all(EmpoderateTheme.gold.withOpacity(0.5)),
                    elevation: MaterialStateProperty.all(8),
                  ),
                  label: Text(
                    'GENERAR MAGIA',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1),
                  ),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedOptions() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(20),
      decoration: EmpoderateTheme.premiumGlassCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDropdown('Formato', _format, _formats, (val) => setState(() => _format = val!)),
          const SizedBox(height: 16),
          _buildChipSelector('Tono de voz', _tone, _tones, (val) => setState(() => _tone = val)),
          const SizedBox(height: 16),
           _buildTextField(_businessTypeController, 'Tu Rubro', 'Ej: Moda'),
          const SizedBox(height: 12),
          _buildTextField(_audienceController, 'Tu Público', 'Ej: Jóvenes'),
          const SizedBox(height: 12),
          _buildTextField(_ctaController, 'Llamado a la acción', 'Ej: Compra aquí'),
        ],
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final request = AiTextRequest(
        format: _format,
        prompt: _promptController.text,
        businessType: _businessTypeController.text.isNotEmpty ? _businessTypeController.text : null,
        audience: _audienceController.text.isNotEmpty ? _audienceController.text : null,
        goal: _goal, // Can be null now
        tone: _tone,
        keywords: _keywordsController.text.isNotEmpty ? _keywordsController.text.split(',') : [],
        callToAction: _ctaController.text.isNotEmpty ? _ctaController.text : null,
      );
      widget.onGenerate(request);
    }
  }

  Widget _buildTextField(TextEditingController controller, String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          style: GoogleFonts.outfit(color: Colors.white),
          decoration: EmpoderateTheme.inputDecoration(hint),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, String value, List<Map<String, String>> items, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white24),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              dropdownColor: EmpoderateTheme.deepBlue,
              style: GoogleFonts.outfit(color: Colors.white),
              isExpanded: true,
              items: items.map((item) => DropdownMenuItem(
                value: item['id'],
                child: Text(item['label']!),
              )).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChipSelector(String label, String current, List<Map<String, String>> items, Function(String) onSelect) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items.map((item) {
            final isSelected = current == item['id'];
            return GestureDetector(
              onTap: () => onSelect(item['id']!),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? EmpoderateTheme.gold.withOpacity(0.2) : Colors.white12,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isSelected ? EmpoderateTheme.gold : Colors.white24),
                ),
                child: Text(
                  item['label']!,
                  style: GoogleFonts.outfit(
                    color: isSelected ? EmpoderateTheme.gold : Colors.white70,
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
