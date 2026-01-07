import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../ui/theme/empoderate_theme.dart';
import '../../../../src/components/neon_widgets.dart';
import 'package:proyecto_empoderate/features/ai_customers/domain/ai_customer_request.dart';

class AiCustomerRequestForm extends StatefulWidget {
  final Function(AiCustomerRequest) onGenerate;
  final bool isLoading;

  const AiCustomerRequestForm({
    Key? key,
    required this.onGenerate,
    required this.isLoading,
  }) : super(key: key);

  @override
  State<AiCustomerRequestForm> createState() => _AiCustomerRequestFormState();
}

class _AiCustomerRequestFormState extends State<AiCustomerRequestForm> {
  final _formKey = GlobalKey<FormState>();
  
  // MAGIC INPUT
  final TextEditingController _promptController = TextEditingController();

  // ADVANCED OPTIONS
  bool _showAdvanced = false;
  final TextEditingController _businessTypeController = TextEditingController();
  final TextEditingController _segmentController = TextEditingController();
  String _tone = 'profesional';

  final List<Map<String, String>> _tones = [
    {'id': 'profesional', 'label': 'Profesional'},
    {'id': 'persuasivo', 'label': 'Persuasivo'},
    {'id': 'empático', 'label': 'Empático'},
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
            'DATOS O IDEA SOBRE TU CLIENTE',
            style: GoogleFonts.outfit(color: EmpoderateTheme.gold, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _promptController,
            style: GoogleFonts.outfit(color: Colors.white, fontSize: 16),
            maxLines: 4,
            decoration: EmpoderateTheme.inputDecoration('Ej: Mujeres emprendedoras de 30-40 años que buscan libertad financiera...').copyWith(
              fillColor: EmpoderateTheme.deepBlue,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.cyanAccent.withOpacity(0.5)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Colors.cyanAccent, width: 2),
              ),
            ),
            validator: (v) => (v == null || v.isEmpty) ? 'Describe a tu cliente para comenzar' : null,
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
                  _showAdvanced ? 'Ocultar opciones avanzadas' : 'Refinar perfil (Opcional)',
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
              ? const Center(child: CircularProgressIndicator(color: Colors.cyanAccent))
              : ElevatedButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.psychology),
                  style: EmpoderateTheme.primaryButtonStyle.copyWith(
                    backgroundColor: MaterialStateProperty.all(Colors.cyanAccent.withOpacity(0.8)),
                    foregroundColor: MaterialStateProperty.all(Colors.black),
                    shadowColor: MaterialStateProperty.all(Colors.cyanAccent.withOpacity(0.5)),
                    elevation: MaterialStateProperty.all(8),
                  ),
                  label: Text(
                    'GENERAR ESTRATEGIA',
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
      decoration: EmpoderateTheme.premiumGlassCard.copyWith(
        border: Border.all(color: Colors.cyanAccent.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildChipSelector('Tono de comunicación', _tone, _tones, (val) => setState(() => _tone = val)),
          const SizedBox(height: 16),
           _buildTextField(_businessTypeController, 'Tu Rubro/Negocio', 'Ej: Consultoría'),
          const SizedBox(height: 12),
          _buildTextField(_segmentController, 'Segmento Específico', 'Ej: Profesionales Independientes'),
        ],
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final request = AiCustomerRequest(
        prompt: _promptController.text,
        businessType: _businessTypeController.text.isNotEmpty ? _businessTypeController.text : null,
        targetSegment: _segmentController.text.isNotEmpty ? _segmentController.text : null,
        tone: _tone,
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
                  color: isSelected ? Colors.cyanAccent.withOpacity(0.2) : Colors.white12,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isSelected ? Colors.cyanAccent : Colors.white24),
                ),
                child: Text(
                  item['label']!,
                  style: GoogleFonts.outfit(
                    color: isSelected ? Colors.cyanAccent : Colors.white70,
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
