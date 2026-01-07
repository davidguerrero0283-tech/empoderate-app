import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../ui/theme/empoderate_theme.dart';
import '../../../../src/components/neon_widgets.dart';
import 'package:proyecto_empoderate/features/ai_customers/domain/ai_customer_output.dart';

class AiCustomerOutputCard extends StatelessWidget {
  final AiCustomerOutput output;
  final VoidCallback onSave;
  final VoidCallback onRegenerate;
  final bool isSaving;

  const AiCustomerOutputCard({
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
        content: Text('$label copiado al portapapeles'),
        backgroundColor: Colors.cyanAccent,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          // TAB BAR
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.cyanAccent.withOpacity(0.2),
              ),
              labelColor: Colors.cyanAccent,
              unselectedLabelColor: Colors.white70,
              labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13),
              tabs: const [
                Tab(text: 'PERFIL'),
                Tab(text: 'ESTRATEGIA'),
                Tab(text: 'MAPA'),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // TAB CONTENT
          Container(
            height: 350,
            padding: const EdgeInsets.all(20),
            decoration: EmpoderateTheme.premiumGlassCard.copyWith(
               border: Border.all(color: Colors.cyanAccent.withOpacity(0.2)),
            ),
            child: TabBarView(
              children: [
                _buildContent(context, output.buyerPersona, 'Perfil del Cliente'),
                _buildContent(context, output.strategy, 'Estrategia de Fidelización'),
                _buildContent(context, output.empathyMap, 'Mapa de Empatía'),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // SUGGESTED ACTION
          NeonWideCard(
            borderColor: Colors.purpleAccent,
            child: Row(
              children: [
                const Icon(Icons.flash_on, color: Colors.purpleAccent),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ACCIÓN RECOMENDADA',
                        style: GoogleFonts.outfit(color: Colors.purpleAccent, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        output.suggestedAction,
                        style: GoogleFonts.outfit(color: Colors.white, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
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
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.bookmark_border),
                  label: Text(isSaving ? 'GUARDANDO...' : 'GUARDAR'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyanAccent,
                    foregroundColor: Colors.black,
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

  Widget _buildContent(BuildContext context, String content, String label) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Text(
              content,
              style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.9), fontSize: 15, height: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () => _copy(context, content, label),
            icon: const Icon(Icons.copy, size: 16, color: Colors.cyanAccent),
            label: Text('COPIAR', style: GoogleFonts.outfit(color: Colors.cyanAccent, fontSize: 12)),
          ),
        ),
      ],
    );
  }
}
