import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../components/premium_scaffold.dart';
import '../components/neon_widgets.dart';
import '../components/calculator_info_panel.dart';

class AuditoriaNegocioScreen extends StatelessWidget {
  const AuditoriaNegocioScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      title: 'AUDITORÍA',
      showBackButton: true,
      // Use global defaults (no custom gradients)

      
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // 1. Info Panel
              const CalculatorInfoPanel(configId: 'auditoria'),
              const SizedBox(height: 24),
              
              const NeonSectionTitle(
                title: 'Estado del Negocio',
                color: kNeonViolet, 
              ),
              const SizedBox(height: 16),
              
              // Table using NeonTable
              NeonTable(
                headers: const ['Área', 'Estado', 'Prioridad'],
                accentColor: kNeonViolet,
                rows: [
                  [
                    Text('Legal', style: GoogleFonts.outfit(color: Colors.white70, fontWeight: FontWeight.bold)),
                    _buildStatusChip('En proceso', Colors.orange),
                    Text('Alta', style: GoogleFonts.outfit(color: kNeonRed, fontWeight: FontWeight.bold)),
                  ],
                  [
                    Text('Marketing', style: GoogleFonts.outfit(color: Colors.white70, fontWeight: FontWeight.bold)),
                    _buildStatusChip('Sin iniciar', kNeonRed),
                    Text('Media', style: GoogleFonts.outfit(color: Colors.white54)),
                  ],
                  [
                    Text('Contabilidad', style: GoogleFonts.outfit(color: Colors.white70, fontWeight: FontWeight.bold)),
                    _buildStatusChip('En proceso', Colors.orange),
                    Text('Alta', style: GoogleFonts.outfit(color: kNeonRed, fontWeight: FontWeight.bold)),
                  ],
                  [
                    Text('RRHH', style: GoogleFonts.outfit(color: Colors.white70, fontWeight: FontWeight.bold)),
                    _buildStatusChip('Completado', kNeonGreen),
                    Text('Baja', style: GoogleFonts.outfit(color: Colors.white54)),
                  ],
                  [
                    Text('Operaciones', style: GoogleFonts.outfit(color: Colors.white70, fontWeight: FontWeight.bold)),
                    _buildStatusChip('Completado', kNeonGreen),
                    Text('Baja', style: GoogleFonts.outfit(color: Colors.white54)),
                  ],
                ],
              ),

              const SizedBox(height: 32),
              // Buttons
              Row(
                children: [
                  Expanded(
                    child: NeonButton(
                      text: 'Actualizar Datos',
                      onTap: () => _showUpdateDialog(context),
                      primary: true, 
                      icon: Icons.edit_note,
                      color: kNeonBlue,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: NeonButton(
                      text: 'Ver Recomendaciones',
                      onTap: () => _showRecommendationsSheet(context),
                      primary: false, 
                      icon: Icons.lightbulb,
                      color: kNeonViolet,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              
              // Next Steps Card
              NeonWideCard(
                borderColor: kNeonPurple,
                isPremium: true, 
                child: Column(
                  children: [
                    Icon(Icons.auto_awesome, color: kNeonPurple, size: 32, shadows: [BoxShadow(color: kNeonPurple.withOpacity(0.5), blurRadius: 10)]),
                    const SizedBox(height: 12),
                    Text(
                      'Próximamente: Auditoría IA en tiempo real',
                      style: GoogleFonts.outfit(
                        color: kNeonPurple,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Conectaremos tus datos de Bóveda y Calculadoras para darte un diagnóstico automático.',
                      style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String label, Color color) {
    return Row(
      children: [
        Icon(Icons.circle, size: 8, color: color, shadows: [BoxShadow(color: color.withOpacity(0.5), blurRadius: 4)]),
        const SizedBox(width: 6),
        Expanded(child: Text(label, style: GoogleFonts.outfit(color: color, fontSize: 12, fontWeight: FontWeight.w500))),
      ],
    );
  }

  void _showUpdateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0F1520),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: kNeonBlue)),
        title: Text('Actualizar Auditoría', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text('Aquí podrás modificar manualmente el estado de cada área y agregar notas.', style: GoogleFonts.outfit(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () { 
              Navigator.pop(context); 
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Datos actualizados (Simulado)')));
            }, 
            style: ElevatedButton.styleFrom(backgroundColor: kNeonBlue),
            child: const Text('Guardar', style: TextStyle(color: Colors.white))
          ),
        ],
      ),
    );
  }

  void _showRecommendationsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F1520),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.lightbulb, color: kNeonViolet),
                const SizedBox(width: 12),
                Text('Recomendaciones', style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            _buildRecItem('Legal', 'Prioridad Alta: Sube tu Aviso de Operaciones a la Bóveda para cambiar el estado.'),
            _buildRecItem('Marketing', 'Crea una cuenta de Instagram Business y define tu logo.'),
            _buildRecItem('Contabilidad', 'Registra tus ingresos diarios en la Calculadora de Flujo.'),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: NeonButton(text: 'Entendido', onTap: () => Navigator.pop(context), primary: true, color: kNeonViolet),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildRecItem(String area, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.arrow_right, color: Colors.white54),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13),
                children: [
                  TextSpan(text: '$area: ', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  TextSpan(text: text),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
