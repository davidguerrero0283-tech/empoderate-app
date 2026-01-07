import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../ui/theme/empoderate_theme.dart';
import '../../../../src/components/neon_widgets.dart';
import 'package:proyecto_empoderate/features/ai_texts/domain/ai_text_output.dart';

class AiOutputCard extends StatelessWidget {
  final AiTextOutput output;
  final VoidCallback onSave;
  final VoidCallback onRegenerate;
  final bool isSaving;

  const AiOutputCard({
    Key? key,
    required this.output,
    required this.onSave,
    required this.onRegenerate,
    this.isSaving = false,
  }) : super(key: key);

  void _copy(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('¡$label copiado al portapapeles!'),
        backgroundColor: EmpoderateTheme.gold,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: EmpoderateTheme.gold, size: 24),
              const SizedBox(width: 8),
              Text(
                'RESULTADOS GENERADOS',
                style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // TAB BAR
          Container(
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              indicator: BoxDecoration(
                color: EmpoderateTheme.gold.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: EmpoderateTheme.gold),
              ),
              labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold),
              unselectedLabelColor: Colors.white70,
              labelColor: EmpoderateTheme.gold,
              tabs: const [
                Tab(text: 'CORTO'),
                Tab(text: 'MEDIO'),
                Tab(text: 'LARGO'),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // TAB CONTENT
          Container(
            height: 250,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white12),
            ),
            child: TabBarView(
              children: [
                _buildTextContent(context, output.shortVersion, 'Texto corto'),
                _buildTextContent(context, output.mediumVersion, 'Texto medio'),
                _buildTextContent(context, output.longVersion, 'Texto largo'),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // HASHTAGS
          Text('Hashtags sugeridos', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: output.hashtags.map((h) => Chip(
              label: Text(h, style: const TextStyle(fontSize: 11, color: Colors.blueAccent)),
              backgroundColor: Colors.blueAccent.withOpacity(0.1),
              side: BorderSide(color: Colors.blueAccent.withOpacity(0.3)),
            )).toList(),
          ),
          
          const SizedBox(height: 32),
          
          // ACTIONS
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onRegenerate,
                  icon: const Icon(Icons.refresh),
                  label: const Text('REGENERAR'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    side: const BorderSide(color: Colors.white24),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isSaving ? null : onSave,
                  icon: isSaving 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black45))
                    : const Icon(Icons.bookmark_add),
                  label: Text(isSaving ? 'GUARDANDO...' : 'GUARDAR'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: EmpoderateTheme.cyanAccent,
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextContent(BuildContext context, String text, String label) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Text(
              text,
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 15, height: 1.5),
            ),
          ),
        ),
        const Divider(color: Colors.white12),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () => _copy(context, text, label),
            icon: const Icon(Icons.copy, size: 18, color: EmpoderateTheme.gold),
            label: Text('Copiar este texto', style: GoogleFonts.outfit(color: EmpoderateTheme.gold)),
          ),
        ),
      ],
    );
  }
}
