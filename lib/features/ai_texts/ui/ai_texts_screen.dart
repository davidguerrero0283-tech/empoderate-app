import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../ui/theme/empoderate_theme.dart';
import '../../../ui/theme/color_palette.dart';
import '../../../src/components/premium_scaffold.dart';
import '../../../src/components/neon_widgets.dart';
import 'package:proyecto_empoderate/features/ai_texts/domain/ai_text_request.dart';
import 'package:proyecto_empoderate/features/ai_texts/domain/ai_text_output.dart';
import 'package:proyecto_empoderate/features/ai_texts/data/ai_texts_service.dart';
import 'package:proyecto_empoderate/features/ai_texts/ui/widgets/request_form.dart';
import 'package:proyecto_empoderate/features/ai_texts/ui/widgets/output_card.dart';

class AiTextsScreen extends StatefulWidget {
  const AiTextsScreen({Key? key}) : super(key: key);

  @override
  State<AiTextsScreen> createState() => _AiTextsScreenState();
}

class _AiTextsScreenState extends State<AiTextsScreen> {
  final AiTextsService _service = AiTextsService();
  bool _isLoading = false;
  bool _isSaving = false;
  AiTextOutput? _currentOutput;
  AiTextRequest? _lastRequest;

  Future<void> _generate(AiTextRequest request) async {
    setState(() {
      _isLoading = true;
      _lastRequest = request;
    });

    try {
      final output = await _service.generate(request);
      setState(() {
        _currentOutput = output;
        _isLoading = false;
      });
      
      // Auto-scroll to results
      Future.delayed(const Duration(milliseconds: 300), () {
        Scrollable.ensureVisible(
          context,
          duration: const Duration(seconds: 1),
          curve: Curves.easeInOut,
        );
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al generar textos. Intenta de nuevo.')),
      );
    }
  }

  Future<void> _save() async {
    if (_currentOutput == null) return;
    
    setState(() => _isSaving = true);
    try {
      await _service.save(_currentOutput!);
      setState(() => _isSaving = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('¡Guardado en tu Biblioteca con éxito!'),
          backgroundColor: EmpoderateTheme.cyanAccent,
          action: SnackBarAction(
            label: 'VER',
            textColor: Colors.black87,
            onPressed: () => Navigator.pushNamed(context, '/library'),
          ),
        ),
      );
    } catch (e) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al guardar.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      title: 'IA PARA TEXTOS',
      subtitle: 'Contenido magnético para tu marca',
      body: Column(
        children: [
          // HEADER EXPLANATION
          NeonWideCard(
            borderColor: EmpoderateTheme.gold,
            child: Row(
              children: [
                const Icon(Icons.tips_and_updates, color: EmpoderateTheme.gold, size: 32),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Copia profesional en segundos',
                        style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Completa el formulario y deja que nuestra IA cree 3 versiones optimizadas para ti.',
                        style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // GENERATION FORM
          AiRequestForm(
            onGenerate: _generate,
            isLoading: _isLoading,
          ),
          
          // DIVIDER IF RESULTS EXIST
          if (_currentOutput != null) ...[
            const SizedBox(height: 40),
            const Divider(color: EmpoderateTheme.gold, thickness: 1),
            const SizedBox(height: 20),
            
            // RESULTS SECTION
            AiOutputCard(
              output: _currentOutput!,
              onSave: _save,
              onRegenerate: () => _generate(_lastRequest!),
              isSaving: _isSaving,
            ),
          ],
          
          const SizedBox(height: 60),
        ],
      ),
    );
  }
}
